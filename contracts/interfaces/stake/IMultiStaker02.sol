// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.6;
pragma abicoder v2;
import "./IMultiStaker.sol";

interface IMultiStaker02 is IMultiStaker{
    function stakeWithEth(
        uint256 activityID,
        address account
    ) external payable;

    function addActivityETH(
        CreateActivityParams calldata params
    )external payable returns(
        uint256 activityID
    );

}