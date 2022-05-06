// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./IEncV2Router01.sol";

interface IEncV2Router02 is IEncV2Router01{
    /// @param fromToken0 whether the from token is token0.
    function getAmountsIn(
        uint256[] memory poolID,
        uint256 amountOut,
        bool[] memory fromToken0
    ) external view returns (
        uint256 amountIn,
        uint256 totalFee
    );

    /// @notice get the amount out if provide amountIn from token.
    /// @param fromToken0 whether the from token is token0.
    function getAmountsOut(
        uint256[] memory poolID,
        uint256 amountIn,
        bool[] memory fromToken0
    ) external  view returns (
        uint256 amountOut,
        uint256 totalFee
    );

    /// @notice swap erc20 token with specified amount in
    function swaps(
        uint[] memory poolID,
        uint256 amountIn,
        uint256 minAmountOut,
        bool[] memory fromToken0,
        address to,
        uint deadline
    ) external returns(bool);

    /// @notice swap eth with specified amount in
    function swapsWithETHIn(
        uint[] memory poolID,
        uint256 minAmountOut,
        bool[] memory fromToken0,
        address to,
        uint deadline
    ) external payable returns(bool);

    /// @notice swap token for eth
    function swapsWithETHOut(
        uint[] memory poolID,
        uint256 amountIn,
        uint256 minAmountOut,
        bool[] memory fromToken0,
        address to,
        uint deadline
    ) external payable returns(bool);
}
