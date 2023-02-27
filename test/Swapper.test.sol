// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.8.17;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Test } from "forge-std/Test.sol";
import { IZeroExRouter } from "../src/interfaces/external/0x/IZeroExRouter.sol";
import { Swapper } from "../src/Swapper.sol";

contract SwapperTest is Test {
    Swapper internal immutable swapper;

    address internal constant router = 0xDef1C0ded9bec7F1a1670819833240f027b25EfF;
    IERC20 internal constant usdc = IERC20(0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8);
    IERC20 internal constant usdt = IERC20(0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9);
    address internal constant whale = 0x489ee077994B6658eAfA855C308275EAd8097C4A;
    address internal constant usdcPriceFeed = 0x50834F3163758fcC1Df9973b6e91f0F0F0434aD3;
    address internal constant usdtPriceFeed = 0x3f3f5dF88dC9F13eac63DF89EC16ef6e7E25DdE7;

    string internal constant rpcUrl = "ARBITRUM_RPC_URL";
    uint256 internal constant blockNumber = 64102477;

    constructor() {
        uint256 forkId = vm.createFork(vm.envString(rpcUrl), blockNumber);
        vm.selectFork(forkId);

        swapper = new Swapper(router);
    }

    function setUp() public {
        vm.deal(whale, 1 ether);

        swapper.addPriceFeed(address(usdc), usdcPriceFeed);
        swapper.addPriceFeed(address(usdt), usdtPriceFeed);
    }

    function testSwap() public {
        // test transaction https://arbiscan.io/tx/0x14d06fac99b9753ec001abd96bee151cfe6a6b780a74bc519a49b3d36cf01af7
        uint256 amount = 5208524686;

        vm.prank(whale);
        usdc.transfer(address(this), amount);

        // pack 0x data
        IZeroExRouter.Transformation[] memory transformations = new IZeroExRouter.Transformation[](1);
        transformations[0].deploymentNonce = 19;
        transformations[0]
            .data = "0x00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ff970a61a04b1ca14834a43f5de4533ebddb5cc8000000000000000000000000fd086bc7cd5c481dcc9c85ebe478a1c0b69fcbb9000000000000000000000000000000000000000000000000000000000000014000000000000000000000000000000000000000000000000000000000000002e000000000000000000000000000000000000000000000000000000000000002e000000000000000000000000000000000000000000000000000000000000002a0000000000000000000000000000000000000000000000000000000013673c78e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002e0000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000001443757276655632000000000000000000000000000000000000000000000000000000000000000000000000013673c78e0000000000000000000000000000000000000000000000000000000134d7c5b5000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000800000000000000000000000007f90122bf0700f9e7e1f688fe926940e8839f3533df021240000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
        // solhint-disable-previous-line max-line-length

        transformations[0].deploymentNonce = 16;
        transformations[0]
            .data = "0x0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000002000000000000000000000000ff970a61a04b1ca14834a43f5de4533ebddb5cc8000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000";
        // solhint-disable-previous-line max-line-length

        usdc.approve(address(swapper), amount);
        swapper.swap(address(usdc), address(usdt), amount, 1, abi.encode(transformations));
    }
}
