// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import './swap/IMultiSwapPoolInfo.sol';

interface IMultiSwapPool is IMultiSwapPoolInfo{
    /*
        Events
    */

    event SwapEvt(
        address indexed sender,
        address indexed to,
        uint poolId,
        bool fromTk0,
        uint amountIn,
        uint amountOut
    );
    event MintEvt(address indexed to, uint indexed poolId, uint amount0, uint amount1);
    event BurnEvt(address indexed to, uint indexed poolId, uint amount0, uint amount1);
    event PoolAddedEvt(uint indexed projectID, uint poolID, address token0, address token1);
    
    /*
        View functions.
    */


    function getTradeInfo(uint256 poolId) external view returns(
        uint gReserve0, 
        uint gReserve1, 
        address token0,
        address token1,
        uint fee
    );
    
    /*
        Write functions.
    */

    /// @notice add a pool.
    function addPool(
        address tokenA,
        address tokenB,
        uint projectID
    ) external returns(uint poolId);

    /// @notice swap from one token to another. 
    function swap(
        uint poolID,
        uint amountOut, 
        bool fromToken0,
        address to,
        bytes calldata data
    ) external returns(bool);

    /// @notice Add liquidity to the pool.
    function addLiquidity(
        uint poolID, 
        address to) 
    external returns(uint);

    /// @notice Removes liquidity from the pool.
    function removeLiquidity(
        uint256 poolID,
        address to
    ) external  returns(uint, uint);

    /// @notice Allow the dao to claim fee.
    function encDaoClaim(address token,uint amount) external;

    /// @notice change the address of dao.
    function setDaoAdr(address adr) external;

}
