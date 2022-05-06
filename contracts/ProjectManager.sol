// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.7;

import './interfaces/IProjectManager.sol';
import './common/EncToken.sol';
import './libraries/SafeCast.sol';

contract ProjectManager is IProjectManager{
    using SafeCast for uint256;
    uint8 public immutable override PM_ID;
    uint88 public override projectNum;

    constructor(uint8 pm_id) {
        PM_ID = pm_id;
    }
    
    struct ProjectInfo{
        uint96 pid;
        address token;
        address owner;
    }

    mapping(uint => ProjectInfo) public override projects;
    
    /// @notice Check sender is owner of specified project.
    modifier onlyProjectOwner(uint256 pid) {
        ProjectInfo memory info = projects[pid];
        require(info.owner == msg.sender, "Owner only");
        _;
    }

    /// @inheritdoc IProjectManager
    function getProjectOwner(uint256 pid) external override view returns(address){
        ProjectInfo memory info = projects[pid];
        return info.owner;
    }

    /// @inheritdoc IProjectManager
    function transferOwnership(uint256 pid, address newOwner) external override onlyProjectOwner(pid) {
        require(newOwner != address(0), "PM: new owner is the zero address");
        ProjectInfo storage info = projects[pid];
        info.owner = newOwner;
        emit ProjectOwnerChanged(pid,newOwner);
    }
    
    /// @inheritdoc IProjectManager
    function createProject( 
        string memory name_, 
        string memory symbol_, 
        uint amount, 
        address to
    ) external override returns (uint256 projectID) {
        require(to != address(0), "Invald to.");
        address token = address(new EncToken(name_,symbol_,amount,to));
        return _createProject(token,msg.sender);
    }

    function createProject2(
        address projectToken
    )external override returns (uint256 projectID) {
       return _createProject(projectToken, msg.sender);
    }

    function _createProject(address token, address owner) internal returns (uint256 projectID){
        require(token != address(0), "Invald token.");
        // [0-7][8-95]
        projectID = (projectNum << 8) + PM_ID;
        projectNum += 1;
        ProjectInfo storage pro = projects[projectID];

        pro.pid = projectID.toUint96();
        pro.token =  token;
        pro.owner = owner;
        
        emit ProjectCreated(owner, token, projectID);
    }

}
