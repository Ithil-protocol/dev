// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.8.17;

import { IERC20, IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { ERC20PresetMinterPauser } from "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";
import { PRBTest } from "@prb/test/PRBTest.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { IManager } from "../src/interfaces/IManager.sol";
import { IVault } from "../src/interfaces/IVault.sol";
import { Manager } from "../src/Manager.sol";
import { GeneralMath } from "../src/libraries/GeneralMath.sol";
import { AuctionRateModel } from "../src/irmodels/AuctionRateModel.sol";

contract VanillaCreditService {
    IManager internal immutable manager;
    address internal immutable token;

    constructor(IManager _manager, address _token) {
        manager = _manager;
        token = _token;
    }

    function deposit(uint256 amount) external {
        manager.deposit(token, amount, address(this), msg.sender);
    }

    function withdraw(uint256 amount, address receiver, address owner) external {
        manager.withdraw(token, amount, receiver, owner);
    }
}

contract MockService is AuctionRateModel {
    IManager internal immutable manager;
    address internal immutable token;
    uint256 internal constant initialRiskSpread = 5e16;

    constructor(IManager _manager, address _token) AuctionRateModel(1 weeks, initialRiskSpread) {
        manager = _manager;
        token = _token;

        IERC20(token).approve(manager.vaults(token), type(uint256).max);
    }

    function pull(uint256 amount) external returns (uint256) {
        (uint256 freeLiquidity, ) = manager.borrow(token, amount, address(this));
        return computeInterestRate(amount, freeLiquidity);
    }

    function push(uint256 amount, uint256 debt) external {
        manager.repay(token, amount, debt, address(this));
    }
}

contract InterestRateTest is PRBTest, StdCheats {
    using GeneralMath for uint256;

    ERC20PresetMinterPauser internal immutable token;
    Manager internal immutable manager;
    MockService internal immutable service;
    VanillaCreditService internal immutable vanillaCreditService;
    IVault internal immutable vault;

    constructor() {
        token = new ERC20PresetMinterPauser("test", "TEST");
        manager = new Manager();
        vault = IVault(manager.create(address(token)));
        service = new MockService(manager, address(token));
        manager.setSpread(address(service), address(token), 1e15);
        manager.setCap(address(service), address(token), 1e18);
        vanillaCreditService = new VanillaCreditService(manager, address(token));
        manager.setCap(address(vanillaCreditService), address(token), 1e18);
    }

    function setUp() public {
        token.mint(address(this), type(uint256).max);
        token.approve(address(vault), type(uint256).max);
    }

    function testIRIncrease(uint256 deposited, uint256 borrowed) public {
        vm.assume(borrowed < deposited / 2);

        vanillaCreditService.deposit(deposited);
        uint256 interestRate = service.pull(borrowed);
        assertTrue(interestRate == uint256(5e16).safeMulDiv(deposited, deposited - borrowed));
    }

    function testDutchAuction(uint256 deposited, uint256 borrowed1, uint256 borrowed2, uint256 timePast) public {
        // less than 3000 years past and amounts do not make interest rate overflow
        vm.assume(borrowed1 < deposited / 2 && borrowed2 < ((deposited / 2) - borrowed1) / 2 && timePast < 1e11);
        uint256 halvingTime = 1 weeks;

        vanillaCreditService.deposit(deposited);
        uint256 initialInterestRate = service.pull(borrowed1);
        uint256 initialTimestamp = block.timestamp;
        vm.warp(initialTimestamp + timePast);
        uint256 finalInterestRate = service.pull(borrowed2);
        assertTrue(
            finalInterestRate ==
                (initialInterestRate.safeMulDiv(deposited - borrowed1, deposited - borrowed1 - borrowed2)).safeMulDiv(
                    halvingTime,
                    block.timestamp - initialTimestamp + halvingTime
                )
        );
    }
}
