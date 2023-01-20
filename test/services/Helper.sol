// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.8.17;

import { IService } from "../../src/interfaces/IService.sol";

library Helper {
    function createSimpleERC20Order(
        address token,
        uint256 amount,
        uint256 margin,
        address collateralToken,
        uint256 collateralAmount,
        uint256 time
    ) public pure returns (IService.Order memory) {
        address[] memory tokens = new address[](1);
        tokens[0] = token;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;
        uint256[] memory margins = new uint256[](1);
        margins[0] = margin;

        address[] memory collateralTokens = new address[](1);
        collateralTokens[0] = collateralToken;
        uint256[] memory collateralAmounts = new uint256[](1);
        collateralAmounts[0] = collateralAmount;
        IService.ItemType[] memory itemTypes = new IService.ItemType[](1);
        itemTypes[0] = IService.ItemType.ERC20;

        return createAdvancedOrder(tokens, amounts, margins, itemTypes, collateralTokens, collateralAmounts, time);
    }

    function createAdvancedOrder(
        address[] memory tokens,
        uint256[] memory amounts,
        uint256[] memory margins,
        IService.ItemType[] memory itemTypes,
        address[] memory collateralTokens,
        uint256[] memory collateralAmounts,
        uint256 time
    ) public pure returns (IService.Order memory) {
        assert(tokens.length == amounts.length && tokens.length == margins.length);

        IService.Loan[] memory loan = new IService.Loan[](tokens.length);
        IService.Collateral[] memory collateral = new IService.Collateral[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            loan[i].token = tokens[i];
            loan[i].amount = amounts[i];
            loan[i].margin = margins[i];

            collateral[i].itemType = itemTypes[i];
            collateral[i].token = collateralTokens[i];
            collateral[i].amount = collateralAmounts[i];
        }

        IService.Agreement memory agreement = IService.Agreement({
            loans: loan,
            collaterals: collateral,
            createdAt: time,
            status: IService.Status.OPEN
        });
        IService.Order memory order = IService.Order({ agreement: agreement, data: "" });

        return order;
    }
}