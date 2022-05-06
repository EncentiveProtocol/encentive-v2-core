// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.7;
import './interfaces/IAirDropper.sol';
import './libraries/LowGasSafeMath.sol';
import './libraries/TransferHelper.sol';
import './libraries/SafeCast.sol';
import './libraries/FullMath.sol';
import './interfaces/IProjectManager.sol';
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract AirDropper is IAirDropper{

    using LowGasSafeMath for uint256;
    using LowGasSafeMath for int256;
    using SafeCast for uint256;
    using SafeCast for int256;

    struct DropActivity{
        uint96  projectID; // Project id of this activity.
        address rewardToken; // Address of reward token.
        bytes32 merkleRoot;
        uint32  endTime; // End time of this activity.
    }

    struct ActivityAssets{
        uint128  totalSupplied; // Amount of token supplied.
        uint128  totalClaimed; // Amount of token claimed by user.
    }

    uint256 public activityNum;
    /// @inheritdoc IAirDropper
    mapping(uint => ActivityAssets) public override activityAssets;
    /// @inheritdoc IAirDropper
    mapping(uint => DropActivity) public override activitiyInfos;
    
    address public projectManager;
    
    mapping(uint => mapping(address => bool)) public override userClaimed;

    function updateAssets(
        uint256 activityID,
        uint256 amountAdded
    ) external {
        DropActivity memory _activity = activitiyInfos[activityID];
        require(IProjectManager(projectManager).getProjectOwner(_activity.projectID) == msg.sender, "Owner only");
        TransferHelper.safeTransferFrom(_activity.rewardToken, msg.sender, address(this), amountAdded);
        ActivityAssets storage asset = activityAssets[activityID];
        ActivityAssets memory _asset = asset;
        asset.totalSupplied = amountAdded.add(_asset.totalSupplied).toUint128();
    }

    function updateMerkleRoot(uint256 activityID, bytes32 merkleRoot) external {
        DropActivity storage activity = activitiyInfos[activityID];
        DropActivity memory _activity = activity;
        require(IProjectManager(projectManager).getProjectOwner(_activity.projectID) == msg.sender, "Owner only");
        activity.merkleRoot = merkleRoot;
    }

    /// @inheritdoc IAirDropper
    function createDropActivity(
        uint96  projectID,
        address rewardToken,
        uint32  endTime,
        uint256 amount,
        bytes32 merkleRoot
    )external override returns(
        uint256 activityID
    ){
        require(IProjectManager(projectManager).getProjectOwner(projectID) == msg.sender, "Owner only");
        activityID = activityNum;
        activityNum += 1;

        DropActivity storage activity = activitiyInfos[activityID];
        (activity.projectID, activity.rewardToken, activity.merkleRoot, activity.endTime) = (
            projectID,
            rewardToken,
            merkleRoot,
            endTime
        );

        TransferHelper.safeTransferFrom(rewardToken, msg.sender, address(this), amount);
        ActivityAssets storage asset = activityAssets[activityID];
        (asset.totalSupplied, asset.totalClaimed) = (amount.toUint128(), 0);
        emit AddActivityEvt(projectID, activityID, rewardToken, merkleRoot, endTime);
    }

    /// @inheritdoc IAirDropper
    function claimTokens(uint256 activityID, uint256 amount, bytes32[] calldata merkleProof) external override {
        DropActivity memory _activity = activitiyInfos[activityID];
        require(!userClaimed[activityID][msg.sender], "Already Claimed.");
        require(block.timestamp <= _activity.endTime, "Ended.");

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, amount));
        bool valid = MerkleProof.verify(merkleProof, _activity.merkleRoot, leaf);
        require(valid, "Proof Invalid");
        userClaimed[activityID][msg.sender] = true;
        TransferHelper.safeTransfer(_activity.rewardToken, msg.sender, amount);
        ActivityAssets storage asset = activityAssets[activityID];
        ActivityAssets memory _asset = asset;
        require(_asset.totalClaimed + amount <= _asset.totalSupplied, "Insufficient Balance");
        asset.totalClaimed = amount.add(_asset.totalClaimed).toUint128();
        emit ClaimEvt(msg.sender, activityID, amount);
    }

    function withDraw(uint256 activityID, address to) external {
        DropActivity memory _activity = activitiyInfos[activityID];
        require(IProjectManager(projectManager).getProjectOwner(_activity.projectID) == msg.sender, "Owner only");
        require(block.timestamp > _activity.endTime, "Not Ended.");

        ActivityAssets storage asset = activityAssets[activityID];
        ActivityAssets memory _asset = asset;
        uint256 paid = uint256(_asset.totalSupplied).sub(_asset.totalClaimed);
        asset.totalClaimed = _asset.totalSupplied;

        TransferHelper.safeTransfer(_activity.rewardToken, to, paid);
        emit ClaimEvt(to, activityID, paid);
    }

    constructor(address projectManager_)  {
        require(projectManager_ != address(0), "Invalid PM");
        projectManager = projectManager_;
    }
}
