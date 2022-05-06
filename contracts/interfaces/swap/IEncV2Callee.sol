// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

interface IEncV2Callee {
    function encV2SwapCall(address sender, uint amount0, uint amount1, bytes calldata data) external;
}
