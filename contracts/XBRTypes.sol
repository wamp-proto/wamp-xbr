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
pragma experimental ABIEncoderV2;

import "./XBRToken.sol";
import "./XBRChannel.sol";


/**
 * @title XBR domain types and helper functions.
 * @author The XBR Project
 */
library XBRTypes {

    /// XBR Network membership levels
    enum MemberLevel { NULL, ACTIVE, VERIFIED, RETIRED, PENALTY, BLOCKED }

    /// XBR Market Actor types
    enum ActorType { NULL, PROVIDER, CONSUMER }

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
    }

    /// Container type for holding XBR Market Actors information.
    struct Actor {
        /// Time (block.timestamp) when the actor has joined.
        uint joined;

        /// Security deposited by actor.
        uint256 security;

        /// Metadata attached to an actor in a market.
        string meta;

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

    /// Container type for holding paying channel request information.
    struct PayingChannelRequest {
        bytes16 marketId;
        address sender;
        address delegate;
        address recipient;
        uint256 amount;
        uint32 timeout;
    }

    /// EIP712 type.
    struct EIP712Domain {
        string  name;
        string  version;
        uint256 chainId;
        address verifyingContract;
    }

    /// EIP712 type.
    struct EIP712MemberRegister {
        uint256 chainId;
        uint256 blockNumber;
        address verifyingContract;
        address member;
        string eula;
        string profile;
    }

    /// EIP712 type.
    struct EIP712MarketJoin {
        uint256 chainId;
        uint256 blockNumber;
        address verifyingContract;
        address member;
        bytes16 marketId;
        uint8 actorType;
        string meta;
    }

    /// EIP712 type data.
    bytes32 constant EIP712_DOMAIN_TYPEHASH = keccak256(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
    );

    /// EIP712 type data.
    bytes32 constant EIP712_MEMBER_REGISTER_TYPEHASH = keccak256(
        "EIP712MemberRegister(uint256 chainId,uint256 blockNumber,address verifyingContract,address member,string eula,string profile)"
    );

    /// EIP712 type data.
    bytes32 constant EIP712_MARKET_JOIN_TYPEHASH = keccak256(
        "EIP712MarketJoin(uint256 chainId,uint256 blockNumber,address verifyingContract,address member,bytes16 marketId,uint8 actorType,string meta)"
    );

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
            keccak256(bytes(domain_.version)),
            domain_.chainId,
            domain_.verifyingContract
        ));
    }

    function domainSeparator () private pure returns (bytes32) {
        return hash(EIP712Domain({
            name: "XBR",
            version: "1",
            // FIXME: read chain ID at run-time (if possible)
            chainId: 1,
            //verifyingContract: address(this)
            verifyingContract: 0x254dffcd3277C0b1660F6d42EFbB754edaBAbC2B
        }));
    }

    function hash (EIP712MemberRegister memory obj) private pure returns (bytes32) {
        return keccak256(abi.encode(
            EIP712_MEMBER_REGISTER_TYPEHASH,
            obj.chainId,
            obj.blockNumber,
            obj.verifyingContract,
            obj.member,
            keccak256(bytes(obj.eula)),
            keccak256(bytes(obj.profile))
        ));
    }

    function hash (EIP712MarketJoin memory obj) private pure returns (bytes32) {
        return keccak256(abi.encode(
            EIP712_MARKET_JOIN_TYPEHASH,
            obj.chainId,
            obj.blockNumber,
            obj.verifyingContract,
            obj.member,
            obj.marketId,
            obj.actorType,
            keccak256(bytes(obj.meta))
        ));
    }

    function verify (address signer, EIP712Domain memory obj,
        bytes memory signature) public pure returns (bool) {

        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);

        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            domainSeparator(),
            hash(obj)
        ));

        return ecrecover(digest, v, r, s) == signer;
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
}
