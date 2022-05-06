// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.6;
pragma abicoder v2;
import "./IMultiStaker02.sol";

interface IAdjustableStake is IMultiStaker02{
     /// @notice event emitted when a new activity is created.
    event ActivityAddedEvt2(uint256 indexed projectID, uint256 indexed activityID, uint flag, uint rewardAmount, address rewardToken);

    function update(uint activityID, int awardAmount, uint rewardRate) external;
    function updateETH(uint activityID, int awardAmount, uint rewardRate) external payable;
    function remainAward(uint activityID) external view returns(uint rewardPaid_, uint remainAward_);
}
