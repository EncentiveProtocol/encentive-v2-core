// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.6;

interface IMultiERC20 {
    event Approval(uint indexed tid, address indexed owner, address indexed spender, uint value);
    event Transfer(uint indexed tid, address indexed from, address indexed to, uint value);

    function totalSupply(uint tid) external view returns (uint);

    function balanceOf(uint tid, address owner) external view returns (uint);
    function allowance(uint tid, address owner, address spender) external view returns (uint);

    function approve(uint tid, address owner, address spender, uint value) external;
    function transfer(uint tid, address to, uint value) external returns (bool);
    function transferFrom(uint tid, address from, address to, uint value) external returns (bool);
}
