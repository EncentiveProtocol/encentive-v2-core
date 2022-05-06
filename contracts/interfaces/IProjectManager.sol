// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.6;

interface IProjectManager {
    event ProjectCreated(
        address indexed owner,
        address token,
        uint256 pid
    );

    event ProjectOwnerChanged(
        uint256 indexed pid,
        address indexed owner
    );
    
    /// @notice Id of this contract including version and chainid.
    function PM_ID() external view returns(uint8);
    function projectNum() external view returns(uint88);
    function projects(uint projectID) external view returns(
        uint96 pid,
        address token,
        address projectOwner
    );
    function getProjectOwner(uint256 pid) external view returns(address);

    /// @notice create a project by create new project token.
    function createProject( 
        string memory name_, 
        string memory symbol_, 
        uint amount, 
        address to
    ) external returns (uint256 projectID);

    /// @notice create a project by import an existing token.
    function createProject2(
        address projectToken
    )external returns (uint256 projectID);

    /// @notice transfer ownership of a project
    function transferOwnership(
        uint256 pid, 
        address newOwner
    ) external;
}
