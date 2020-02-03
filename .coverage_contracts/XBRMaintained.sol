///////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2018-2019 Crossbar.io Technologies GmbH and contributors.
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

pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/access/Roles.sol";


/**
 * XBR Network (and XBR Network Proxies) SCs inherit from this base contract
 * to manage network administration and maintenance via Role-based Access
 * Control (RBAC).
 * The implementation for management comes from the OpenZeppelin RBAC library.
 */
contract XBRMaintained {
function coverage_0x7e051ec3(bytes32 c__0x7e051ec3) public pure {}

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
    constructor () internal {coverage_0x7e051ec3(0x8229ac84cd86e7a116b842396bbb05f99d8d66f66b7b350105cbad0cbc4f08b7); /* function */ 

coverage_0x7e051ec3(0xa4faa95bdcdbcb882e542abaf9c2f17ae300c39a009fb14bc71832ee63bc24a2); /* line */ 
        coverage_0x7e051ec3(0x0bc16c04f378576ee84b59f2d2b74e60d6f723a7907e46e7120e770b70c3d271); /* statement */ 
_addMaintainer(msg.sender);
    }

    /**
     * Modifier to require maintainer-role for the sender when calling a SC.
     */
    modifier onlyMaintainer () {coverage_0x7e051ec3(0x9542d59670946ed42104a5f1e3b3a83bec74daba16318bbf7979c2a1ea042c8e); /* function */ 

coverage_0x7e051ec3(0x656d0ea3a0105fb22c8699ea35e35ca6f1736f2295e731b50f89a3b0b64da34a); /* line */ 
        coverage_0x7e051ec3(0x5dd81afc33785c8965bd009f8581488dd9eebbad50c44ae44dfcc941339b8f40); /* assertPre */ 
coverage_0x7e051ec3(0x29910e06409e66ce5b94cbc49f409429ae6039a97dd9414cbd6b69e571a6182b); /* statement */ 
require(isMaintainer(msg.sender));coverage_0x7e051ec3(0x38c08d769d71e1668bb9654b376135db34c62ecd91ac70ca2d28e426404fef02); /* assertPost */ 

coverage_0x7e051ec3(0xeb2e3279bd3083976e8db9abf9a730d6eb78f522bbf244ae4f976ef57c2b3e56); /* line */ 
        _;
    }

    /**
     * Check if the given address is currently a maintainer.
     *
     * @param account The account to check.
     * @return `true` if the account is maintainer, otherwise `false`.
     */
    function isMaintainer (address account) public view returns (bool) {coverage_0x7e051ec3(0xc05fed5b39ae2e8f8901cc2dabc084a74563eb6093c0ab5c179155e66acf58e3); /* function */ 

coverage_0x7e051ec3(0x624917aa8d702c33aeba19bc68e75d73c00ddd7e9ea80eb07715292fe00b1ee6); /* line */ 
        coverage_0x7e051ec3(0xb3460c6bebe8e05f65ffcdbbf591f84b8a3e0bc2b9eefaaf1f24b4a99b135cbf); /* statement */ 
return maintainers.has(account);
    }

    /**
     * Add a new maintainer to the list of maintainers.
     *
     * @param account The account to grant maintainer rights to.
     */
    function addMaintainer (address account) public onlyMaintainer {coverage_0x7e051ec3(0x736a6de79c0c782daa0b9f3b33075026919ec0fa3c2ab63a4c3d46d17d0abe98); /* function */ 

coverage_0x7e051ec3(0x1d8a8a1b8065435f285c741cdf99b1743438ba13eb17eadcaea199b5b21aceb4); /* line */ 
        coverage_0x7e051ec3(0x5e2577195cab5d69577512c6acc21bdd9ae2d0efc072b211f70f3baabb2c93a4); /* statement */ 
_addMaintainer(account);
    }

    /**
     * Give away maintainer rights.
     */
    function renounceMaintainer () public {coverage_0x7e051ec3(0xcc13edd6340b2a67ff6d21f445b2ed7933476decafafe5f7e2986fa60d0c292a); /* function */ 

coverage_0x7e051ec3(0x302108175d6f506c78f3e8d94632a119d59cb58b29a9de782d4eeabd4b0bc074); /* line */ 
        coverage_0x7e051ec3(0x338a3678bc049bd18492315f111cc93a519e7a8f932d304252311b4bf9c70677); /* statement */ 
_removeMaintainer(msg.sender);
    }

    function _addMaintainer (address account) internal {coverage_0x7e051ec3(0x020788caf5740e1737a30e2a925ff5be624b7e9d397462c65baeb6f720b79686); /* function */ 

coverage_0x7e051ec3(0x1ef90bea47438db1ca48d9d8665197b436a68caffa2e611740a0751f5fdab4ba); /* line */ 
        coverage_0x7e051ec3(0x94d7019d7c54130b32c150d0348bda1107aaf8acd0a8b5b73d950d661fb07f32); /* statement */ 
maintainers.add(account);
coverage_0x7e051ec3(0x81848d4150b6e4a6093ad196c499ce5a8aa08e1265f38a297fa98be91c04b549); /* line */ 
        coverage_0x7e051ec3(0xacbcc5d30b2c7609883505d0414c9cb59a1b281bd06ebdb627551a6783dc6db9); /* statement */ 
emit MaintainerAdded(account);
    }

    function _removeMaintainer (address account) internal {coverage_0x7e051ec3(0x30f1ad0f8b8de3fc67ca63aec415b0e2c41f2305457dc355fff3b5bbf02035be); /* function */ 

coverage_0x7e051ec3(0xabec1d29b2bd3609baaca3842fd2cd39d873c33428c4794c04cfed04900036bf); /* line */ 
        coverage_0x7e051ec3(0xb7231672f7afc21ddeed19c5c6db98b62a7bf3b2b1044508728d3b89e6b1f8fd); /* statement */ 
maintainers.remove(account);
coverage_0x7e051ec3(0xde191ab0c8be757f8ef89caece20f24e9dda768b8ed557298ec9c4574d484319); /* line */ 
        coverage_0x7e051ec3(0x755c4abe42725b66cef7e2c16fe3e823462e35fe63fdd123ce157f3ec5f4d495); /* statement */ 
emit MaintainerRemoved(account);
    }
}
