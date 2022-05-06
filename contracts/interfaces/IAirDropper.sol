// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.7;

interface IAirDropper{
    event ClaimEvt(address indexed user, uint256 indexed activityID ,uint256 amount);
    event AddActivityEvt(uint256 indexed projectID, uint256 activityID, address token, bytes32 root, uint256 endTime);

    function activitiyInfos(uint256 activityID) external view returns(
        uint96  projectID, // Project id of this activity.
        address rewardToken, // Address of reward token.
        bytes32 merkleRoot,
        uint32  endTime
    );

    function activityAssets(uint256 activityID) external view returns(
        uint128  totalSupplied, // Amount of token supplied.
        uint128  totalClaimed // Amount of token claimed by user.
    );

    function userClaimed(uint256 activityID, address adr) external view returns(bool);

    function createDropActivity(
        uint96  projectID,
        address rewardToken,
        uint32  endTime,
        uint256 amount,
        bytes32 merkleRoot
    )external  returns(
        uint256 activityID
    );

    function claimTokens(uint256 activityID, uint256 amount, bytes32[] calldata merkleProof) external;
}