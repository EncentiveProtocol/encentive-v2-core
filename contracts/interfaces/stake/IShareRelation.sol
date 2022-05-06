// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;


interface IShareRelation {
    
    function addShareRelation(uint96 projectId, address userAddress, address inviteeAddress) external returns (bool);

    function userShareRelation(uint96 projectId, address userAddress) external view returns (address);

    function getUserTwoLevelInviteeAddress(uint96 projectId, address userAddress) external view returns (address, address);

    function approve(address whiteadr, bool state) external returns (bool);

    /// @notice event emitted when addShareRelation
    event AddShareRelationEvt(uint96 projectId, address indexed userAddress, address indexed inviteeAddress);
}