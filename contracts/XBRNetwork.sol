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
pragma experimental ABIEncoderV2;

// https://openzeppelin.org/api/docs/math_SafeMath.html
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "./XBRMaintained.sol";
import "./XBRTypes.sol";
import "./XBRToken.sol";


/**
 * @title XBR Network main smart contract.
 * @author The XBR Project
 */
contract XBRNetwork is XBRMaintained {

    // Add safe math functions to uint256 using SafeMath lib from OpenZeppelin
    using SafeMath for uint256;

    // //////// events for MEMBERS

    /// Event emitted when a new member joined the XBR Network.
    event MemberCreated (address indexed member, uint registered, string eula, string profile, XBRTypes.MemberLevel level);

    /// Event emitted when a member leaves the XBR Network.
    event MemberRetired (address member);

    // Note: closing event of payment channels are emitted from XBRChannel (not from here)

    /// Used for EIP712 verification: network ID of the blockchain this contract is running on.
    uint256 public verifyingChain;

    /// Used for EIP712 verification: verifying contract address.
    address public verifyingContract;

    /// XBR network EULA (IPFS Multihash). Source: https://github.com/crossbario/xbr-protocol/tree/master/ipfs/xbr-eula
    string public constant eula = "QmV1eeDextSdUrRUQp9tUXF8SdvVeykaiwYLgrXHHVyULY";

    /// XBR Network ERC20 token (XBR for the CrossbarFX technology stack)
    XBRToken public token;

    /// Address of the `XBR Network Organization <https://xbr.network/>`_
    address public organization;

    /// Current XBR Network members ("member directory").
    mapping(address => XBRTypes.Member) public members;

     /// Create the XBR network.
     ///
     /// @param networkToken The token to run this network itself on. Note that XBR data markets can use
     ///                     any ERC20 token as a means of payment.
     /// @param networkOrganization The XBR network organization.
    constructor (address networkToken, address networkOrganization) public {

        // read chain ID into temp local var (to avoid "TypeError: Only local variables are supported").
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        verifyingChain = chainId;

        verifyingContract = address(this);
        token = XBRToken(networkToken);
        organization = networkOrganization;

        // technically, the creator of the XBR network contract instance is a XBR member (by definition).
        members[msg.sender] = XBRTypes.Member(block.timestamp, "", "", XBRTypes.MemberLevel.VERIFIED, "");
    }

     /// Register the sender of this transaction in the XBR network. All XBR stakeholders, namely XBR data
     /// providers, data consumers and data market operators, must first register with the XBR network.
     ///
     /// @param networkEula The IPFS Multihash of the XBR EULA being agreed to and stored as one ZIP file archive on IPFS.
     /// @param profile Optional public member profile: the IPFS Multihash of the member profile stored in IPFS.
    function register (string memory networkEula, string memory profile) public {
        _register(msg.sender, networkEula, profile, "");
    }

    /**
     * Register sender in the XBR Network. All XBR stakeholders, namely XBR Data Providers,
     * XBR Data Consumers and XBR Data Market Operators, must first register
     * with the XBR Network on the global blockchain by calling this function.
     *
     * IMPORTANT: This version uses pre-signed data where the actual blockchain transaction is
     * submitted by a gateway paying the respective gas (in ETH) for the blockchain transaction.
     *
     * @param member Address of the registering (new) member.
     * @param registered Block number at which the registering member has created the signature.
     * @param eula_ The IPFS Multihash of the XBR EULA being agreed to and stored as one ZIP file archive on IPFS.
     * @param profile_ Optional public member profile: the IPFS Multihash of the member profile stored in IPFS.
     * @param signature EIP712 signature (using private key of member) over
     *                  `(chain_id, contract_adr, register_at, eula_hash, profile_hash)`.
     */
    function registerFor (address member, uint256 registered, string memory eula_,
        string memory profile_, bytes memory signature) public {

        require(XBRTypes.verify(member, XBRTypes.EIP712MemberRegister(verifyingChain, verifyingContract,
            member, registered, eula_, profile_), signature), "INVALID_MEMBER_REGISTER_SIGNATURE");

        _register(member, eula_, profile_, signature);
    }

    function _register (address member_, string memory eula_, string memory profile_, bytes memory signature) private {
        // check that sender is not already a member
        require(uint8(members[member_].level) == 0, "MEMBER_ALREADY_REGISTERED");

        // check that the EULA the member accepted is the one we expect
        require(keccak256(abi.encode(eula_)) ==
                keccak256(abi.encode(eula)), "INVALID_EULA");

        // remember the member
        uint registered = block.timestamp;
        members[member_] = XBRTypes.Member(registered, eula_, profile_, XBRTypes.MemberLevel.ACTIVE, signature);

        // notify observers of new member
        emit MemberCreated(member_, registered, eula_, profile_, XBRTypes.MemberLevel.ACTIVE);
    }

    /**
     * Manually override the member level of a XBR Network member. Being able to do so
     * currently serves two purposes:
     *
     * - having a last resort to handle situation where members violated the EULA
     * - being able to manually patch things in error/bug cases
     *
     * @param member The address of the XBR network member to override member level.
     * @param level The member level to set the member to.
     */
    function setMemberLevel (address member, XBRTypes.MemberLevel level) public onlyMaintainer {
        require(uint(members[msg.sender].level) != 0, "NO_SUCH_MEMBER");

        members[member].level = level;
    }
}
