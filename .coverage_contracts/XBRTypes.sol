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
function coverage_0x1bcd7adb(bytes32 c__0x1bcd7adb) public pure {}


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
    function splitSignature (bytes memory signature_rsv) private pure returns (uint8 v, bytes32 r, bytes32 s) {coverage_0x1bcd7adb(0x1c17e6a8d73b0e65301795421c097c95b8d37c04252185767064908ff0e1eff7); /* function */ 

coverage_0x1bcd7adb(0x522f0131628eafb7a76f4bd9164f964eb0d976a555918e535a8994abd6be084c); /* line */ 
        coverage_0x1bcd7adb(0xbd9397a08396850d5d11ed0eeecc9abf428239c0ad2918e7a8d524b87ac191d5); /* assertPre */ 
coverage_0x1bcd7adb(0x7d2641767be48d25130070eae1992e7f724444345408149678e2a1b714abb047); /* statement */ 
require(signature_rsv.length == 65, "INVALID_SIGNATURE_LENGTH");coverage_0x1bcd7adb(0xddb742922382dcedc56e9e7cab1d7c6f9920d8ec430a9214f7a95ffbf9230fd3); /* assertPost */ 


        //  // first 32 bytes, after the length prefix
        //  r := mload(add(sig, 32))
        //  // second 32 bytes
        //  s := mload(add(sig, 64))
        //  // final byte (first byte of the next 32 bytes)
        //  v := byte(0, mload(add(sig, 96)))
coverage_0x1bcd7adb(0x7e86780f686d461600fdfa1b56fd899768b267b0f955d817b76c8b435741f3e5); /* line */ 
        assembly
        {
            r := mload(add(signature_rsv, 32))
            s := mload(add(signature_rsv, 64))
            v := and(mload(add(signature_rsv, 65)), 255)
        }
coverage_0x1bcd7adb(0x69c215c83086f4b24c3abc7865517a4b6312f02c785910b720b8ff1c23ee97e1); /* line */ 
        coverage_0x1bcd7adb(0xc64711eba8cf850bf8fa8d7786cab84ba91a31e6d490997ee64f467b27007732); /* statement */ 
if (v < 27) {coverage_0x1bcd7adb(0xf2fc2fa51223fe3435a72ae01922844fc2aee79529032ca90bd76849eff028a8); /* branch */ 

coverage_0x1bcd7adb(0x6cff7183c5a4db16a140b1974f8e84703d8398521ebfeb482f105018d4d4904b); /* line */ 
            coverage_0x1bcd7adb(0x9c7787b9cb1a54fe98f8bc60a0b3ba3b4112be7d5006121f8f02bd66e9949c99); /* statement */ 
v += 27;
        }else { coverage_0x1bcd7adb(0xa57bc9b913dda51f2e54942efc9d7df6205d17f52b3581674e8e3886078381d6); /* branch */ 
}

coverage_0x1bcd7adb(0x67144a2c742ee4f81d17fa7af14d3a3fc442362710193c3b1656caa0ca11179b); /* line */ 
        coverage_0x1bcd7adb(0x4479de06b0bdc07384ec5e468c4009735cbb87b456fbecb46568974dae829a21); /* statement */ 
return (v, r, s);
    }

    function hash(EIP712Domain memory domain_) private pure returns (bytes32) {coverage_0x1bcd7adb(0x5857c9454db723ef943820ab34acd6ca00a2d4d84b0718fcc422d8a88d176555); /* function */ 

coverage_0x1bcd7adb(0xf3c5dacb39a14f38fa530d32fc656f5cb7d30a03a97aaba9a0d16052e0820c6e); /* line */ 
        coverage_0x1bcd7adb(0xd5b189f0533471c5b5fc6564d1e842116f83a6070227e7f9e2c1531ff93dd930); /* statement */ 
return keccak256(abi.encode(
            EIP712_DOMAIN_TYPEHASH,
            keccak256(bytes(domain_.name)),
            keccak256(bytes(domain_.version)),
            domain_.chainId,
            domain_.verifyingContract
        ));
    }

    function domainSeparator () private pure returns (bytes32) {coverage_0x1bcd7adb(0xaa043e99c6741b0e5f8f502e86afc074721a87213674d8a264188a0ed34296f3); /* function */ 

coverage_0x1bcd7adb(0x824c22448b15c0a97778500a4417d82a0ae30043487328647e2e57b6340692d1); /* line */ 
        coverage_0x1bcd7adb(0xe37112a24f4fb06724d181165db1c0de1f0961e13b409662d19f4c097560bcb5); /* statement */ 
return hash(EIP712Domain({
            name: "XBR",
            version: "1",
            // FIXME: read chain ID at run-time (if possible)
            chainId: 1,
            //verifyingContract: address(this)
            verifyingContract: 0x254dffcd3277C0b1660F6d42EFbB754edaBAbC2B
        }));
    }

    function hash (EIP712MemberRegister memory obj) private pure returns (bytes32) {coverage_0x1bcd7adb(0x3ee1cc32bd45a50190372cf3d751b8eca5d140114132dfa34490f2fc64c0291d); /* function */ 

coverage_0x1bcd7adb(0xced14daf61f0df5c6f7106580e5a301f9520b4da60fb0db2ecaad19fcb8dd656); /* line */ 
        coverage_0x1bcd7adb(0x9e159e9fa8d6351270c6333b60e1b74b4b0befa39bfecd4c45e3bd53ef3c8762); /* statement */ 
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

    function hash (EIP712MarketJoin memory obj) private pure returns (bytes32) {coverage_0x1bcd7adb(0xfdff11e9d730daf6112fca5837954e8961bfae8cfeb0f907acdade7c28458f81); /* function */ 

coverage_0x1bcd7adb(0x434f247bc1719e8ca03cf0601265bfa8247922dbcd4ec2b5f5e341bac067e122); /* line */ 
        coverage_0x1bcd7adb(0x9055a81874688ec9731c4b1cd5ac80a72a270cb9878485071f2c0eba7409da0c); /* statement */ 
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
        bytes memory signature) public pure returns (bool) {coverage_0x1bcd7adb(0xa7cf41898d0cea3795b4205aea02e900446f1edd6d749c4821a793edb80b92f6); /* function */ 


coverage_0x1bcd7adb(0xabcd5862becdd38f03a239e2bb40eddcd2d7d54f5f3743d5f20111f877a822fd); /* line */ 
        coverage_0x1bcd7adb(0x78b48ea2e4a95b0f845948384e5cfe155da85f117752508516ae893d2793f26e); /* statement */ 
(uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);

coverage_0x1bcd7adb(0x90c7ae20177e4e1dcf856538ea80cd9fe164269dba02b2af6391fa2be5739cd5); /* line */ 
        coverage_0x1bcd7adb(0xb2f1f311f5f5b66982d6f4995837f40af296c6a780f51a046b316d9619e9d03a); /* statement */ 
bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            domainSeparator(),
            hash(obj)
        ));

