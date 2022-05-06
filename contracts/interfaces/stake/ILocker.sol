// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.6;
pragma abicoder v2;


interface ILocker {
     /// @notice event emitted when user stakes token
    event StakedEvt(address indexed user, uint256 indexed activityID ,uint256 amount);

    /// @notice event emitted when reward is paid to user.
    event RewardPaidEvt(address indexed user, uint256 indexed activityID ,uint256 amount);

    /// @notice event emitted when user withdraws token
    event WithdrawEvt(address indexed user, uint256 indexed activityID ,uint256 amount);

    /// @notice event emitted when a new activity is created.
    event ActivityAddedEvt(uint256 indexed projectID, uint256 indexed activityID, uint256 rewardAmount, address rewardToken);

    function update(uint activityID, int awardAmount,  uint rewardPerSecond) external;
    function updateETH(uint activityID, int awardAmount,  uint rewardPerSecond) external payable;
    function remainAward(uint activityID) external view returns(uint rewardPaid_, uint remainAward_);

    /// @notice reward of a token staked from the beginning.
    function rewardPerToken(uint activityID) external view returns (uint256);

    /// @notice get the claimable reward of specified account and activity.
    function claimableReward(uint activityID,address account) external view returns(uint256);
    
    /// @notice return user assets amount
    function userAssets(uint activityID, address account) external view returns(
        uint128 amount,
        int128  debt,
        uint128 paid,
        uint128 lastStakeTime
    );
    
    /// @notice return the token needed to be staked
    function stakedTokens(uint activityID) external view returns(
        address token,
        uint88 tid,
        bool isMultiToken,
        bool isChainToken
    );

    /// @notice return activity info of specified activity
    function activities(uint activityID) external view returns(
        uint96  projectID, // Project id of this activity.
        uint32  startTime, // Start time of this activity.
        uint128 penaltyFeeRate, // unit is 1/10000
        
        uint128 rewardPaid,
        uint128 totalStaked, // Amount of token staked in this activity.
        
        uint128 rewardPerSecond, // Reward token in base unit per second.
        uint128 rewardAmount, // Reward amount in base unit.

        uint128 accreward, // Unit is reward token base unit per stored token.
        uint32  lastUpdateTime, // max(last time update acc, start time)
        uint32  lastAddTime, // max(last time add reward, start time)
        uint32  finishTime, // Time when rewards run out.
        uint32  targetFinishTime // Target finish time.
    );

    struct CreateActivityParams{
        uint64  projectID; // Project id of this activity.
        uint32  startTime; // Start time of this activity.
        uint32  targetFinishTime; // Time can withdraw without penalty.
        uint128 penaltyFeeRate;
        
        uint128  rewardAmount; // Reward amount.
        uint rewardPerSecond;

        address staketoken;
        uint88 tid;
        bool isMultiToken;
        bool isChainToken;
    }
    
    /// @notice create a new activity.
    function addActivity(CreateActivityParams calldata params)external returns(uint256 activityID);
    function addActivityETH(CreateActivityParams calldata params)external payable returns(uint256 activityID);


    /// @notice stake token to win award from specified activity.
    function stake(uint256 activityID,uint256 amount,address account) external;
    function stakeWithEth(uint256 activityID,address account) external payable;


    /// @notice withdraw token from specified activity.
    function withdraw(
        address account, 
        uint256 amount, 
        uint256 activityID
    ) external;

    /// @notice claim reward of account from specified activity
    function claimReward(address account, uint256 activityId) external;

    /// @notice withdraw all and claim rewards.
    function exit(address account, uint256 activityId) external;

}
