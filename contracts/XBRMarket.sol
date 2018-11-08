///////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2018 Crossbar.io Technologies GmbH and contributors.
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

pragma solidity ^0.4.24;

import 'openzeppelin-solidity/contracts/lifecycle/Pausable.sol';


contract XBRMarket {

    /// Value type for holding XBR Market information.
    struct Market {
        address owner;
        bytes32 terms;
    }

    /// Address of the XBR Network
    address public network;

    /// Current XBR Markets
    mapping(bytes32 => Market) public markets;


    constructor (address _network) public {
        network = _network;
    }
    
    function register (bytes32 terms) public {

        // generate new market_id
        bytes32 market_id = keccak256(abi.encodePacked(msg.sender, blockhash(block.number - 1)));

        // FIXME: gracefully handle multiple market registrations from one user within one block!
        require(markets[market_id].owner != address(0), "MARKET_ALREADY_EXISTS");

        markets[market_id] = Market(msg.sender, terms);
    }

/*
    function register_api (string domain, string name, string descriptor) public returns (uint256) {
    }

    function register_service (bytes32 public_key, string prefix, uint256[] implements, uint256[] provides) public {
    }
*/    
}
