// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.6;
import '../interfaces/IMultiERC20.sol';
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library TransferHelper {
    function safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferFrom(
        uint256 tid,
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(IMultiERC20.transferFrom.selector, tid, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransfer(
        uint256 tid,
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(IMultiERC20.transfer.selector, tid, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    // Check balance after transfer.So deflationary token is not supported.
    function safeTransferFrom2(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        uint256 balanceBefore = IERC20(token).balanceOf(to);
        
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');

        uint256 balanceAfter = IERC20(token).balanceOf(to);
        require(balanceBefore + value <= balanceAfter, 'No deflationary token');
    }

    function safeTransferFrom3(
        address token,
        address from,
        address to,
        uint256 value
    ) internal returns (uint){
        uint256 balanceBefore = IERC20(token).balanceOf(to);
        
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
        uint256 balanceAfter = IERC20(token).balanceOf(to);
        require(balanceBefore <= balanceAfter, 'No deflationary token');
        return (balanceAfter - balanceBefore);
    }
    
    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }
}