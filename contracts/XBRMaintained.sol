///////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2018-2020 Crossbar.io Technologies GmbH and contributors.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
///////////////////////////////////////////////////////////////////////////////

pragma solidity ^0.5.12;

import "openzeppelin-solidity/contracts/access/Roles.sol";


/**
 * XBR Network (and XBR Network Proxies) SCs inherit from this base contract
 * to manage network administration and maintenance via Role-based Access
 * Control (RBAC).
 * The implementation for management comes from the OpenZeppelin RBAC library.
 */
contract XBRMaintained {
    /// OpenZeppelin RBAC mixin.
    using Roles for Roles.Role;

    /**
     * Event fired when a maintainer was added.
     *
     * @param account The account that was added as a maintainer.
     */
    event MaintainerAdded(address indexed account);

    /**
     * Event fired when a maintainer was removed.
     *
     * @param account The account that was removed as a maintainer.
     */
    event MaintainerRemoved(address indexed account);

    /// Current list of XBR network maintainers.
    Roles.Role private maintainers;

    /// The constructor is internal (roles are managed by the OpenZeppelin base class).
    constructor () internal {
        _addMaintainer(msg.sender);
    }

    /**
     * Modifier to require maintainer-role for the sender when calling a SC.
     */
    modifier onlyMaintainer () {
        require(isMaintainer(msg.sender));
        _;
    }

    /**
     * Check if the given address is currently a maintainer.
     *
     * @param account The account to check.
     * @return `true` if the account is maintainer, otherwise `false`.
     */
    function isMaintainer (address account) public view returns (bool) {
        return maintainers.has(account);
    }

    /**
     * Add a new maintainer to the list of maintainers.
     *
     * @param account The account to grant maintainer rights to.
     */
    function addMaintainer (address account) public onlyMaintainer {
        _addMaintainer(account);
    }

    /**
     * Give away maintainer rights.
     */
    function renounceMaintainer () public {
        _removeMaintainer(msg.sender);
    }

    function _addMaintainer (address account) internal {
        maintainers.add(account);
        emit MaintainerAdded(account);
    }

    function _removeMaintainer (address account) internal {
        maintainers.remove(account);
        emit MaintainerRemoved(account);
    }
}
