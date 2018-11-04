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

import "./XBRAdminRole.sol";


/**
 * @title XBR Network root SC
 * @author The XBR Project
 */
contract XBRNetwork is XBRAdminRole {

    /// XBR Network membership levels
    enum MemberLevel { NULL, ACTIVE, VERIFIED, RETIRED, PENALTY, BLOCKED }

    /// Value type for holding XBR Network membership information.
    struct Member {
        bytes32 profile;
        bytes32 eula;
        MemberLevel level;
    }

    /// Address of the XBR Network ERC20 token (XBR for the CrossbarFX technology stack)
    address public network_token;

    /// Address of the `XBR Network Organization <https://xbr.network/>`_
    address public network_organization;
    
    /// Current XBR Network members.
    mapping(address => Member) public members;
    
    /**
     * Create a new network.
     * 
     * @param _network_token The token to run this network on.
     * @param _network_organization The network technology sponsor.
     */
    constructor (address _network_token,
                 address _network_organization) public {
        network_token = _network_token;
        network_organization = _network_organization;
    }
    
    /**
     * Join the XBR Network. All XBR stakeholders, namely XBR Data Providers,
     * XBR Data Consumers, XBR Data Markets and XBR Data Clouds, must register
     * with the XBR Network on the global blockchain by calling this function.
     * 
     * @param profile Optional public member profile: the file hash (SHA2-256)
     *                of the member profile file stored on a well-known location
     *                (suchas as IPFS).
     * @param eula The file hash (SHA2-256) of the XBR Network EULA documents
     *             stored as one ZIP file archive on IPFS.    
     */
    function register (bytes32 profile, bytes32 eula) public {
        require(uint(members[msg.sender].level) == 0, "MEMBER_ALREADY_EXISTS");

        members[msg.sender] = Member(profile, eula, MemberLevel.ACTIVE);
    }
    
    function retire () public {
        require(uint(members[msg.sender].level) != 0, "NO_SUCH_MEMBER");

        members[msg.sender].level = MemberLevel.RETIRED;
    }

    /**
     * Manually override the member level of a XBR Network member. Being able to do so
     * currently serves two purposes:
     * 
     * - having a last resort to handle situation where members violated the EULA
     * - being able to manually patch things in error/bug cases
     */
    function set_member_level (address member, MemberLevel level) public onlyAdmin {
        // only network admins are allowed to override member level
        //require(network_admins.has(msg.sender), "DOES_NOT_HAVE_NETWORK_ADMIN_ROLE");

        members[member].level = level;
    }
}
