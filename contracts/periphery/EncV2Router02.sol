// SPDX-License-Identifier: SimPL-2.0
pragma solidity 0.8.7;

import '../libraries/LowGasSafeMath.sol';
import '../libraries/FullMath.sol';
import '../interfaces/IMultiSwapPool.sol';
import '../interfaces/periphery/IEncV2Router02.sol';
import '../interfaces/periphery/IWETH.sol';
import '../libraries/TransferHelper.sol';
import './EncV2Library.sol';
import './EncV2Router01.sol';

contract EncV2Router02 is EncV2Router01, IEncV2Router02{
    using LowGasSafeMath for uint256;

    constructor(address _multiSwapPool, address _WETH) EncV2Router01(_multiSwapPool, _WETH){
       
    }

    /// @inheritdoc IEncV2Router02
    function getAmountsOut(
        uint256[] memory poolID,
        uint256 amountIn,
        bool[] memory fromToken0
    ) external override view returns (
        uint256 amountOut,
        uint256 totalFee
    )
    {
        uint[] memory amounts;
        (amounts, totalFee) = EncV2Library.getAmountsOut(poolID, amountIn, fromToken0, multiSwapPool);
        amountOut = amounts[amounts.length - 1];
    }

    /// @inheritdoc IEncV2Router02
    function getAmountsIn(
        uint256[] memory poolID,
        uint256 amountOut,
        bool[] memory fromToken0
    ) external override view returns (
        uint256 amountIn,
        uint256 totalFee
    )
    {   
        return EncV2Library.getAmountsIn(poolID, amountOut, fromToken0, multiSwapPool);
    }

    function _swap(
        uint[] memory amounts,
        uint[] memory poolIds,
        bool[] memory fromToken0,
        address[] memory fromTokens,
        address to
    ) internal returns(bool res) {
        for (uint i=0; i < fromTokens.length; i++) {
            if(i > 0){
                TransferHelper.safeTransfer(fromTokens[i], multiSwapPool, amounts[i]);
            }
            address _to = (i == fromTokens.length - 1) ? to : address(this);
            res = IMultiSwapPool(multiSwapPool).swap(poolIds[i], amounts[i + 1], fromToken0[i], _to, new bytes(0));
        }
    }
    
    /// @inheritdoc IEncV2Router02
    function swaps(
        uint[] memory poolID,
        uint256 amountIn,
        uint256 minAmountOut,
        bool[] memory fromToken0,
        address to,
        uint deadline
    ) external override ensure(deadline) returns(bool){
        require(to != address(0), "Invalid to adr");
        require(amountIn > 0 && minAmountOut >= 0, "Amount invalid");
        (uint[] memory amounts, address[] memory fromTokens) = EncV2Library.getAmountsOut2(poolID, amountIn, fromToken0, multiSwapPool);
        require(amounts[amounts.length - 1] >= minAmountOut, "Failed to get minAmountOut");
        TransferHelper.safeTransferFrom(fromTokens[0], msg.sender, multiSwapPool, amounts[0]);
        return _swap(amounts, poolID, fromToken0, fromTokens, to);       
    }
    
    /// @inheritdoc IEncV2Router02
    function swapsWithETHIn(
        uint[] memory poolID,
        uint256 minAmountOut,
        bool[] memory fromToken0,
        address to,
        uint deadline
    ) external override ensure(deadline) payable returns(bool){
        require(to != address(0), "Invalid to adr");
        uint amountIn = msg.value;
        require(amountIn > 0 && minAmountOut >= 0, "Amount invalid");
        (uint[] memory amounts, address[] memory fromTokens) = EncV2Library.getAmountsOut2(poolID, amountIn, fromToken0, multiSwapPool);
        require(amounts[amounts.length - 1] >= minAmountOut, "Failed to get minAmountOut");
        // Transfer token
        {
            require(fromTokens[0] == WETH, "Not ETH.");
            IWETH(WETH).deposit{value: amountIn}();
            TransferHelper.safeTransfer(WETH, multiSwapPool, amountIn);
        }
        return _swap(amounts, poolID, fromToken0, fromTokens, to);
    }

    /// @inheritdoc IEncV2Router02
    function swapsWithETHOut(
        uint[] memory poolID,
        uint256 amountIn,
        uint256 minAmountOut,
        bool[] memory fromToken0,
        address to,
        uint deadline
    ) external override payable ensure(deadline) returns(bool){
        require(to != address(0), "Invalid to adr");
        require(amountIn > 0 && minAmountOut >= 0, "Amount invalid");
        (uint[] memory amounts, address[] memory fromTokens) = EncV2Library.getAmountsOut2(poolID, amountIn, fromToken0, multiSwapPool);
        require(amounts[amounts.length - 1] >= minAmountOut, "Failed to get minAmountOut");
        // Transfer token
        TransferHelper.safeTransferFrom(fromTokens[0], msg.sender, multiSwapPool, amountIn);
        _swap(amounts, poolID, fromToken0, fromTokens, address(this));
        _transferToken(WETH, amounts[amounts.length - 1], to);
        return true;
    }
}
