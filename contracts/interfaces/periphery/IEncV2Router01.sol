
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IEncV2Router01 {
    function multiSwapPool() external view returns(address);
    function WETH() external view returns(address);

    /// @param fromToken0 whether the from token is token0.
    function getAmountIn(
        uint256 poolID,
        uint256 amountOut,
        bool fromToken0
    ) external view returns (
        uint256 amountIn,
        uint256 _reserve0,
        uint256 _reserve1,
        uint256 totalFee
    );

    /// @notice get the amount out if provide amountIn from token.
    /// @param fromToken0 whether the from token is token0.
    function getAmountOut(
        uint256 poolID,
        uint256 amountIn,
        bool fromToken0
    ) external view returns (
        uint256 amountOut,
        uint256 _reserve0,
        uint256 _reserve1,
        uint256 totalFee
    );

    /// @notice swap erc20 token with specified amount in
    function swap(
        uint poolID,
        uint256 amountIn,
        uint256 minAmountOut,
        bool fromToken0,
        address to,
        uint deadline
    ) external returns(bool);

    /// @notice swap eth with specified amount in
    function swapWithETHIn(
        uint poolID,
        uint256 minAmountOut,
        bool fromToken0,
        address to,
        uint deadline
    ) external payable returns(bool);

    /// @notice swap token for eth
    function swapWithETHOut(
        uint poolID,
        uint256 amountIn,
        uint256 minAmountOut,
        bool fromToken0,
        address to,
        uint deadline
    ) external payable returns(bool);

    /// @notice remove liquidity.
    function removeLiquidity(
        uint256 liquidity, 
        uint256 poolID,
        uint deadline) 
    external returns(uint, uint);

    /// @notice remove liquidity and get ETH back.
    function removeLiquidityETH(
        uint256 liquidity, 
        uint256 poolID,
        uint deadline) 
    external returns(uint, uint);

    /// @notice add liquidity.
    function addLiquidity(
        uint poolID, 
        uint256 amount0, 
        uint256 amount1,
        uint deadline) 
    external returns(uint);

    /// @notice add liquidity with eth.
    function addLiquidityETH(
        uint poolID, 
        uint256 amount0, 
        uint256 amount1,
        uint deadline) 
    external payable returns(uint);

    /// @notice get pool reserves and fee rate info.
    function poolAssets(uint pid) external view returns(
        uint120 gReserves0,
        uint120 gReserves1,
        uint256 poolLpAmount,
        uint256 globalLpAmount
    );
}
