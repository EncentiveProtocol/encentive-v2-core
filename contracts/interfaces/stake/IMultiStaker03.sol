// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.6;
pragma abicoder v2;
import "./IMultiShareStaker.sol";

interface IMultiStaker03 is IMultiShareStaker{
    function stakeWithEth(
        uint256 activityID,
        address account
    ) external payable;

    function addActivityETH(
        CreateShareActivityParams calldata params
    )external payable returns(
        uint256 activityID
    );

}