// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.6;
pragma abicoder v2;

interface IMultiStaker {
    
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

    /// @notice return activity info of specified activity
    function activities(uint activityID) external view returns(
        address rewardToken, // Address of reward token.
        uint32  startTime, // Start time of this activity.
        uint32  lastingTime, // How long is this activity.
        uint32  lastUpdateTime,

        uint32  finishTime, // Finish time of this activity.
        uint128  rewardRate, // Reward token in base unit per second.
        uint96  projectID, // Project id of this activity.

        uint256  accreward, // Unit is reward token base unit per stored token.

        uint128  rewardAmount, // Reward amount in base unit.
        uint128  totalStaked // Amount of token staked in this activity.
    );

    struct CreateActivityParams{
        uint96  projectID; // Project id of this activity.
        uint32  startTime; // Start time of this activity.
        uint32  lastingTime; // How long is this activity.
        uint96  rewardAmount; // Reward amount.

        address staketoken;
        uint88 tid;
        bool isMultiToken;
        bool isChainToken;

        address rewardToken; // Address of reward token.
        uint96  flag;
    }
    
    /// @notice create a new activity.
    function addActivity(
        CreateActivityParams calldata params
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
