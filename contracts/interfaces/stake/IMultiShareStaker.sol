// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.6;
pragma abicoder v2;

interface IMultiShareStaker {
    
    /// @notice event emitted when user stakes token
    event StakedEvt(address indexed user, uint256 indexed activityID ,uint256 amount);

    /// @notice event emitted when reward is paid to user.
    event RewardPaidEvt(address indexed user, uint256 indexed activityID ,uint256 amount);

    /// @notice event emitted when user withdraws token
    event WithdrawEvt(address indexed user, uint256 indexed activityID ,uint256 amount);

    /// @notice event emitted when a new activity is created.
    event ActivityAddedEvt(uint256 indexed projectID, uint256 indexed activityID, uint256 rewardAmount, address rewardToken);

    /// @notice reward of a token staked from the beginning.
    function rewardPerToken(uint activityID) external view returns (uint256);

    /// @notice get the claimable reward of specified account and activity.
    function claimableReward(
        uint activityID,
        address account
    ) external view returns(uint256);
    
    /// @notice return user assets amount
    function userAssets(uint activityID, address account) external view returns(
        uint128 amount,
        uint128 userDirectShareAmount,
        uint128 userIndirectShareAmount,
        int128  debt,
        uint256 paid
    );
    
    /// @notice return the token needed to be staked
    function stakedTokens(uint activityID) external view returns(
        address token,
        uint88 tid,
        bool isMultiToken,
        bool isChainToken
    );

    /// @notice return activity info of specified shareactivity
    function shareActivities(uint activityID) external view returns(
        uint32  startTime, // Start time of this activity.
        uint32  lastingTime, // How long is this activity.
        uint32  lastUpdateTime,
        uint32  finishTime, // Finish time of this activity.
        uint128 rewardRate, // Reward token in base unit per second.

        address rewardToken, // Address of reward token.
        uint64  projectID, // Project id of this activity.
        uint16  directShareRewardRate, // user Direct share stake rewordrate
        uint16  indirectShareRewardRate, // user Indirect share stake rewordrate

        uint256  accreward, // Unit is reward token base unit per stored token.

        uint128  rewardAmount, // Reward amount in base unit.
        uint128  totalStaked // Amount of token staked in this activity.
    );

    struct CreateShareActivityParams{
        uint64  projectID; // Project id of this activity.
        uint32  startTime; // Start time of this activity.
        uint32  lastingTime; // How long is this activity.
        uint96  rewardAmount; // Reward amount.
        uint16  directShareRewardRate; // user direct share stake rewordrate
        uint16  indirectShareRewardRate; // user indirect share stake rewordrate

        address staketoken;
        uint88 tid;
        bool isMultiToken;
        bool isChainToken;

        address rewardToken; // Address of reward token.
        uint96  flag;
    }
    
    /// @notice create a new activity.
    function addActivity(
        CreateShareActivityParams calldata params
    )external returns(
        uint256 activityID
    );

    /// @notice stake token to win award from specified activity.
    function stake(
        uint256 activityID,
        uint256 amount,
        address account
    )external;

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
