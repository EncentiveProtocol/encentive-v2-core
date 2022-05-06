// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IMultiSwapPoolInfo {
    

    /// @notice get pool infomation
    function poolInfos(uint pid) external view returns(
        address token0,  // First erc20 token. 
        uint96 projectID, // Project id of this pool
        address token1   // Second erc20 token. 
    );

    /// @notice address of project manager
    function projectManager() external view returns(address);

    function getGlobalReserve(address token0, address token1) external view returns(
        uint256 totalSupply,
        uint120 reserves0,
        uint120 reserves1,
        uint16  flag
    );
}