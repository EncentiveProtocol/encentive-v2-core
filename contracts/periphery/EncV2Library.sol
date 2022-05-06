// SPDX-License-Identifier: SimPL-2.0
pragma solidity 0.8.7;

import '../libraries/LowGasSafeMath.sol';
import '../libraries/FullMath.sol';
import '../interfaces/IMultiSwapPool.sol';

library EncV2Library {
    using LowGasSafeMath for uint256;

    function getAmountOut2(
        uint256 poolID,
        uint256 amountIn,
        bool fromToken0,
        address multiSwapPool
    ) internal view returns (
        uint256 amountOut,
        address fromToken
    )
    {   
        (uint gReserves0, uint gReserves1, address token0, address token1, uint feeRate) = IMultiSwapPool(multiSwapPool).getTradeInfo(poolID);
        fromToken = fromToken0 ? token0 : token1;
        uint totalFee = FullMath.mulDiv(amountIn, feeRate, 10000);
        uint256 amountInWithFee = amountIn.sub(totalFee);

        // Formula is dy = dx_with_fee * y / (x + dx_with_fee)
        if (fromToken0) {
            // Token0 is input token. Token1 is output token.
            amountOut = FullMath.mulDiv(amountInWithFee, gReserves1, gReserves0 + amountInWithFee);
        } else {
            // Token1 is input token. Token0 is output token.
            amountOut = FullMath.mulDiv(amountInWithFee, gReserves0, gReserves1 + amountInWithFee);
        }
    }

    function getAmountOut3(
        uint256 poolID,
        uint256 amountIn,
        bool fromToken0,
        address multiSwapPool
    ) internal view returns (
        uint256 amountOut,
        address fromToken,
        uint totalFee
    )
    {   
        (uint gReserves0, uint gReserves1, address token0, address token1, uint feeRate) = IMultiSwapPool(multiSwapPool).getTradeInfo(poolID);
        fromToken = fromToken0 ? token0 : token1;
        totalFee = FullMath.mulDiv(amountIn, feeRate, 10000);
        uint256 amountInWithFee = amountIn.sub(totalFee);

        // Formula is dy = dx_with_fee * y / (x + dx_with_fee)
        if (fromToken0) {
            // Token0 is input token. Token1 is output token.
            amountOut = FullMath.mulDiv(amountInWithFee, gReserves1, gReserves0 + amountInWithFee);
        } else {
            // Token1 is input token. Token0 is output token.
            amountOut = FullMath.mulDiv(amountInWithFee, gReserves0, gReserves1 + amountInWithFee);
        }
    }

    function getAmountIn(
        uint256 poolID,
        uint256 amountOut,
        bool fromToken0,
        address multiSwapPool
    ) internal view returns(
        uint256 amountIn,
        uint256 totalFee
    ){
        (uint gReserves0, uint gReserves1, , , uint feeRate) = IMultiSwapPool(multiSwapPool).getTradeInfo(poolID);
      
        // Formula is dx_with_fee = x * dy / (y - dy)
        uint256 amountInWithFee;
        if (fromToken0) {
            // Token0 is input token. Token1 is output token.
            amountInWithFee = FullMath.mulDiv(gReserves0, amountOut, gReserves1 - amountOut).add(1);
           
        } else {
            amountInWithFee = FullMath.mulDiv(gReserves1, amountOut, gReserves0 - amountOut).add(1);
        }
        amountIn = FullMath.mulDiv(amountInWithFee, 10000, uint(10000).sub(feeRate)).add(1);
        totalFee = amountIn.sub(amountInWithFee);
    }

    function getAmountsOut(
        uint256[] memory poolID,
        uint256 amountIn,
        bool[] memory fromToken0,
        address multiSwapPool
    ) internal view returns(
        uint[] memory amounts,
        uint totalFee
    ){
        require(fromToken0.length >= 1 && fromToken0.length == poolID.length, "IP");
        amounts = new uint[](poolID.length + 1);
        amounts[0] = amountIn;
        (amounts[1], , totalFee) = getAmountOut3(poolID[0], amounts[0], fromToken0[0], multiSwapPool);
        for (uint i = 1; i < poolID.length; i++) {
            (amounts[i+1], ) = getAmountOut2(poolID[i], amounts[i], fromToken0[i], multiSwapPool);
        }
    }

    function getAmountsOut2(
        uint256[] memory poolID,
        uint256 amountIn,
        bool[] memory fromToken0,
        address multiSwapPool
    ) internal view returns(
        uint[] memory amounts,
        address[] memory fromTokens
    ){
        require(fromToken0.length >= 1 && fromToken0.length == poolID.length, "IP");
        amounts = new uint[](poolID.length + 1);
        fromTokens = new address[](poolID.length);
        amounts[0] = amountIn;
        for (uint i = 0; i < poolID.length; i++) {
            (amounts[i+1], fromTokens[i]) = getAmountOut2(poolID[i], amounts[i], fromToken0[i], multiSwapPool);
        }
    }

    function getAmountsIn(
        uint256[] memory poolID,
        uint256 amountOut,
        bool[] memory fromToken0,
        address multiSwapPool
    ) internal view returns(
        uint amountIn,
        uint totalFee
    ){
        require(fromToken0.length >= 1 && fromToken0.length == poolID.length, 'IP');
        for (uint i = poolID.length - 1; i > 0; i--) {
            (amountOut, ) = getAmountIn(poolID[i], amountOut, fromToken0[i], multiSwapPool);
        }
        (amountIn, totalFee) = getAmountIn(poolID[0], amountOut, fromToken0[0], multiSwapPool);
    }
}
