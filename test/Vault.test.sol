// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.8.17;

import { IERC20, IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { ERC20PresetMinterPauser } from "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";
import { PRBTest } from "@prb/test/PRBTest.sol";
import { console2 } from "forge-std/console2.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { IVault, Vault } from "../src/Vault.sol";

/// @dev See the "Writing Tests" section in the Foundry Book if this is your first time with Forge.
/// @dev Run Forge with `-vvvv` to see console logs.
/// https://book.getfoundry.sh/forge/writing-tests
contract VaultTest is PRBTest, StdCheats {
    Vault internal immutable vault;
    ERC20PresetMinterPauser internal immutable token;

    constructor() {
        token = new ERC20PresetMinterPauser("test", "TEST");
        vault = new Vault(IERC20Metadata(address(token)));
    }

    function setUp() public {
        token.approve(address(vault), type(uint256).max);
        token.mint(address(this), type(uint256).max);
    }

    function testBase() public {
        assertTrue(keccak256(bytes(vault.name())) == keccak256(bytes("Ithil test")));
        assertTrue(keccak256(bytes(vault.symbol())) == keccak256(bytes("iTEST")));
        assertTrue(vault.asset() == address(token));
        assertTrue(vault.decimals() == token.decimals());
        assertTrue(vault.creationTime() == block.timestamp);
        assertTrue(vault.netLoans() == 0);
        assertTrue(vault.currentProfits() == 0);
    }

    function testAccess() public {
        vm.prank(address(0));
        vm.expectRevert();
        vault.setFeeUnlockTime(1000);
    }

    function testDeposit(uint256 amount) public {
        uint256 balanceBefore = token.balanceOf(address(this));
        vault.deposit(amount, address(this));
        assertTrue(vault.totalAssets() == amount);
        uint256 change = balanceBefore - token.balanceOf(address(this));
        assertTrue(change == amount);
        assertTrue(vault.balanceOf(address(this)) == amount);
    }

    function testWithdraw(uint256 amount) public {
        vm.assume(amount > 0);
        vault.deposit(amount, address(this));

        // withdraw on behalf of another user
        vm.prank(address(0));
        vm.expectRevert();
        vault.withdraw(amount - 1, address(this), address(this));

        uint256 balanceBefore = token.balanceOf(address(this));
        vault.withdraw(amount - 1, address(this), address(this));
        assertTrue(vault.totalAssets() == 1);
        uint256 change = token.balanceOf(address(this)) - balanceBefore;
        assertTrue(change == amount - 1);
    }

    function testRedeem(uint256 amount) public {
        vm.assume(amount > 0);
        vault.mint(amount, address(this));

        // Cannot redeem everything, only one less than maximum
        vm.expectRevert(IVault.Insufficient_Liquidity.selector);
        vault.redeem(amount, address(this), address(this));

        uint256 balanceBefore = vault.balanceOf(address(this));
        vault.redeem(amount - 1, address(this), address(this));
        assertTrue(vault.totalAssets() == 1);
        uint256 change = balanceBefore - vault.balanceOf(address(this));
        assertTrue(change == amount - 1);
    }

    function testCannotWithdrawMoreThanFreeLiquidity(uint256 amount) public {
        vm.assume(amount > 0);
        vault.deposit(amount, address(this));

        // withdraw without leaving 1 token unit
        uint256 vaultBalance = token.balanceOf(address(vault));
        vm.expectRevert(IVault.Insufficient_Liquidity.selector);
        vault.withdraw(vaultBalance, address(this), address(this));
    }

    function testCannotBorrowMoreThanFreeLiquidity(uint256 amount) public {
        vm.assume(amount > 0);
        vault.deposit(amount, address(this));

        uint256 vaultBalance = token.balanceOf(address(vault));
        vm.expectRevert(IVault.Insufficient_Free_Liquidity.selector);
        vault.borrow(vaultBalance, address(this));
    }

    function testDirectMintDilutesOtherLPs(uint256 amount1, uint256 amount2, uint256 toMint) public {
        vm.assume(amount1 > 0 && amount1 < type(uint64).max);
        vm.assume(amount2 > 0 && amount2 < type(uint64).max);
        vm.assume(toMint < type(uint64).max);

        token.transfer(address(1), amount1);
        vm.startPrank(address(1));
        token.approve(address(vault), amount1);
        vault.deposit(amount1, address(1));
        vm.stopPrank();

        token.transfer(address(2), amount2);
        vm.startPrank(address(2));
        token.approve(address(vault), amount2);
        vault.deposit(amount2, address(2));
        vm.stopPrank();

        uint256 investorShares = vault.balanceOf(address(2));
        uint256 initialMaximumWithdraw1 = vault.maxWithdraw(address(1));
        uint256 initialMaximumWithdraw2 = vault.maxWithdraw(address(2));

        uint256 supply = vault.totalSupply();
        // Check maximum withdraw stay the same while direct minting
        vault.directMint(toMint, address(2));
        assertTrue(initialMaximumWithdraw1 == vault.maxWithdraw(address(1)));

        // Advance time to unlock the loss
        vm.warp(block.timestamp + vault.feeUnlockTime());
        uint256 finalMaximumWithdraw1 = vault.maxWithdraw(address(1));
        uint256 finalMaximumWithdraw2 = vault.maxWithdraw(address(2));

        // Initially with the same shares, now investor2 has twice as many as investor1
        // Therefore investor1 can withdraw only one-third of the total amount
        // Fix rounding errors
        assertTrue(finalMaximumWithdraw1 == (initialMaximumWithdraw1 * supply) / (supply + toMint));
        assertTrue(
            finalMaximumWithdraw2 ==
                (initialMaximumWithdraw2 * supply * (investorShares + toMint)) / (investorShares * (supply + toMint))
        );

        // The total amount is very close to be constant, but there are rounding errors (not avoidable)
    }
}
