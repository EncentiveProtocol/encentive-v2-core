// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

interface IDexInfo {
    function recordPool(address token0, address token1, uint projectID, uint poolId) external;
    function updatePrice(address token0, address token1, uint reserve0, uint reserve1) external;
    function getPool(address ctr, address token0, address token1, uint projectId) external view returns(uint);
    function getPrice(address ctr, address token0, address token1) external view returns (uint,uint);

}