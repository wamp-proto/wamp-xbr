// SPDX-License-Identifier: Apache-2.0

///////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2018-2021 Crossbar.io Technologies GmbH and contributors.
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

pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

// https://openzeppelin.org/api/docs/math_SafeMath.html
// import "openzeppelin-solidity/contracts/math/SafeMath.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";

import "./XBRMaintained.sol";
import "./XBRTypes.sol";
import "./XBRToken.sol";


/**
 * The `XBR Network <https://github.com/crossbario/xbr-protocol/blob/master/contracts/XBRNetwork.sol>`__
 * contract is the on-chain anchor of and the entry point to the XBR protocol.
 */
contract XBRNetwork is XBRMaintained {

    // Add safe math functions to uint256 using SafeMath lib from OpenZeppelin
    using SafeMath for uint256;

    /// Event emitted when a new member registered in the XBR Network.
    event MemberRegistered (address indexed member, uint registered, string eula, string profile, XBRTypes.MemberLevel level);

    /// Event emitted when an existing member is changed (without leaving the XBR Network).
    event MemberChanged (address indexed member, uint changed, string eula, string profile, XBRTypes.MemberLevel level);

    /// Event emitted when a member leaves the XBR Network.
    event MemberRetired (address member, uint retired);

    /// Event emitted when the payable status of a coin is changed.
    event CoinChanged (address indexed coin, address operator, bool isPayable);

    /// Special addresses used as "any address" marker in mappings (eg coins).
    address public constant ANYADR = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;

    /// Limit to how old a pre-signed transaction is accetable (eg in "registerMemberFor" and similar).
    uint256 public PRESIGNED_TXN_MAX_AGE = 1440;

    /// Chain ID of the blockchain this contract is running on, used in EIP712 typed data signature verification.
    uint256 public verifyingChain;

    /// Verifying contract address, used in EIP712 typed data signature verification.
    address public verifyingContract;

    /// IPFS multihash of the `XBR Network EULA <https://github.com/crossbario/xbr-protocol/blob/master/EULA>`__.
    string public eula = "QmUEM5UuSUMeET2Zo8YQtDMK74Fr2SJGEyTokSYzT3uD94";

    /// XBR network contributions from markets for the XBR project, expressed as a fraction of the total amount of XBR tokens.
    uint256 public contribution;

    /// Address of the XBR Networks' own ERC20 token for network-wide purposes.
    XBRToken public token;

    /// Address of the `XBR Network Organization <https://xbr.network/>`__.
    address public organization;

    /// Current XBR Network members ("member directory").
    mapping(address => XBRTypes.Member) public members;

    /// ERC20 coins which can specified as a means of payment when creating a new data market.
    mapping(address => mapping(address => bool)) public coins;

    /// Create the XBR network.
    ///
    /// @param networkToken The token to run this network itself on. Note that XBR data markets can use
    ///                     any ERC20 token (enabled in the ``coins`` mapping of this contract) as
    ///                     a means of payment in the respective market.
    /// @param networkOrganization The XBR network organization address.
    constructor (address networkToken, address networkOrganization) public {

        // read chain ID into temp local var (to avoid "TypeError: Only local variables are supported").
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        verifyingChain = chainId;
        verifyingContract = address(this);

        token = XBRToken(networkToken);
        coins[networkToken][ANYADR] = true;
        emit CoinChanged(networkToken, ANYADR, true);

        contribution = token.totalSupply() * 30 / 100;

        organization = networkOrganization;

        uint256 registered = block.timestamp;

        // technically, the creator of the XBR network contract instance is a XBR member (by definition).
        members[msg.sender] = XBRTypes.Member(registered, "", "", XBRTypes.MemberLevel.VERIFIED, "");
        emit MemberRegistered(msg.sender, registered, "", "", XBRTypes.MemberLevel.VERIFIED);
    }

    /// Register the sender of this transaction in the XBR network. All XBR stakeholders, namely data
    /// providers ("sellers"), data consumers ("buyers") and data market operators, must be registered
    /// in the XBR network.
    ///
    /// @param networkEula Multihash of the XBR EULA being agreed to and stored as one ZIP file archive on IPFS.
    /// @param memberProfile Optional public member profile: the IPFS Multihash of the member profile stored in IPFS.
    function registerMember (string memory networkEula, string memory memberProfile) public {
        _registerMember(msg.sender, block.number, networkEula, memberProfile, "");
    }

    /// Register the specified new member in the XBR Network. All XBR stakeholders, namely data
    /// providers ("sellers"), data consumers ("buyers") and data market operators, must be registered
    /// in the XBR network.
    ///
    /// Note: This version uses pre-signed data where the actual blockchain transaction is
    /// submitted by a gateway paying the respective gas (in ETH) for the blockchain transaction.
    ///
    /// @param member Address of the registering (new) member.
    /// @param registered Block number at which the registering member has created the signature.
    /// @param networkEula Multihash of the XBR EULA being agreed to and stored as one ZIP file archive on IPFS.
    /// @param memberProfile Optional public member profile: the IPFS Multihash of the member profile stored in IPFS.
    /// @param signature EIP712 signature, signed by the registering member.
    function registerMemberFor (address member, uint256 registered, string memory networkEula,
        string memory memberProfile, bytes memory signature) public {

        // verify signature
        require(XBRTypes.verify(member, XBRTypes.EIP712MemberRegister(verifyingChain, verifyingContract,
            member, registered, networkEula, memberProfile), signature), "INVALID_MEMBER_REGISTER_SIGNATURE");

        // signature must have been created in a window of PRESIGNED_TXN_MAX_AGE blocks from the current one
        require(registered <= block.number && (block.number <= PRESIGNED_TXN_MAX_AGE ||
            registered >= (block.number - PRESIGNED_TXN_MAX_AGE)), "INVALID_REGISTERED_BLOCK_NUMBER");

        _registerMember(member, registered, networkEula, memberProfile, signature);
    }

    function _registerMember (address member, uint256 registered, string memory networkEula, string memory profile, bytes memory signature) private {
        // check that sender is not already a member
        require(uint8(members[member].level) == 0, "MEMBER_ALREADY_REGISTERED");

        // check that the EULA the member accepted is the one we expect
        require(keccak256(abi.encode(networkEula)) ==
                keccak256(abi.encode(eula)), "INVALID_EULA");

        // remember the member
        members[member] = XBRTypes.Member(registered, networkEula, profile, XBRTypes.MemberLevel.ACTIVE, signature);

        // notify observers of new member
        emit MemberRegistered(member, registered, networkEula, profile, XBRTypes.MemberLevel.ACTIVE);
    }

    /// Unregister the sender of this transaction from the XBR network.
    function unregisterMember () public {
        _unregisterMember(msg.sender, block.number, "");
    }

    /// Unregister the specified member from the XBR Network.
    ///
    /// Note: This version uses pre-signed data where the actual blockchain transaction is
    /// submitted by a gateway paying the respective gas (in ETH) for the blockchain transaction.
    ///
    /// @param member Address of the unregistering (existing) member.
    /// @param retired Block number at which the unregistering member has created the signature.
    /// @param signature EIP712 signature, signed by the unregistering member.
    function unregisterMemberFor (address member, uint256 retired, bytes memory signature) public {

        // verify signature
        require(XBRTypes.verify(member, XBRTypes.EIP712MemberUnregister(verifyingChain, verifyingContract,
            member, retired), signature), "INVALID_SIGNATURE");

        // signature must have been created in a window of PRESIGNED_TXN_MAX_AGE blocks from the current one
        require(retired <= block.number && (block.number <= PRESIGNED_TXN_MAX_AGE ||
            retired >= (block.number - PRESIGNED_TXN_MAX_AGE)), "INVALID_BLOCK_NUMBER");

        _unregisterMember(member, retired, signature);
    }

    function _unregisterMember (address member, uint256 retired, bytes memory signature) private {
        // check that sender is currently a member
        require(members[member].level == XBRTypes.MemberLevel.ACTIVE ||
                members[member].level == XBRTypes.MemberLevel.VERIFIED, "MEMBER_NOT_REGISTERED");

        // remember the member left the network
        members[member].level = XBRTypes.MemberLevel.RETIRED;

        // notify observers of retired member
        emit MemberRetired(member, retired);
    }

    /// Set the XBR network organization address.
    ///
    /// @param networkToken The token to run this network itself on. Note that XBR data markets can use
    ///                     any ERC20 token (enabled in the ``coins`` mapping of this contract) as
    ///                     a means of payment in the respective market.
    function setNetworkToken (address networkToken) public onlyMaintainer returns (bool) {
        if (networkToken != address(token)) {
            coins[address(token)][ANYADR] = false;
            token = XBRToken(networkToken);
            coins[networkToken][ANYADR] = true;
            return true;
        } else {
            return false;
        }
    }

    /// Set the XBR network organization address.
    ///
    /// @param networkOrganization The XBR network organization address.
    function setNetworkOrganization (address networkOrganization) public onlyMaintainer returns (bool) {
        if (networkOrganization != address(organization)) {
            organization = networkOrganization;
            return true;
        } else {
            return false;
        }
    }

    /// Set (override manually) the member level of a XBR Network member. Being able to do so
    /// currently serves two purposes:
    ///
    /// - having a last resort to handle situation where members violated the EULA
    /// - being able to manually patch things in error/bug cases
    ///
    /// @param member The address of the XBR network member to override member level.
    /// @param level The member level to set the member to.
    function setMemberLevel (address member, XBRTypes.MemberLevel level) public onlyMaintainer returns (bool) {
        require(uint(members[msg.sender].level) != 0, "NO_SUCH_MEMBER");
        if (members[member].level != level) {
            members[member].level = level;
            emit MemberChanged(member, block.timestamp, members[member].eula, members[member].profile, level);
            return true;
        } else {
            return false;
        }
    }

    /// Set ERC20 coins as usable as a means of payment when opening data markets.
    ///
    /// @param coin The address of the ERC20 coin to change.
    /// @param isPayable When true, the coin can be specified when opening a new data market.
    function setCoinPayable (address coin, address operator, bool isPayable) public onlyMaintainer returns (bool) {
        if (coins[coin][operator] != isPayable) {
            coins[coin][operator] = isPayable;
            emit CoinChanged(coin, operator, isPayable);
            return true;
        } else {
            return false;
        }
    }

    /// Set the network contribution which is deducted from the market fees defined by a market operator.
    ///
    /// @param networkContribution Network contribution, defined as the ratio of given number of
    ///                            tokens and the total token supply.
    /// @return Flag indicating whether the contribution value was actually changed.
    function setContribution (uint256 networkContribution) public onlyMaintainer returns (bool) {
        require(networkContribution >= 0 && networkContribution <= token.totalSupply(), "INVALID_CONTRIBUTION");
        if (contribution != networkContribution) {
            contribution = networkContribution;
            return true;
        } else {
            return false;
        }
    }
}
