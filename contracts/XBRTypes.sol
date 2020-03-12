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

import "./XBRToken.sol";
import "./XBRChannel.sol";


/**
 * @title XBR domain types and helper functions.
 * @author The XBR Project
 */
library XBRTypes {

    /// All XBR Member levels.
    enum MemberLevel { NULL, ACTIVE, VERIFIED, RETIRED, PENALTY, BLOCKED }

    /// All XBR Actor types in a market.
    enum ActorType { NULL, PROVIDER, CONSUMER }

    /// All XBR Channel types.
    enum ChannelType { NULL, PAYMENT, PAYING }

    /// All XBR Channel states.
    enum ChannelState { NULL, OPEN, CLOSING, CLOSED }

    // //////// container types

    /// Container type for holding XBR Network membership information.
    struct Member {
        /// Time (block.timestamp) when the member was (initially) registered.
        uint registered;

        /// The IPFS Multihash of the XBR EULA being agreed to and stored as one
        /// ZIP file archive on IPFS.
        string eula;

        /// Optional public member profile: the IPFS Multihash of the member profile stored in IPFS.
        string profile;

        /// Current member level.
        MemberLevel level;

        /// If the transaction was pre-signed, this is the signature the user supplied
        bytes signature;
    }

    /// Container type for holding XBR Market Actors information.
    struct Actor {
        /// Time (block.timestamp) when the actor has joined.
        uint joined;

        /// Security deposited by actor.
        uint256 security;

        /// Metadata attached to an actor in a market.
        string meta;

        /// This is the signature the user (actor) supplied for joining a market.
        bytes signature;

        /// All payment (paying) channels of the respective buyer (seller) actor.
        address[] channels;
    }

    /// Container type for holding XBR Market information.
    struct Market {
        /// Time (block.timestamp) when the market was created.
        uint created;

        /// Market sequence number.
        uint32 marketSeq;

        /// Market owner (aka "market operator").
        address owner;

        /// Market terms (IPFS Multihash).
        string terms;

        /// Market metadata (IPFS Multihash)
        string meta;

        /// Current market maker address.
        address maker;

        /// Security deposit required by data providers (sellers) to join the market.
        uint256 providerSecurity;

        /// Security deposit required by data consumers (buyers) to join the market.
        uint256 consumerSecurity;

        /// Market fee rate for the market operator.
        uint256 marketFee;

        /// This is the signature the user (market owner/operator) supplied for opening the market.
        bytes signature;

        /// Adresses of provider (seller) actors joined in the market.
        address[] providerActorAdrs;

        /// Adresses of consumer (buyer) actors joined in the market.
        address[] consumerActorAdrs;

        /// Provider (seller) actors joined in the market by actor address.
        mapping(address => Actor) providerActors;

        /// Consumer (buyer) actors joined in the market by actor address.
        mapping(address => Actor) consumerActors;

        /// Current payment channel by (buyer) delegate.
        mapping(address => address) currentPaymentChannelByDelegate;

        /// Current paying channel by (seller) delegate.
        mapping(address => address) currentPayingChannelByDelegate;
    }

    /// Container type for holding channel static information.
    struct Channel {
        /// Channel sequence number.
        uint32 channelSeq;

        /// Block timestamp when the channel was created.
        uint256 openedAt;

        /// Current payment channel type (either payment or paying channel).
        ChannelType ctype;

        /// The XBR Market ID this channel is operating payments (or payouts) for.
        bytes16 marketId;

        /**
        * The off-chain market maker that operates this payment or paying channel.
        */
        address marketmaker;

        /**
        * The sender of the payments in this channel. Either a XBR Consumer (payment channels) or
        * the XBR Market Maker (paying channels).
        */
        address actor;

        /**
        * The delegate of the channel, e.g. the XBR Consumer delegate in case of a payment channel
        * or the XBR Provider (delegate) in case of a paying channel that is allowed to consume or
        * provide data with payment therefor running under this channel.
        */
        address delegate;

        /**
        * Recipient of the payments in this channel. Either the XBR Market Operator (payment
        * channels) or a XBR Provider (paying channels) in the market.
        */
        address recipient;

        /// Amount of XBR held in the channel.
        uint256 amount;

        /**
        * Timeout with which the channel will be closed (the grace period during which the
        * channel will wait for participants to submit their last signed transaction).
        */
        uint32 timeout;

        /// Signature supplied (by the actor) when opening the channel.
        bytes signature;
    }

    /// Container type for holding channel closing state information.
    struct ChannelClosingState {
        /// Current payment channel state.
        ChannelState state;

        /// Block timestamp when the channel was requested to close (before timeout).
        uint256 closingAt;

        /// When this channel is closing, the sequence number of the closing transaction.
        uint32 closingSeq;

        /// When this channel is closing, the off-chain closing balance of the closing transaction.
        uint256 closingBalance;

        /// Block timestamp when the channel was closed (finally, after the timeout).
        uint256 closedAt;

        /// When this channel has closed, the sequence number of the final accepted closing transaction.
        uint32 closedSeq;

        /// When this channel is closing, the closing balance of the final accepted closing transaction.
        uint256 closedBalance;

        /// Closing transaction signature by (buyer or seller) delegate supplied when requesting to close the channel.
        bytes delegateSignature;

        /// Closing transaction signature by market maker supplied when requesting to close the channel.
        bytes marketmakerSignature;
    }

    /// EIP712 type for XBR as a type domain.
    struct EIP712Domain {
        // make signatures from different domains incompatible
        string  name;
        string  version;
    }

    /// EIP712 type for use in XBRNetwork.registerFor.
    struct EIP712MemberRegister {
        // replay attack protection
        uint256 chainId;
        address verifyingContract;

        // actual data attributes
        address member;
        uint256 registered;
        string eula;
        string profile;
    }

    /// EIP712 type for use in XBRMarket.createMarketFor.
    struct EIP712MarketCreate {
        // replay attack protection
        uint256 chainId;
        address verifyingContract;

        // actual data attributes
        bytes16 marketId;
        string terms;
        string meta;
        address maker;
        uint256 providerSecurity;
        uint256 consumerSecurity;
        uint256 marketFee;
    }

    /// EIP712 type for use in XBRMarket.joinMarketFor.
    struct EIP712MarketJoin {
        // replay attack protection
        uint256 chainId;
        address verifyingContract;

        // actual data attributes
        address member;
        uint256 joined;
        bytes16 marketId;
        uint8 actorType;
        string meta;
    }

    /// EIP712 type for use in XBRChannel.openFor.
    struct EIP712ChannelOpen {
        // replay attack protection
        uint256 chainId;
        address verifyingContract;

        // actual data attributes
        uint8 ctype;
        uint256 openedAt;
        bytes16 marketId;
        bytes16 channelId;
        address actor;
        address delegate;
        address marketmaker;
        address recipient;
        uint256 amount;
        uint32 timeout;
    }

    /// EIP712 type for use in XBRChannel.closeFor.
    struct EIP712ChannelClose {
        // replay attack protection
        uint256 chainId;
        address verifyingContract;

        // actual data attributes
        bytes16 marketId;
        bytes16 channelId;
        uint32 channelSeq;
        uint256 balance;
        bool isFinal;
    }

    /// EIP712 type data.
    // solhint-disable-next-line
    bytes32 constant EIP712_DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,string version)");

    /// EIP712 type data.
    // solhint-disable-next-line
    bytes32 constant EIP712_MEMBER_REGISTER_TYPEHASH = keccak256("EIP712MemberRegister(uint256 chainId,address verifyingContract,address member,uint256 registered,string eula,string profile)");

    /// EIP712 type data.
    // solhint-disable-next-line
    bytes32 constant EIP712_MARKET_CREATE_TYPEHASH = keccak256("EIP712MarketCreate(uint256 chainId,address verifyingContract,bytes16 marketId,string terms,string meta,address maker,uint256 providerSecurity,uint256 consumerSecurity,uint256 marketFee)");

    /// EIP712 type data.
    // solhint-disable-next-line
    bytes32 constant EIP712_MARKET_JOIN_TYPEHASH = keccak256("EIP712MarketJoin(uint256 chainId,address verifyingContract,address member,uint256 joined,bytes16 marketId,uint8 actorType,string meta)");

    /// EIP712 type data.
    // solhint-disable-next-line
    bytes32 constant EIP712_CHANNEL_OPEN_TYPEHASH = keccak256("EIP712ChannelOpen(uint256 chainId,address verifyingContract,uint8 ctype,uint256 openedAt,bytes16 marketId,bytes16 channelId,address actor,address delegate,address recipient,uint256 amount,uint32 timeout)");

    /// EIP712 type data.
    // solhint-disable-next-line
    bytes32 constant EIP712_CHANNEL_CLOSE_TYPEHASH = keccak256("EIP712ChannelClose(uint256 chainId,address verifyingContract,bytes16 marketId,bytes16 channelId,uint32 channelSeq,uint256 balance,bool isFinal)");

    /**
     * Split a signature given as a bytes string into components.
     */
    function splitSignature (bytes memory signature_rsv) private pure returns (uint8 v, bytes32 r, bytes32 s) {
        require(signature_rsv.length == 65, "INVALID_SIGNATURE_LENGTH");

        //  // first 32 bytes, after the length prefix
        //  r := mload(add(sig, 32))
        //  // second 32 bytes
        //  s := mload(add(sig, 64))
        //  // final byte (first byte of the next 32 bytes)
        //  v := byte(0, mload(add(sig, 96)))
        assembly
        {
            r := mload(add(signature_rsv, 32))
            s := mload(add(signature_rsv, 64))
            v := and(mload(add(signature_rsv, 65)), 255)
        }
        if (v < 27) {
            v += 27;
        }

        return (v, r, s);
    }

    function hash(EIP712Domain memory domain_) private pure returns (bytes32) {
        return keccak256(abi.encode(
            EIP712_DOMAIN_TYPEHASH,
            keccak256(bytes(domain_.name)),
            keccak256(bytes(domain_.version))
        ));
    }

    function domainSeparator () private pure returns (bytes32) {
        // makes signatures from different domains incompatible.
        // see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md#arbitrary-messages
        return hash(EIP712Domain({
            name: "XBR",
            version: "1"
        }));
    }

    function hash (EIP712MemberRegister memory obj) private pure returns (bytes32) {
        return keccak256(abi.encode(
            EIP712_MEMBER_REGISTER_TYPEHASH,
            obj.chainId,
            obj.verifyingContract,
            obj.member,
            obj.registered,
            keccak256(bytes(obj.eula)),
            keccak256(bytes(obj.profile))
        ));
    }

    function hash (EIP712MarketCreate memory obj) private pure returns (bytes32) {
        return keccak256(abi.encode(
            EIP712_MARKET_CREATE_TYPEHASH,
            obj.chainId,
            obj.verifyingContract,
            obj.marketId,
            keccak256(bytes(obj.terms)),
            keccak256(bytes(obj.meta)),
            obj.maker,
            obj.providerSecurity,
            obj.consumerSecurity,
            obj.marketFee
        ));
    }

    function hash (EIP712MarketJoin memory obj) private pure returns (bytes32) {
        return keccak256(abi.encode(
            EIP712_MARKET_JOIN_TYPEHASH,
            obj.chainId,
            obj.verifyingContract,
            obj.member,
            obj.joined,
            obj.marketId,
            obj.actorType,
            keccak256(bytes(obj.meta))
        ));
    }

    function hash (EIP712ChannelOpen memory obj) private pure returns (bytes32) {
        return keccak256(abi.encode(
            EIP712_CHANNEL_OPEN_TYPEHASH,
            obj.chainId,
            obj.verifyingContract,
            obj.ctype,
            obj.openedAt,
            obj.marketId,
            obj.channelId,
            obj.actor,
            obj.delegate,
            obj.recipient,
            obj.amount,
            obj.timeout
        ));
    }

    function hash (EIP712ChannelClose memory obj) private pure returns (bytes32) {
        return keccak256(abi.encode(
            EIP712_CHANNEL_CLOSE_TYPEHASH,
            obj.chainId,
            obj.verifyingContract,
            obj.marketId,
            obj.channelId,
            obj.channelSeq,
            obj.balance,
            obj.isFinal
        ));
    }

    function verify (address signer, EIP712MemberRegister memory obj,
        bytes memory signature) public pure returns (bool) {

        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);

        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            domainSeparator(),
            hash(obj)
        ));

        return ecrecover(digest, v, r, s) == signer;
    }

    function verify (address signer, EIP712MarketCreate memory obj,
        bytes memory signature) public pure returns (bool) {

        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);

        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            domainSeparator(),
            hash(obj)
        ));

        return ecrecover(digest, v, r, s) == signer;
    }

    function verify (address signer, EIP712MarketJoin memory obj,
        bytes memory signature) public pure returns (bool) {

        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);

        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            domainSeparator(),
            hash(obj)
        ));

        return ecrecover(digest, v, r, s) == signer;
    }

    function verify (address signer, EIP712ChannelOpen memory obj,
        bytes memory signature) public pure returns (bool) {

        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);

        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            domainSeparator(),
            hash(obj)
        ));

        return ecrecover(digest, v, r, s) == signer;
    }

    function verify (address signer, EIP712ChannelClose memory obj,
        bytes memory signature) public pure returns (bool) {

        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);

        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            domainSeparator(),
            hash(obj)
        ));

        return ecrecover(digest, v, r, s) == signer;
    }
}
