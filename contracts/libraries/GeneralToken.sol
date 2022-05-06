// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.6;
import './TransferHelper.sol';

library GeneralToken {
    struct Info{
        address token; // 160
        uint88 tid; // token id in multi coin
        bool isMultiToken;
        bool isChainToken;
    }
    
    function transferFrom(
        GeneralToken.Info memory self,
        address from,
        address to,
        uint256 value
    ) internal {
        if (self.isMultiToken){
            TransferHelper.safeTransferFrom(self.tid, self.token, from, to, value);
        }else{
            TransferHelper.safeTransferFrom2(self.token, from, to, value);
        }
    }

    function transferFrom2(
        GeneralToken.Info memory self,
        address from,
        address to,
        uint256 value
    ) internal returns(uint){
        if (self.isMultiToken){
            TransferHelper.safeTransferFrom(self.tid, self.token, from, to, value);
            return value;
        }
        else if(self.isChainToken){
            require(from == msg.sender && to == address(this));
            return msg.value;
        }
        else{
            return TransferHelper.safeTransferFrom3(self.token, from, to, value);
        }
    }

    function transfer(
        GeneralToken.Info memory self,
        address to,
        uint256 value
    ) internal {
        if (self.isMultiToken){
            TransferHelper.safeTransfer(self.tid, self.token, to, value);
        }
        else if(self.isChainToken){
            TransferHelper.safeTransferETH(to, value);
        }
        else{
            TransferHelper.safeTransfer(self.token, to, value);
        }
    }

}