// SPDX-License-Identifier: SimPL-2.0
pragma solidity 0.8.7;

import '../libraries/LowGasSafeMath.sol';
import '../libraries/FullMath.sol';
import '../interfaces/IMultiSwapPool.sol';
import '../interfaces/periphery/IEncV2Router01.sol';
import '../interfaces/periphery/IWETH.sol';
import '../libraries/TransferHelper.sol';
import './EncV2Library.sol';

contract EncV2Router01 is IEncV2Router01{
    using LowGasSafeMath for uint256;

    /// @inheritdoc IEncV2Router01
    address public immutable override multiSwapPool;
    /// @inheritdoc IEncV2Router01
    address public immutable override WETH;

    constructor(address _multiSwapPool, address _WETH) {
        multiSwapPool = _multiSwapPool;
        WETH = _WETH;
    }

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'EXPIRED');
        _;
    }

    /// @inheritdoc IEncV2Router01
    function getAmountOut(
        uint256 poolID,
        uint256 amountIn,
        bool fromToken0
    ) external override view returns (
        uint256 amountOut,
        uint256 _reserve0,
        uint256 _reserve1,
        uint256 totalFee
    )
    {
        (amountOut, _reserve0, _reserve1, totalFee,) = _getAmountOut(poolID, amountIn, fromToken0);
    }

    /// @inheritdoc IEncV2Router01
    function getAmountIn(
        uint256 poolID,
        uint256 amountOut,
        bool fromToken0
    ) external override view returns (
        uint256 amountIn,
        uint256 _reserve0,
        uint256 _reserve1,
        uint256 totalFee
    )
    {   
        (uint gReserves0, uint gReserves1, , , uint feeRate) = IMultiSwapPool(multiSwapPool).getTradeInfo(poolID);
        return _getAmountIn(gReserves0, gReserves1, feeRate, amountOut, fromToken0);
    }

    function _getAmountIn(
        uint256 gReserves0,
        uint256 gReserves1,
        uint256 feeRate,
        uint256 amountOut,
        bool fromToken0
    ) internal pure returns(
        uint256 amountIn,
        uint256 _reserve0,
        uint256 _reserve1,
        uint256 totalFee
    ){
        // Formula is dx_with_fee = x * dy / (y - dy)
        uint256 amountInWithFee;
        if (fromToken0) {
            // Token0 is input token. Token1 is output token.
            amountInWithFee = FullMath.mulDiv(gReserves0, amountOut, gReserves1 - amountOut).add(1);
            _reserve0 = uint256(gReserves0).add(amountIn);
            _reserve1 = uint256(gReserves1).sub(amountOut);
        } else {
            amountInWithFee = FullMath.mulDiv(gReserves1, amountOut, gReserves0 - amountOut).add(1);
            _reserve1 = uint256(gReserves1).add(amountIn);
            _reserve0 = uint256(gReserves0).sub(amountOut);
        }
        amountIn = FullMath.mulDiv(amountInWithFee, 10000, uint(10000).sub(feeRate)).add(1);
        totalFee = amountIn.sub(amountInWithFee);
    }

    function _getAmountOut(
        uint256 poolID,
        uint256 amountIn,
        bool fromToken0
    ) internal view returns (
        uint256 amountOut,
        uint256 _reserve0,
        uint256 _reserve1,
        uint256 totalFee,
        address fromToken
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
            _reserve0 = uint256(gReserves0).add(amountIn);
            _reserve1 = uint256(gReserves1).sub(amountOut);
        } else {
            // Token1 is input token. Token0 is output token.
            amountOut = FullMath.mulDiv(amountInWithFee, gReserves0, gReserves1 + amountInWithFee);
            _reserve1 = uint256(gReserves1).add(amountIn);
            _reserve0 = uint256(gReserves0).sub(amountOut);
        }
    }

    /// @inheritdoc IEncV2Router01
    function swap(
        uint poolID,
        uint256 amountIn,
        uint256 minAmountOut,
        bool fromToken0,
        address to,
        uint deadline
    ) external override ensure(deadline) returns(bool){
        require(to != address(0), "Invalid to adr");
        require(amountIn > 0 && minAmountOut >= 0, "Amount invalid");
        (uint256 amountOut, address fromToken) = EncV2Library.getAmountOut2(poolID, amountIn, fromToken0, multiSwapPool);
        require(amountOut >= minAmountOut, "Failed to get minAmountOut");
       
        TransferHelper.safeTransferFrom(fromToken, msg.sender, multiSwapPool, amountIn);
        return IMultiSwapPool(multiSwapPool).swap(poolID, amountOut, fromToken0, to, new bytes(0));
    }
    
    /// @inheritdoc IEncV2Router01
    function swapWithETHIn(
        uint poolID,
        uint256 minAmountOut,
        bool fromToken0,
        address to,
        uint deadline
    ) external override ensure(deadline) payable returns(bool){
        require(to != address(0), "Invalid to adr");
        uint amountIn = msg.value;
        require(amountIn > 0 && minAmountOut >= 0, "Amount invalid");
        (uint256 amountOut, address fromToken) = EncV2Library.getAmountOut2(poolID, amountIn, fromToken0, multiSwapPool);
        require(amountOut >= minAmountOut, "Failed to get minAmountOut");
        // Transfer token
        {
            require(fromToken == WETH, "Not ETH.");
            IWETH(WETH).deposit{value: amountIn}();
            TransferHelper.safeTransfer(WETH, multiSwapPool, amountIn);
        }
        return IMultiSwapPool(multiSwapPool).swap(poolID, amountOut, fromToken0, to, new bytes(0));
    }

    /// @inheritdoc IEncV2Router01
    function swapWithETHOut(
        uint poolID,
        uint256 amountIn,
        uint256 minAmountOut,
        bool fromToken0,
        address to,
        uint deadline
    ) external override payable ensure(deadline) returns(bool){
        require(to != address(0), "Invalid to adr");
        require(amountIn > 0 && minAmountOut >= 0, "Amount invalid");
        (uint256 amountOut, address fromToken) = EncV2Library.getAmountOut2(poolID, amountIn, fromToken0, multiSwapPool);
        require(amountOut >= minAmountOut, "Failed to get minAmountOut");
        // Transfer token
        TransferHelper.safeTransferFrom(fromToken, msg.sender, multiSwapPool, amountIn);
        IMultiSwapPool(multiSwapPool).swap(poolID, amountOut, fromToken0, address(this), new bytes(0));
        _transferToken(WETH, amountOut, to);
        return true;
    }

    function _getFinalLiquidityAmount(
        uint256 reserves0,
        uint256 reserves1,
        uint256 amount0, 
        uint256 amount1
    )internal pure returns(uint256 _amount0, uint256 _amount1)
    {
        if(reserves0 == 0 && reserves1 == 0){
            return (amount0, amount1);
        }
        uint amount_1 = FullMath.mulDiv(amount0, reserves1, reserves0);
        if(amount_1 <= amount1){
            return (amount0, amount_1);
        }else{
            return (FullMath.mulDiv(amount1, reserves0, reserves1), amount1);
        }
    }
    
    /// @inheritdoc IEncV2Router01
    function addLiquidity(
        uint poolID, 
        uint256 amount0, 
        uint256 amount1,
        uint deadline) 
    external override ensure(deadline) returns(uint) {
        (uint gReserves0, uint gReserves1, address token0, address token1, ) = IMultiSwapPool(multiSwapPool).getTradeInfo(poolID);
        (uint256 _amount0, uint256 _amount1) = _getFinalLiquidityAmount(gReserves0, gReserves1, amount0, amount1);
      
        // Transfer token
        TransferHelper.safeTransferFrom(token0, msg.sender, multiSwapPool, _amount0);
        TransferHelper.safeTransferFrom(token1, msg.sender, multiSwapPool, _amount1);
        return IMultiSwapPool(multiSwapPool).addLiquidity(poolID, msg.sender);
    }

    /// @inheritdoc IEncV2Router01
    function removeLiquidity(
        uint256 liquidity, 
        uint256 poolID,
        uint deadline) 
    external override ensure(deadline) returns(uint, uint){
        TransferHelper.safeTransferFrom(poolID, multiSwapPool, msg.sender, multiSwapPool, liquidity);
        return IMultiSwapPool(multiSwapPool).removeLiquidity(poolID, msg.sender);
    }

    /// @notice remove liquidity and get ETH back.
    function removeLiquidityETH(
        uint256 liquidity, 
        uint256 poolID,
        uint deadline) 
    external override ensure(deadline) returns(uint, uint){
        TransferHelper.safeTransferFrom(poolID, multiSwapPool, msg.sender, multiSwapPool, liquidity);
        (uint amount0, uint amount1) = IMultiSwapPool(multiSwapPool).removeLiquidity(poolID, address(this));
        (address token0,,address token1) = IMultiSwapPool(multiSwapPool).poolInfos(poolID);
        _transferToken(token0, amount0, msg.sender);
        _transferToken(token1, amount1, msg.sender);
        return (amount0, amount1);
    }

    /// @notice remove liquidity and get ETH back.
    function addLiquidityETH(
        uint poolID, 
        uint256 amount0, 
        uint256 amount1,
        uint deadline) 
    external override payable ensure(deadline) returns(uint){
        // Calculate amount
        uint ethAmount;
        {
            (uint gReserves0, uint gReserves1, address token0, address token1, ) = IMultiSwapPool(multiSwapPool).getTradeInfo(poolID);
            (uint256 _amount0, uint256 _amount1) = _getFinalLiquidityAmount(gReserves0, gReserves1, amount0, amount1);
            if(token0 == WETH){
                ethAmount = _amount0;
                TransferHelper.safeTransferFrom(token1, msg.sender, multiSwapPool, _amount1);
            }else{
                require(token1 == WETH, "Not WETH.");
                ethAmount = _amount1;
                TransferHelper.safeTransferFrom(token0, msg.sender, multiSwapPool, _amount0);
            }
            require(msg.value >= ethAmount, "Not enough eth.");
            if(msg.value > ethAmount){
                TransferHelper.safeTransferETH(msg.sender, msg.value.sub(ethAmount));
            }
        }
        
        IWETH(WETH).deposit{value: ethAmount}();
        TransferHelper.safeTransfer(WETH, multiSwapPool, ethAmount);
        return IMultiSwapPool(multiSwapPool).addLiquidity(poolID, msg.sender);
    }

    function _transferToken(address token, uint amount, address to) internal{
        if(token == WETH){
            IWETH(WETH).withdraw(amount);
            TransferHelper.safeTransferETH(to, amount);
        }else{
            TransferHelper.safeTransfer(token, to, amount);
        }
    }

    /// @inheritdoc IEncV2Router01
    function poolAssets(uint pid) external override view returns(
        uint120 gReserves0,
        uint120 gReserves1,
        uint256 poolLpAmount,
        uint256 globalLpAmount
    ){
        (address token0,,address token1) = IMultiSwapPool(multiSwapPool).poolInfos(pid);
        (globalLpAmount, gReserves0, gReserves1,) = IMultiSwapPool(multiSwapPool).getGlobalReserve(token0, token1);
        poolLpAmount = IMultiERC20(multiSwapPool).totalSupply(pid);
    }

    // Allow this contract to receive platfrom token(ETH/BNB)
    receive() external payable {}
    fallback() external payable {}
}
