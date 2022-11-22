// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.8.17;

/// @title Multicall interface
/// @notice Enables calling multiple methods in a single call to the contract
/// @dev forked from https://github.com/Uniswap/v3-periphery/blob/main/contracts/base/Multicall.sol
interface IMulticall {
    /// @notice Call multiple functions in the current contract and return the data from all of them if they all succeed
    /// @dev The `msg.value` should not be trusted for any method callable from multicall.
    /// @param data The encoded function data for each of the calls to make to this contract
    /// @return results The results from each of the calls passed in via data
    function multicall(bytes[] calldata data) external payable returns (bytes[] memory results);
}