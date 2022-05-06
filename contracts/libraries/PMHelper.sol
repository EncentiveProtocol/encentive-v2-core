// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.6;
import '../interfaces/IProjectManager.sol';

library PMHelper {
    function getProjOwner(address pm, uint projectId) internal view returns(address){
        return IProjectManager(pm).getProjectOwner(projectId);
    }
}
