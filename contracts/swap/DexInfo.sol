// SPDX-License-Identifier: GPL-3.0
import './libraries/Oracle.sol';
import '../interfaces/swap/IDexInfo.sol';

pragma solidity 0.8.7;

contract DexInfo is IDexInfo{
    using Oracle for Oracle.Info;
    
    mapping(bytes32 => Oracle.Info) public priceOracle;
    
    /// @notice Used to record pool id
    // swap pool => keccak256(abi.encodePacked(tk0, tk1, projectID) => pool id
    mapping(address => mapping(bytes32 => uint)) public projectPool;

    function recordPool(address token0, address token1, uint projectID, uint poolId) external override{
        bytes32 poolHash = keccak256(abi.encodePacked(token0, token1, projectID));
        require(projectPool[msg.sender][poolHash] == 0,"AE");
        projectPool[msg.sender][poolHash] = poolId;
    }

    function updatePrice(address token0, address token1, uint reserve0, uint reserve1) external override{
        bytes32 pairHash = keccak256(abi.encodePacked(token0, token1, msg.sender));
        priceOracle[pairHash].update(reserve0, reserve1);
    } 

    function getPool(address ctr, address token0, address token1, uint projectId) external override view returns(uint){
        bytes32 poolHash = keccak256(abi.encodePacked(token0, token1, projectId));
        return projectPool[ctr][poolHash];
    }

    function getPrice(address ctr, address token0, address token1) external override view returns (uint,uint){
        bytes32 pairHash = keccak256(abi.encodePacked(token0, token1, ctr));
        Oracle.Info memory _info = priceOracle[pairHash];
        return (_info.price0CumulativeLast, _info.price1CumulativeLast);
    }
}