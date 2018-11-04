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

pragma solidity ^0.4.0;

// without this, complex returns types won't compile
pragma experimental ABIEncoderV2;

import "./XBRMarket.sol";


contract XBRNetwork {

    address public _network_token;

    address public _network_sponsor;

    address public _dns_oracle;

    struct Agent {
        uint32 public_key;
        string descriptor;
    }

    struct Domain {
        uint256 cookie;
    }
    mapping(string => Domain) _domains;

    struct DomainVerification {
        uint started;
        Domain domain;
    }
    mapping(uint256 => DomainVerification) _domain_verifications;

    /// Create a new network.
    /// @param network_token The token to run this network on.
    /// @param network_sponsor The network technology sponsor.
    /// @param dns_oracle The DNS oracle within the network.
    constructor (address network_token, address network_sponsor, address dns_oracle) public {
        network_token = network_token;
        network_sponsor = network_sponsor;
        dns_oracle = dns_oracle;
    }

    function register_domain(string domain, string descriptor) public returns (uint256) {
    }


    function verify_domain(uint256 domain_cookie, uint8 v, bytes32 r, bytes32 s) public {
    }

    function get_domain(string domain) public returns (Domain) {
    }

    /// Register an XBR agent in a data market.
    /// @param public_key The WAMP-cryptosign (Ed25519) public key of the peer
    /// @param block_number The Ethereum block number from which onwards the association should be established.
    /// @param descriptor The IPFS object content address of the agent descriptor bundle. e.g. `QmarHSr9aSNaPSR6G9KFPbuLV9aEqJfTk1y9B8pdwqK4Rq`.
    function register_agent(bytes32 public_key, uint block_number, string descriptor) public {
    }

    function get_agent(bytes32 public_key) public returns (Agent) {
    }

    function register_market(string domain, string market, string descriptor) public {
    }

    function get_market(string domain, string market) public returns (XBRMarket) {
    }

    function is_signed_by(address signer, bytes32 hash, uint8 v, bytes32 r, bytes32 s) private constant returns (bool) {

        /*
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHash = keccak256(prefix, hash);
        return ecrecover(prefixedHash, v, r, s) == signer;
        */
    }
}