coverage_0x1bcd7adb(0x25e435579e6c827b2deecc8b47a18b35bb51cea504c250fa7c08d03d1b54fb7a); /* line */ 
        coverage_0x1bcd7adb(0x6d6cecae1a9021f99ad6322b2cc02682bdc2ced0d6b4f9f858be57a67531f8a0); /* statement */ 
return ecrecover(digest, v, r, s) == signer;
    }

    function verify (address signer, EIP712MemberRegister memory obj,
        bytes memory signature) public pure returns (bool) {coverage_0x1bcd7adb(0xd6c48a558c81487cf621531a85578070cba0127bfab50169ce7f6732d4006069); /* function */ 


coverage_0x1bcd7adb(0x2bc5cbc9f973c7ada13473ba519afe8e9a22354a1c6a475b09ab52c4af0418e5); /* line */ 
        coverage_0x1bcd7adb(0x16ca67d8d4e5aa1737789f976b5818e4d6eac675d6546d647278d0075173b59b); /* statement */ 
(uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);

coverage_0x1bcd7adb(0x2fc71ba55ed5c57714d3ffb9f8623c6afbcd95d7757086abd977dd77fa598842); /* line */ 
        coverage_0x1bcd7adb(0xabe98105d6fdfa83b2975b5dd28c03dde16528db0568090c6c9819d946f8b877); /* statement */ 
bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            domainSeparator(),
            hash(obj)
        ));

coverage_0x1bcd7adb(0x9b24b8c03a00b992dc81fd410c8dfe0c7edb84e719c181d73d83181136c371e9); /* line */ 
        coverage_0x1bcd7adb(0x49e45f12870ffcfff335b3de1ece4e470ae582b04b6fc26ad706ebd7deee2c92); /* statement */ 
return ecrecover(digest, v, r, s) == signer;
    }

    function verify (address signer, EIP712MarketJoin memory obj,
        bytes memory signature) public pure returns (bool) {coverage_0x1bcd7adb(0xc3e7693547da86bfbcc47ef1204d26c98be2982036b0b119dbe7081911a18a7e); /* function */ 


coverage_0x1bcd7adb(0x842ed7ba09385d2f84d5994f08abf7c1171e3453c7e686a09880924272ac6d48); /* line */ 
        coverage_0x1bcd7adb(0x0635b1094eafe46389ed61098aa5744654c0f131d6b89dd94aeedc0a8e99f67a); /* statement */ 
(uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);

coverage_0x1bcd7adb(0x2792d2d4dca94db526ad6e68c57ffb36a72b1c098117668a7bfde04943c793d2); /* line */ 
        coverage_0x1bcd7adb(0xa0756ea4ffd706b5c99e10a19e7f6db274fe1c1ef00e87ddc30b08136360c111); /* statement */ 
bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            domainSeparator(),
            hash(obj)
        ));

coverage_0x1bcd7adb(0xfaf10cd3e908a01fb87d1a6d16b8b426216a3df7479eb356f47120ae93d36e39); /* line */ 
        coverage_0x1bcd7adb(0xc5fd730f9a36e7582b1fddddf17b90e1540c2801dd9ca84e55c9bc38cc0b4f2e); /* statement */ 
return ecrecover(digest, v, r, s) == signer;
    }
}
