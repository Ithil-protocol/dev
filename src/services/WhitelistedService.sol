// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.8.17;

import { Service } from "./Service.sol";
import { IERC20, SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

abstract contract WhitelistedService is Service {
    mapping(address => bool) public whitelisted;
    bool public enabled;

    event WhitelistAccessFlagWasToggled();
    event WhitelistStatusWasChanged(address indexed user, bool status);
    error UserIsNotWhitelisted();

    constructor() {
        enabled = true;
    }

    function toggleWhitelistFlag() external onlyOwner {
        enabled = !enabled;

        emit WhitelistAccessFlagWasToggled();
    }

    function addToWhitelist(address[] calldata users) external onlyOwner {
        uint256 length = users.length;
        for (uint256 i = 0; i < length; i++) {
            whitelisted[users[i]] = true;

            emit WhitelistStatusWasChanged(users[i], true);
        }
    }

    function removeFromWhitelist(address[] calldata users) external onlyOwner {
        uint256 length = users.length;
        for (uint256 i = 0; i < length; i++) {
            delete whitelisted[users[i]];

            emit WhitelistStatusWasChanged(users[i], false);
        }
    }

    function _beforeOpening(Agreement memory agreement, bytes calldata data) internal override {
        if (enabled && !whitelisted[msg.sender]) revert UserIsNotWhitelisted();
    }
}