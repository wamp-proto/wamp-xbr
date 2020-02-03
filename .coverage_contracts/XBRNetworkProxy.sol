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

import "./XBRMaintained.sol";


/**
 * @title XBR Network root SC
 * @author The XBR Project
 */
contract XBRNetworkProxy is XBRMaintained {
function coverage_0x5f90d532(bytes32 c__0x5f90d532) public pure {}


    address internal _networkContract;

    function setNetworkContract (address networkContract) public onlyMaintainer {coverage_0x5f90d532(0xc67b4e7c5d4fd73fd8cd951877cbb859ea395245776d03e0044237e4b97b7612); /* function */ 

coverage_0x5f90d532(0x1b5dbbe12256d984f4a3a409caad642cd5149240445be9f40460c5c5b1e5cd06); /* line */ 
        coverage_0x5f90d532(0x5d258908643e35761a5f60a6491e04a53f792e3556f7667eb2230492ac7f34c7); /* statement */ 
_networkContract = networkContract;
    }
}
