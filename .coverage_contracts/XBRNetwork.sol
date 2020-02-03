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

// https://openzeppelin.org/api/docs/math_SafeMath.html
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "./XBRToken.sol";
import "./XBRTypes.sol";
import "./XBRMaintained.sol";
import "./XBRChannel.sol";


/**
 * @title XBR Network main smart contract.
 * @author The XBR Project
 */
contract XBRNetwork is XBRMaintained {
function coverage_0x2b4f46cc(bytes32 c__0x2b4f46cc) public pure {}


    // Add safe math functions to uint256 using SafeMath lib from OpenZeppelin
    using SafeMath for uint256;

    // //////// events for MEMBERS

    /// Event emitted when a new member joined the XBR Network.
    event MemberCreated (address indexed member, uint registered, string eula, string profile, XBRTypes.MemberLevel level);

    /// Event emitted when a member leaves the XBR Network.
    event MemberRetired (address member);

    // //////// events for MARKETS

    /// Event emitted when a new market was created.
    event MarketCreated (bytes16 indexed marketId, uint created, uint32 marketSeq, address owner, string terms,
        string meta, address maker, uint256 providerSecurity, uint256 consumerSecurity, uint256 marketFee);

    /// Event emitted when a market was updated.
    event MarketUpdated (bytes16 indexed marketId, uint32 marketSeq, address owner, string terms, string meta,
        address maker, uint256 providerSecurity, uint256 consumerSecurity, uint256 marketFee);

    /// Event emitted when a market was closed.
    event MarketClosed (bytes16 indexed marketId);

    /// Event emitted when a new actor joined a market.
    event ActorJoined (bytes16 indexed marketId, address actor, uint8 actorType, uint joined,
        uint256 security, string meta);

    /// Event emitted when an actor has left a market.
    event ActorLeft (bytes16 indexed marketId, address actor, uint8 actorType);

    /// Event emitted when a new payment channel was created in a market.
    event ChannelCreated (bytes16 indexed marketId, address sender, address delegate,
        address recipient, address channel, XBRChannel.ChannelType channelType);

    /// Event emitted when a new request for a paying channel was created in a market.
    event PayingChannelRequestCreated (bytes16 indexed marketId, address sender, address recipient, address delegate,
        uint256 amount, uint32 timeout);

    // Note: closing event of payment channels are emitted from XBRChannel (not from here)

    // Note: closing event of payment channels are emitted from XBRChannel (not from here)

    /// Created markets are sequence numbered using this counter (to allow deterministic collision-free IDs for markets)
    uint32 private marketSeq = 1;

    /// XBR network EULA (IPFS Multihash). Source: https://github.com/crossbario/xbr-protocol/tree/master/ipfs/xbr-eula
    string public constant eula = "QmV1eeDextSdUrRUQp9tUXF8SdvVeykaiwYLgrXHHVyULY";

    /// XBR Network ERC20 token (XBR for the CrossbarFX technology stack)
    XBRToken public token;

    /// Address of the `XBR Network Organization <https://xbr.network/>`_
    address private organization;

    /// Current XBR Network members ("member directory").
    mapping(address => XBRTypes.Member) public members;

    /// Current XBR Markets ("market directory")
    mapping(bytes16 => XBRTypes.Market) public markets;

    /// List of IDs of current XBR Markets.
    bytes16[] public marketIds;

    /// Index: maker address => market ID
    mapping(address => bytes16) public marketsByMaker;

    /// Index: market owner address => [market ID]
    mapping(address => bytes16[]) public marketsByOwner;

    /**
     * Create a new network.
     *
     * @param token_ The token to run this network on.
     * @param organization_ The network technology provider and ecosystem sponsor.
     */
    constructor (address token_, address organization_) public {coverage_0x2b4f46cc(0xda473bae76ccbf2777d38f5ba879a0240a11b6b976cf73b12c65a55d68b990b7); /* function */ 


coverage_0x2b4f46cc(0x459619b31751d0b3a62f9db5f9fd4fa586d1b1734753d886a62e28ce83a592b7); /* line */ 
        coverage_0x2b4f46cc(0x34762bb7879dafff0c43207e80f23a46045d3f2a95c240797e6be79bef38e64b); /* statement */ 
token = XBRToken(token_);
coverage_0x2b4f46cc(0xce70e129f789b34bc148a638f20dcc20a1736600a748efccd032ee18f812b443); /* line */ 
        coverage_0x2b4f46cc(0xe4501d38f8cddd591d5a0297e0021b9711c09e00c2761c12f93612776885a16e); /* statement */ 
organization = organization_;

        // Technical creator is XBR member (by definition).
coverage_0x2b4f46cc(0x5f7fdf8a01b0563778c3972f656bd191002537c09fb44a8892a7070f65116084); /* line */ 
        coverage_0x2b4f46cc(0x63b2d2d3d24e096fa8d005345cefe4389429b576bbf53910d0e9ca745ec79b6a); /* statement */ 
members[msg.sender] = XBRTypes.Member(block.timestamp, "", "", XBRTypes.MemberLevel.VERIFIED);
    }

    /**
     * Register sender in the XBR Network. All XBR stakeholders, namely XBR Data Providers,
     * XBR Data Consumers and XBR Data Market Operators, must first register
     * with the XBR Network on the global blockchain by calling this function.
     *
     * @param eula_ The IPFS Multihash of the XBR EULA being agreed to and stored as one ZIP file archive on IPFS.
     * @param profile_ Optional public member profile: the IPFS Multihash of the member profile stored in IPFS.
     */
    function register (string memory eula_, string memory profile_) public {coverage_0x2b4f46cc(0xa5dc52462f42a5161b25d4a5a4bf2d4e335cf3d36a0a71c9223b8845510cf86b); /* function */ 

        // check that sender is not already a member
coverage_0x2b4f46cc(0x99a16ab937e2d824097f8e5a97f53b35095c86209fbd9dd8373ec0d5510c6787); /* line */ 
        coverage_0x2b4f46cc(0xd6e7d940db8336dbc56d88650a6aea82045b4e05db4f833d283b3cbaddaf7963); /* assertPre */ 
coverage_0x2b4f46cc(0xa7556ea7f84b0405417098c9a5d8f701d87cdf05101a8e4baf5835ed6acddbb9); /* statement */ 
require(uint8(members[msg.sender].level) == 0, "MEMBER_ALREADY_REGISTERED");coverage_0x2b4f46cc(0xb1c1e3df6ea14ee1eeefaf6bf1c337d87cbe25da32f67230f018b052709bcda0); /* assertPost */ 


        // check that the EULA the member accepted is the one we expect
coverage_0x2b4f46cc(0xca3477dc29bff390a44bf3a40243d2bc381850b6cc47e46ca99665b6ab5c9868); /* line */ 
        coverage_0x2b4f46cc(0x9376012cf5eaaabd04c738cdb27052c7192658697574deff7f4ac8f6302bb737); /* assertPre */ 
coverage_0x2b4f46cc(0x59cf313b6a6c96ad2e24a099775c0940ce5638e1edc2659a589b3a906a9fadeb); /* statement */ 
require(keccak256(abi.encode(eula_)) ==
                keccak256(abi.encode(eula)), "INVALID_EULA");coverage_0x2b4f46cc(0x5a0adf4e21fc6fc576de88a42f73f9e46ad5889189d965551ab0f30e8805a39f); /* assertPost */ 


        // remember the member
coverage_0x2b4f46cc(0x1c17b34e3fe159c7ff11e5f3a046d6343ff1c96ecf87db3e20aa476eaf9ebb1d); /* line */ 
        coverage_0x2b4f46cc(0x3c429a2c9b04363bab5ffc7c7cce5f1dbbf6d9ae09df2922e928eacd0a51ae3b); /* statement */ 
uint registered = block.timestamp;
coverage_0x2b4f46cc(0x1c5b9474c8b503f56ce65895ba485e4019fc299bf66d3d5d76e872826af7c8ca); /* line */ 
        coverage_0x2b4f46cc(0xdf28d1d094baeed1eaa812d22e201c16b95e1d9463ce51d929cbc111ce418e7d); /* statement */ 
members[msg.sender] = XBRTypes.Member(registered, eula_, profile_, XBRTypes.MemberLevel.ACTIVE);

        // notify observers of new member
coverage_0x2b4f46cc(0xf9beb5c5357d590dedeffee386a2c2e653a474a5652f7627adba6179d1489916); /* line */ 
        coverage_0x2b4f46cc(0xf4cafbfee53c940c40bea409117adb1c8c82e0e2e3f9b86bfa910c8f49ece5eb); /* statement */ 
emit MemberCreated(msg.sender, registered, eula_, profile_, XBRTypes.MemberLevel.ACTIVE);
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
        string memory profile_, bytes memory signature) public {coverage_0x2b4f46cc(0xdbd05a5bf52f5015bd70ec10d75da514a1d315cbe6c03a471deb268162c65a99); /* function */ 


        // check that sender is not already a member
coverage_0x2b4f46cc(0x2d1683dd852c03111d02561d08bfa46be367103aa21056a58df43d3327284ed3); /* line */ 
        coverage_0x2b4f46cc(0x09ab06a9d006ca4e9fe88178ca6f0518550bd4addd932d292b0caefdef5e5403); /* assertPre */ 
coverage_0x2b4f46cc(0xce730d3b568e04270529c7a04f2e5bb6c53812d2c9be6d5f6dd1d18bee24e229); /* statement */ 
require(uint8(members[member].level) == 0, "MEMBER_ALREADY_REGISTERED");coverage_0x2b4f46cc(0xd166692da48c759a126ab24aed215aca345770c140c3440816503ad38cdce48a); /* assertPost */ 


        // FIXME: check registered

        // check that the EULA the member accepted is the one we expect
coverage_0x2b4f46cc(0xb7fa82a89d636b822b2435f6a7a80a885090872149839d99daf1a349d69ca869); /* line */ 
        coverage_0x2b4f46cc(0xe492ed5c407dd1e03fb544c404422d40c8450cfa668b422c213258b35fb0a7db); /* assertPre */ 
coverage_0x2b4f46cc(0xa78f5b2bff1a8a371f43c57a74842b826c33fc7d450b07dff46a2a5c146c1ffe); /* statement */ 
require(keccak256(abi.encode(eula_)) ==
                keccak256(abi.encode(eula)), "INVALID_EULA");coverage_0x2b4f46cc(0xc106ea34f1fc317d124fc68b1f645b237ff645158a0b9c25b82910c4f5a4555e); /* assertPost */ 


        // FIXME: check profile

        // FIXME:
coverage_0x2b4f46cc(0x2ff78440538d335cb590e811ff97dc1d22c9ed239cd46ef7680612143b1b372e); /* line */ 
        coverage_0x2b4f46cc(0x8053f69b39be7a484b6d1e0fafcd85b3e3023d88ece6ee7b37f2f874d2e6c27c); /* assertPre */ 
coverage_0x2b4f46cc(0x1d5ffbf79beeed7429e8e027e109c429af1fdd8fbe58329bd69d90b8afad24b1); /* statement */ 
require(XBRTypes.verify(member, XBRTypes.EIP712MemberRegister(1, registered, 0x254dffcd3277C0b1660F6d42EFbB754edaBAbC2B,
            member, eula_, profile_), signature), "INVALID_MEMBER_REGISTER_SIGNATURE");coverage_0x2b4f46cc(0x514fa44feb9dd837acf9a7c37dc5aa867794f403c2b8bd7369f6a61e957b7eea); /* assertPost */ 


        // remember the member
coverage_0x2b4f46cc(0xd2d1ba4cc59e6f8a43f4c8e7f104aac6901ae8a136bf3b766c8dbd7e3db31e92); /* line */ 
        coverage_0x2b4f46cc(0xbdd9a5112cfce3399bd024e16f0b947627af9ff3e094ff1334daa777f88e06c3); /* statement */ 
members[member] = XBRTypes.Member(registered, eula_, profile_, XBRTypes.MemberLevel.ACTIVE);

        // notify observers of new member
coverage_0x2b4f46cc(0x1153a3717025c7c72f9c77ab3e2c7acf21820270cbf90eb031cbbff4028e57dc); /* line */ 
        coverage_0x2b4f46cc(0xa79d0cf21bf4b51c1975b673a0071b6d84b68be7791086d4927c5ce4c295f3c7); /* statement */ 
emit MemberCreated(member, registered, eula_, profile_, XBRTypes.MemberLevel.ACTIVE);
    }

    /**
     * Leave the XBR Network.
     */
    function unregister () public {coverage_0x2b4f46cc(0xb35af02e216cf516fc186b1c9cadb856640cfbf5c7000c332158e1f14f9e2bef); /* function */ 

coverage_0x2b4f46cc(0x8609873b7f73b083ab76fb2944596d205a0d81a519cc01d3e1076f89a5eaa364); /* line */ 
        coverage_0x2b4f46cc(0xe6a4f168be29da999c304a542d059d601074ef82c239dcfca95246420fe30959); /* assertPre */ 
coverage_0x2b4f46cc(0xfa4dd0c8338dcfb27c515ec1c0e264df8c3fb8f7d54d22bc5d1d969c6e08bf45); /* statement */ 
require(uint8(members[msg.sender].level) != 0, "NO_SUCH_MEMBER");coverage_0x2b4f46cc(0x7a591b40065e67be03331d56c3c6e6d3e5938c1719785c158d736751f52a3450); /* assertPost */ 

coverage_0x2b4f46cc(0x13dc9a9b214864a0241438a04649a8fac10334902ceeb226d3b065bc1dce64ae); /* line */ 
        coverage_0x2b4f46cc(0xc5e233273f318f61dc76dda0fe692a4a49346594c816424db7ebcce0b2b15194); /* assertPre */ 
coverage_0x2b4f46cc(0xb716166e5d010aeb42e77ba10f36eb200bc49fffe9967e2e51f15ab603cff8e8); /* statement */ 
require((uint8(members[msg.sender].level) == uint8(XBRTypes.MemberLevel.ACTIVE)) ||
                (uint8(members[msg.sender].level) == uint8(XBRTypes.MemberLevel.VERIFIED)), "MEMBER_NOT_ACTIVE");coverage_0x2b4f46cc(0xbc159bc6efdb53699d519bbbe2343c0c0a96f40581749c61b5f6c98359b6cd12); /* assertPost */ 


        // FIXME: check that the member has no active objects associated anymore
coverage_0x2b4f46cc(0x97d87d2ba99d62815c94e55e3189fcd8e0c31829ea099afff65568295a3bfc07); /* line */ 
        coverage_0x2b4f46cc(0x619e939d2b73449864dfff0b73d701e4af0a2025501d01d46bfaf6dab60cb5ac); /* assertPre */ 
coverage_0x2b4f46cc(0x883c844f6789851c2255cf58f5759a4c0e67c6011f01c3c1d1d3e26350585830); /* statement */ 
require(false, "NOT_IMPLEMENTED");coverage_0x2b4f46cc(0x2c6e466451c9d6cae6a16c055e3bf56dbfef2172181cf5f28ae41897b08325dc); /* assertPost */ 


coverage_0x2b4f46cc(0xa98f670e5109366d95a91dd631b8f6a0b9328875aea10dcf4fa22c7f42d99a72); /* line */ 
        coverage_0x2b4f46cc(0x73c39b0d7e3ab35cb801b396dda1188ef81880b5390bb8f0de75f56e3f7c4cae); /* statement */ 
members[msg.sender].level = XBRTypes.MemberLevel.RETIRED;

coverage_0x2b4f46cc(0x82437ee14e377baa8d733b1c4d00d7fcd34c48022424b7704c93c9fd8d83664a); /* line */ 
        coverage_0x2b4f46cc(0x75a0bc48cff66922cbfbe4906bd10e5117ff10b1645fbd15e47e98756c829efb); /* statement */ 
emit MemberRetired(msg.sender);
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
    function setMemberLevel (address member, XBRTypes.MemberLevel level) public onlyMaintainer {coverage_0x2b4f46cc(0xa0b90b8f4b244c43b4783ffd65ead5e47d38efb8f67861433706da798890bc80); /* function */ 

coverage_0x2b4f46cc(0x580e44ac8d0645d46698e1ec06157b9ce26ed63efdb0e75d5369ebe87239c21c); /* line */ 
        coverage_0x2b4f46cc(0x81bc1d1526a5917bedb353f4631fb6578b6f5bc77c001a97dc6fe3bab24b217c); /* assertPre */ 
coverage_0x2b4f46cc(0xfe62e68c47872f452f00240bd53e0c635865306999a66b332b7d73565564c6c7); /* statement */ 
require(uint(members[msg.sender].level) != 0, "NO_SUCH_MEMBER");coverage_0x2b4f46cc(0x32395755de3aef0bc0bd0e89073402605c65d1ca14236d76f12c7d4fe4edd99f); /* assertPost */ 


coverage_0x2b4f46cc(0x72e6113b07cb78e1b451e302e77055d2cc6b6450ca6c9cf5ca9dd2f1de0590c5); /* line */ 
        coverage_0x2b4f46cc(0x53354b1b273356cb5f4d1a0e6dbaca7a0d9f04f6f99df54061f35e202268c4e8); /* statement */ 
members[member].level = level;
    }

    /**
     * Create a new XBR market. The sender of the transaction must be XBR network member
     * and automatically becomes owner of the new market.
     *
     * @param marketId The ID of the market to create. Must be unique (not yet existing).
                       To generate a new ID you can do `python -c "import uuid; print(uuid.uuid4().bytes.hex())"`.
     * @param terms The XBR market terms set by the market owner. IPFS Multihash pointing
     *              to a ZIP archive file with market documents.
     * @param meta The XBR market metadata published by the market owner. IPFS Multihash pointing
     *             to a RDF/Turtle file with market metadata.
     * @param maker The address of the XBR market maker that will run this market. The delegate of the market owner.
     * @param providerSecurity The amount of XBR tokens a XBR provider joining the market must deposit.
     * @param consumerSecurity The amount of XBR tokens a XBR consumer joining the market must deposit.
     * @param marketFee The fee taken by the market (beneficiary is the market owner). The fee is a percentage of
     *                  the revenue of the XBR Provider that receives XBR Token paid for transactions.
     *                  The fee must be between 0% (inclusive) and 99% (inclusive), and is expressed as
     *                  a fraction of the total supply of XBR tokens.
     */
    function createMarket (bytes16 marketId, string memory terms, string memory meta, address maker,
        uint256 providerSecurity, uint256 consumerSecurity, uint256 marketFee) public {coverage_0x2b4f46cc(0x9cb5749dc65befb7720f7cdf01fe97863a60228d60d2f75d8a10ba224eb20ffd); /* function */ 


        // the market operator (owner) must be a registered member
coverage_0x2b4f46cc(0x5710eb460f62225c78b4eed5ea663e1ed4c8e197325ae1b147115b6819a0bb38); /* line */ 
        coverage_0x2b4f46cc(0xcb2df2b1332aa5cfde708239ec19de951d5f4b4e340ad487b9776e4a0d87ff03); /* assertPre */ 
coverage_0x2b4f46cc(0xa69f764b852740f554ad64cc97657d5c73230013952e0c036c0cdd04bd47fe4a); /* statement */ 
require(members[msg.sender].level == XBRTypes.MemberLevel.ACTIVE ||
                members[msg.sender].level == XBRTypes.MemberLevel.VERIFIED, "SENDER_NOT_A_MEMBER");coverage_0x2b4f46cc(0xda719cf58ecd15e1ff4cafd2493673dce394acc042a62c430841a84de2ff2687); /* assertPost */ 


        // market must not yet exist (to generate a new marketId: )
coverage_0x2b4f46cc(0x1b282b70bbd137a3b24f56354290bbf356263fa4e6be87d33d2b573601941cc8); /* line */ 
        coverage_0x2b4f46cc(0x9f4fb3ffc2ed00599a223df5a39b77684c6caf8b64b010f6d6ee1d161252d328); /* assertPre */ 
coverage_0x2b4f46cc(0xc7d121a879690c8f0cc2d5ca6904521a6b5b0467105811225abf7fefe66ed86a); /* statement */ 
require(markets[marketId].owner == address(0), "MARKET_ALREADY_EXISTS");coverage_0x2b4f46cc(0xd54fa2e695fb51e88ba78075081518845a1a0da9604bfb135c955abb912e176c); /* assertPost */ 


        // must provide a valid market maker address already when creating a market
coverage_0x2b4f46cc(0x4434795c95c36bcf67a42f41cd7ca2c7d9c820661f9993f7224ac8954c95527f); /* line */ 
        coverage_0x2b4f46cc(0x7f9c71cf406710520eb6b6119157f7207c1e652aec3f37ca6d4647ac3b072e74); /* assertPre */ 
coverage_0x2b4f46cc(0xee1f7cee9183c49389f38dc644953ee4a4edc0daa3b46a1e00476739acc6eab9); /* statement */ 
require(maker != address(0), "INVALID_MAKER");coverage_0x2b4f46cc(0x7dbd3f2d7cd3ec7093064d3cc3cb5cc6ec9849eaf2e95bf5ae8c98bfaa5d9520); /* assertPost */ 


        // the market maker can only work for one market
coverage_0x2b4f46cc(0x519b7176b67392d823f38f3bfb11f29f495b16613610818eb134c459cb17b8f2); /* line */ 
        coverage_0x2b4f46cc(0x92e01b934839fbe792b8404eb94a38481232d5852dfd77362c09f9701dcd6960); /* assertPre */ 
coverage_0x2b4f46cc(0xd3a064fc8b5f1849afe2f81e6447fcade56efd9ded70f7a7cac16a605dfda02d); /* statement */ 
require(marketsByMaker[maker] == bytes16(0), "MAKER_ALREADY_WORKING_FOR_OTHER_MARKET");coverage_0x2b4f46cc(0xd58b1d337b46cc6cfa0baf6391fba3fe0dce269d44e04f489e8b667ecf8f0b64); /* assertPost */ 


        // provider security must be non-negative (and obviously smaller than the total token supply)
coverage_0x2b4f46cc(0x3936730d091feb651353e6ae1ebc94b8af13027f3418f5a2b2f536f8ee836549); /* line */ 
        coverage_0x2b4f46cc(0x1f654f40743760f422fe3f76d8ff905c9fba2be9205e2e3352f0e09df60abb75); /* assertPre */ 
coverage_0x2b4f46cc(0xc7de0a2670864602035ae038db25a1d9a7668dc6eeab702683ae74ebeebe2e14); /* statement */ 
require(providerSecurity >= 0 && providerSecurity <= token.totalSupply(), "INVALID_PROVIDER_SECURITY");coverage_0x2b4f46cc(0xab417b3aa72cbbcbed38f461d88670f460f567bedc2aeb5857707646b0c16fc8); /* assertPost */ 


        // consumer security must be non-negative (and obviously smaller than the total token supply)
coverage_0x2b4f46cc(0xc4677422bf930b707b99783ddc9d7a326f380aaeca88f1d2080345883d76af5e); /* line */ 
        coverage_0x2b4f46cc(0xbbfa1999e9d013a2ff8a8b167d9a3edd7387187a721116f464d54eeaa5252314); /* assertPre */ 
coverage_0x2b4f46cc(0x769d133d31892c768ba286e1fcac8d5c43584b197122c3a7b7c10fe1d97afecc); /* statement */ 
require(consumerSecurity >= 0 && consumerSecurity <= token.totalSupply(), "INVALID_CONSUMER_SECURITY");coverage_0x2b4f46cc(0xb54a42132d6a42e49a255fd1b8a10e85cade2bfa5587ef2dc1f0615b2bd786b2); /* assertPost */ 


        // FIXME: treat market fee
coverage_0x2b4f46cc(0xe79785eadd97e56555c311e45dbb9d560dd808b9e75b58c7c9be928562aad0d3); /* line */ 
        coverage_0x2b4f46cc(0x8c4c34e107c8a59b397d14f5dee6ec1517ce52381d27ae0145f90196e4fb5fd8); /* assertPre */ 
coverage_0x2b4f46cc(0xe959644c9c40e689091a28a85a6a100e499951310cdedfc3a9d77e0edffa8fe9); /* statement */ 
require(marketFee >= 0 && marketFee < (token.totalSupply() - 10**7) * 10**18, "INVALID_MARKET_FEE");coverage_0x2b4f46cc(0x717cb61d00044a2903b00fc065a60d5e557c142da5d1bcd8207e9340db5360a3); /* assertPost */ 


        // now remember out new market ..
coverage_0x2b4f46cc(0xe7a31211b6cb464b1ea31b56ad8d3573466d4e4a200e7c1613a14a76c15bfb9d); /* line */ 
        coverage_0x2b4f46cc(0xa2c756a3b53de983759b31c2dc211fa7eb987018ef933ad7079fefc9f1b617ed); /* statement */ 
uint created = block.timestamp;
coverage_0x2b4f46cc(0xb6ca8e1db49d5310f11f754bc07c604f577273feaa9f65ceb07d5de4baf060c3); /* line */ 
        coverage_0x2b4f46cc(0x8a494715c071e2063faba5087a3dc6629b805c22e68af78b28fce87ff0d34e07); /* statement */ 
markets[marketId] = XBRTypes.Market(created, marketSeq, msg.sender, terms, meta, maker,
            providerSecurity, consumerSecurity, marketFee, new address[](0), new address[](0));

        // .. and the market-maker-to-market mapping
coverage_0x2b4f46cc(0x4050f05d78c465a735ff64c8c4d475ad4512917ca6ed42fe1fa5efd3a3f17b8c); /* line */ 
        coverage_0x2b4f46cc(0x505fcd0bde56b3704043e208b125cbc3d612e07843407c57687cc4c14fbe1bd8); /* statement */ 
marketsByMaker[maker] = marketId;

        // .. and the market-owner-to-market mapping
coverage_0x2b4f46cc(0xa2e271093c473ff586b61f47042fc4781ec7d936e74420ce287d4e3f73160f3a); /* line */ 
        coverage_0x2b4f46cc(0x72bcd90bd83181e032a1e99666aead52b97411476b2a5c72444595fe0f2d6e68); /* statement */ 
marketsByOwner[msg.sender].push(marketId);

        // .. and list of markst IDs
coverage_0x2b4f46cc(0xb46e0c74b82275dcc7b0449e314b6d0d671cb1be2cd2a04ec3ff18c511dbf47c); /* line */ 
        coverage_0x2b4f46cc(0x5bc67b1fd4240c2602a820e078296624763c9e1eba86344eb4b650a709508bfc); /* statement */ 
marketIds.push(marketId);

        // increment market sequence for next market
coverage_0x2b4f46cc(0x6412cb055258904c8bb4ad9be957749646ccd60c770460b02e7b6d3687b3caca); /* line */ 
        coverage_0x2b4f46cc(0xa17ee2b978e77610a911ef342b38e8c3badde3e3eb54d76bb1335c4661d57464); /* statement */ 
marketSeq = marketSeq + 1;

        // notify observers (eg a dormant market maker waiting to be associated)
coverage_0x2b4f46cc(0xb562603b7c818f6264962dbda2d4a652105c0b87b4769598c35262526117ef95); /* line */ 
        coverage_0x2b4f46cc(0xa6e73d12dd198db84f8a59946f6acc30eb40984e5cb82bfb60b1ab29e79b2bd3); /* statement */ 
emit MarketCreated(marketId, created, marketSeq, msg.sender, terms, meta, maker,
            providerSecurity, consumerSecurity, marketFee);
    }

    function countMarkets() public view returns (uint) {coverage_0x2b4f46cc(0x5eb5d5ecc81e2a57208d453bf21d5e323d7f25c645a5915c265aa372375457ba); /* function */ 

coverage_0x2b4f46cc(0xb8a84e4e40eb1af222e0467732a92586abaf7397bef9bd1bd40c9efbcf408383); /* line */ 
        coverage_0x2b4f46cc(0x71a183485f2f74bd8bda682984960c1df550531ab899aac6e53a8b64b49f94bb); /* statement */ 
return marketIds.length;
    }

    function getMarketsByOwner(address owner, uint index) public view returns (bytes16) {coverage_0x2b4f46cc(0xcfcec4a1a23c176087dbccb99e810680127128126e32778a7ced3516e52c367c); /* function */ 

coverage_0x2b4f46cc(0x33b3bcefdcdb6a16698d0152e73cc0a62c9113065b1ee21702ec7f4a979f748e); /* line */ 
        coverage_0x2b4f46cc(0xedbb8f7fbf341b9f07fd29ae1cd43e34ede283bb440ee38f30851e2ebff65117); /* statement */ 
return marketsByOwner[owner][index];
    }

    function countMarketsByOwner(address owner) public view returns (uint) {coverage_0x2b4f46cc(0xc8e09768af0368123ce4b7d051dae3d9874746b1d444fa952d596be247e33247); /* function */ 

coverage_0x2b4f46cc(0x2990744da6398b4a045911ea21ad4182ce95bc96ccd1c8828110d20a001bb454); /* line */ 
        coverage_0x2b4f46cc(0xcf8cad0b7ded1797b84520e4b60790aedd463d64f1e8f91c5f6fd8e30dc4eec7); /* statement */ 
return marketsByOwner[owner].length;
    }

    function getMarketActor (bytes16 marketId, address actor, uint8 actorType) public view
        returns (uint, uint256, string memory)
    {coverage_0x2b4f46cc(0x3a35371dec890e0a99a5d46dab649777aa2f68fea3d0cea82048fd830cc33efc); /* function */ 


        // the market must exist
coverage_0x2b4f46cc(0xeb7a3f6177e419d074e80a00ec0107743820f32cd970f9e8d60078b0fb7d418b); /* line */ 
        coverage_0x2b4f46cc(0x03f8ff740ad7cf1acaef530824fa0d9bf27da668915437a858cf23b70ea9a5bd); /* assertPre */ 
coverage_0x2b4f46cc(0x3ee1304d5dac3028892f39219785479d0819e90ef3e9a671b22776b37e395789); /* statement */ 
require(markets[marketId].owner != address(0), "NO_SUCH_MARKET");coverage_0x2b4f46cc(0xb533be503fe9b1c5228c4b75b3244b6ebbe0500d47b9541124e7f2e10434adbb); /* assertPost */ 


        // must ask for a data provider (seller) or data consumer (buyer)
coverage_0x2b4f46cc(0xe416986bbecbc9f95633a8a3b99a723e417f8232accbfe65d8d9691de74df1e2); /* line */ 
        coverage_0x2b4f46cc(0x4390510e8f1e1b1787069331a0b9c0181d0e3aafbc1c2222f809bfc397547558); /* assertPre */ 
coverage_0x2b4f46cc(0xede45492ee78167d4d017c8ca1b9dde7961fca066cfcbd15b07b8458db88abb6); /* statement */ 
require(actorType == uint8(XBRTypes.ActorType.PROVIDER) ||
                actorType == uint8(XBRTypes.ActorType.CONSUMER), "INVALID_ACTOR_TYPE");coverage_0x2b4f46cc(0x416a4019934a75ffeb7b279481ea524462622513166a6e29d880af89d353a86e); /* assertPost */ 


coverage_0x2b4f46cc(0xc35505b9e82d7993bbdf512b81b16682aff541953fb3fe4be4f561b84b16a49c); /* line */ 
        coverage_0x2b4f46cc(0xe536b82d99b4b3906fc94cee90bdb197c52205a0467ddf4e2886b30eb3c00a97); /* statement */ 
if (actorType == uint8(XBRTypes.ActorType.CONSUMER)) {coverage_0x2b4f46cc(0xf82d0f89272a1e98935f4d9b1e897b53edc6226f2d0e829f43fddab76c194c22); /* branch */ 

coverage_0x2b4f46cc(0x379e52aaa5deac45be9249b3e0b9a814fc5a24d5785a368e7bb3864365497b10); /* line */ 
            coverage_0x2b4f46cc(0x0e91f4acc14c5616f6dc62f1e4fc3171c9ddb5699e12f758682c909756e3e240); /* statement */ 
XBRTypes.Actor storage _actor = markets[marketId].consumerActors[actor];
coverage_0x2b4f46cc(0xaaeb828a01f87cd375bd9088a086d7bf7b5f0a1b723696cb84272874950237cf); /* line */ 
            coverage_0x2b4f46cc(0xf990a7e9358cc471f90bc5c9d4c1714a55b057a6aa83329f5d60f4cd9ee54aac); /* statement */ 
return (_actor.joined, _actor.security, _actor.meta);
        } else {coverage_0x2b4f46cc(0x7e3260bf3988defdef3d3bb766875db635c64af6c763cc9fe13da1ea5cd422aa); /* branch */ 

coverage_0x2b4f46cc(0xa40cad6a0802878167f55b8f1400800aded10a648f13d505f430c42f2f4a1464); /* line */ 
            coverage_0x2b4f46cc(0xcf1d360d9adc898067d4fa2f60d875d793f964e6b038a77fc77bb0512f960564); /* statement */ 
XBRTypes.Actor storage _actor = markets[marketId].providerActors[actor];
coverage_0x2b4f46cc(0xc1582a4b0a59790745942f23a6898983cedb50d026c0a1a57258e791a6da1c0b); /* line */ 
            coverage_0x2b4f46cc(0x2edc42f69a322ebacaa1db52b79d9af5c88e2f151c5610862bf77eb0f7a23ae2); /* statement */ 
return (_actor.joined, _actor.security, _actor.meta);
        }
    }

    // /**
    //  * Update market information, like market terms, metadata or maker address.
    //  *
    //  * @param marketId The ID of the market to update.
    //  * @param terms When terms should be updated, provide a string of non-zero length with
    //  *              an IPFS Multihash pointing to the new ZIP file with market terms.
    //  * @param meta When metadata should be updated, provide a string of non-zero length with
    //  *             an IPFS Multihash pointing to the new RDF/Turtle file with market metadata.
    //  * @param maker When maker should be updated, provide a non-zero address.
    //  * @param providerSecurity Provider security to set that will apply for new members (providers) joining
    //  *                         the market. It will NOT apply to current market members.
    //  * @param consumerSecurity Consumer security to set that will apply for new members (consumers) joining
    //  *                         the market. It will NOT apply to current market members.
    //  * @param marketFee New market fee to set. The new market fee will apply to all new payment channels
    //  *                  opened. It will NOT apply to already opened (or closed) payment channels.
    //  * @return Flag indicating weather the market information was actually updated or left unchanged.
    //  */
    // function updateMarket(bytes16 marketId, string memory terms, string memory meta, address maker,
    //     uint256 providerSecurity, uint256 consumerSecurity, uint256 marketFee) public returns (bool) {

    //     Market storage market = markets[marketId];

    //     require(market.owner != address(0), "NO_SUCH_MARKET");
    //     require(market.owner == msg.sender, "NOT_AUTHORIZED");
    //     //require(marketsByMaker[maker] == bytes16(0), "MAKER_ALREADY_WORKING_FOR_OTHER_MARKET");
    //     require(marketFee >= 0 && marketFee < (10**9 - 10**7) * 10**18, "INVALID_MARKET_FEE");

    //     bool wasChanged = false;

    //     // for these knobs, only update when non-zero values provided
    //     if (maker != address(0) && maker != market.maker) {
    //         markets[marketId].maker = maker;
    //         wasChanged = true;
    //     }

    //     /* FIXME: find out why including the following code leas to "out of gas" issues when deploying contracts

    //     if (bytes(terms).length > 0 && keccak256(abi.encode(terms)) != keccak256(abi.encode(market.terms))) {
    //         markets[marketId].terms = terms;
    //         wasChanged = true;
    //     }
    //     if (bytes(meta).length > 0 && keccak256(abi.encode(meta)) != keccak256(abi.encode(market.meta))) {
    //         markets[marketId].meta = meta;
    //         wasChanged = true;
    //     }
    //     */

    //     // for these knobs, we allow updating to zero value
    //     if (providerSecurity != market.providerSecurity) {
    //         markets[marketId].providerSecurity = providerSecurity;
    //         wasChanged = true;
    //     }
    //     if (consumerSecurity != market.consumerSecurity) {
    //         markets[marketId].consumerSecurity = consumerSecurity;
    //         wasChanged = true;
    //     }
    //     if (marketFee != market.marketFee) {
    //         markets[marketId].marketFee = marketFee;
    //         wasChanged = true;
    //     }

    //     if (wasChanged) {
    //         emit MarketUpdated(marketId, market.marketSeq, market.owner, market.terms, market.meta, market.maker,
    //                 market.providerSecurity, market.consumerSecurity, market.marketFee);
    //     }

    //     return wasChanged;
    // }

    // /**
    //  * Close a market. A closed market will not accept new memberships.
    //  *
    //  * @param marketId The ID of the market to close.
    //  */
    // function closeMarket (bytes16 marketId) public view {
    //     require(markets[marketId].owner != address(0), "NO_SUCH_MARKET");
    //     require(markets[marketId].owner == msg.sender, "NOT_AUTHORIZED");
    //     // FIXME
    //     // - remove market ID from marketIds
    //     require(false, "NOT_IMPLEMENTED");
    // }

    /**
     * Join the given XBR market as the specified type of actor, which must be PROVIDER or CONSUMER.
     *
     * @param marketId The ID of the XBR data market to join.
     * @param actorType The type of actor under which to join: PROVIDER or CONSUMER.
     * @param meta The XBR market provider/consumer metadata. IPFS Multihash pointing to a JSON file with metadata.
     */
    function joinMarket (bytes16 marketId, uint8 actorType, string memory meta) public returns (uint256) {coverage_0x2b4f46cc(0x7870d1c8cbbecde2fa1ea6746d89107be0ff94afaec286c7d7ab26d6807b215e); /* function */ 


        // the joining sender must be a registered member
coverage_0x2b4f46cc(0x125d7f53f968ebd1905aceb81cd98015a34e4c95ea4616be207cb3b8aaa92bc3); /* line */ 
        coverage_0x2b4f46cc(0xb7a29e54270d8875edb84b4d5f12750f570ccb963c27951a783f9fbb6661e6d6); /* assertPre */ 
coverage_0x2b4f46cc(0x9d01c90f6f738f75626aa6d8a49e59459fe675c66901ff93f803292952d5139e); /* statement */ 
require(members[msg.sender].level == XBRTypes.MemberLevel.ACTIVE, "SENDER_NOT_A_MEMBER");coverage_0x2b4f46cc(0xa7ec7fbebd8ce94d4914d33958caec8497d91973a9a1f8507f01c947513f4b28); /* assertPost */ 


        // the market to join must exist
coverage_0x2b4f46cc(0x1d109e56ae852d3828dc69adbb79a7edcf0b6fee45a8d6de2a837953b8925c1e); /* line */ 
        coverage_0x2b4f46cc(0x2bcaf047a543b62c9a85bd4f5a9a62a5a1630b5fa8b9c83eeec814bc5bd63eae); /* assertPre */ 
coverage_0x2b4f46cc(0x8046957158d30476f6e4531e06514ea8d5cc5159179a4868d798bbaa8441ea30); /* statement */ 
require(markets[marketId].owner != address(0), "NO_SUCH_MARKET");coverage_0x2b4f46cc(0x8c95ef8c793d7a99fac9314968effdd3c6e0e7f45375d9fbc1823fcb1659fffa); /* assertPost */ 


        // the market owner cannot join as an actor (provider/consumer) in the market
coverage_0x2b4f46cc(0xc6bd5634db7899d3edbe03c3db528c3d7e663213e39c7dc1dac5d5660381e5d4); /* line */ 
        coverage_0x2b4f46cc(0x816bafbf1ba38e860f915099553bce8df2b738c9a13f0bf431adb495cace23d6); /* assertPre */ 
coverage_0x2b4f46cc(0xa74ab006caef40cd551017ab6e75db68db0812cba8d999e14811b09f45f07dfb); /* statement */ 
require(markets[marketId].owner != msg.sender, "SENDER_IS_OWNER");coverage_0x2b4f46cc(0xd90853c086f2dfa0f099cd46a09a6ecc68bcdc5450953a0bd9851759043f09e8); /* assertPost */ 


        // the joining member must join as a data provider (seller) or data consumer (buyer)
coverage_0x2b4f46cc(0xfc905f9dcccf7d0c20e5c741f4f8116a804fa358ecfbfaf5408e009301effea2); /* line */ 
        coverage_0x2b4f46cc(0x2541e93d5c602040606e9a53eb91ba3305355caad592aef7774e272f4740653e); /* assertPre */ 
coverage_0x2b4f46cc(0xe5b96ab0164b354ef80ceca30938a6f0a58106defc690c620e8613f20d86ba93); /* statement */ 
require(actorType == uint8(XBRTypes.ActorType.PROVIDER) ||
                actorType == uint8(XBRTypes.ActorType.CONSUMER), "INVALID_ACTOR_TYPE");coverage_0x2b4f46cc(0x0145e4a71d5329cb87925f337d416243a1965b70241509b095a6739906962d2d); /* assertPost */ 


        // get the security amount required for joining the market (if any)
coverage_0x2b4f46cc(0x1acd1afdf0b38f9d2922d4cd3897972393a60d736b2ffdba76d98a3ce4d886a9); /* line */ 
        coverage_0x2b4f46cc(0x4ed069115b013ea0a008b911a816838f2871aa4753bdbe031bbd25c7ce421a0b); /* statement */ 
uint256 security;
        // if (uint8(actorType) == uint8(ActorType.PROVIDER)) {
coverage_0x2b4f46cc(0x007ff30474449e6de820b0efa0b71cb795cc6d8887f60b0cdd7f936d952d821a); /* line */ 
        coverage_0x2b4f46cc(0x9f03e497ef064c1be80feacf0e025cabf997c523514d94e3823ba38a682d0be2); /* statement */ 
if (actorType == uint8(XBRTypes.ActorType.PROVIDER)) {coverage_0x2b4f46cc(0x0c2bd0eaeefffe52a4a40b069c4909393ac3300b4e9968a9a0e5ad254a0730da); /* branch */ 

            // the joining member must not be joined as a provider already
coverage_0x2b4f46cc(0x1f4c6b5dde96eaa10246dd55e323a0649e96c76a1aa3ce0ae37f16e27aa7acad); /* line */ 
            coverage_0x2b4f46cc(0x3082e10c304facde881357f0fdd9d6034b0332186f642b3343bafa0ca9ea8b4e); /* assertPre */ 
coverage_0x2b4f46cc(0x49e72e6dcd40a8092e578aaf1f0b279638d2f4ba57e74ce04d07317db4e7340d); /* statement */ 
require(uint8(markets[marketId].providerActors[msg.sender].joined) == 0, "ALREADY_JOINED_AS_PROVIDER");coverage_0x2b4f46cc(0xf200409d38a7f68e442921003441188b9fd2c6cd60aea4407c9d67d00accf275); /* assertPost */ 

coverage_0x2b4f46cc(0x344a5ae0abb3e57d41846b5cb93e0c3b7b7df89427e402e62cc6bc5b7911f14e); /* line */ 
            coverage_0x2b4f46cc(0xad342d81e27cd5bf6c2d7c135cd9dabbb5ff1deac08eef23bf00e4ca2a4b845a); /* statement */ 
security = markets[marketId].providerSecurity;
        } else  {coverage_0x2b4f46cc(0x9e5652cfc984f0ebb5f85407977e468f076d751ec2acdfac8f4fce5347cf4f79); /* branch */ 

            // the joining member must not be joined as a consumer already
coverage_0x2b4f46cc(0x0ed14479914825eb7c48c4284fc8010e79d8fdd0c152524360a3fc6831c7e033); /* line */ 
            coverage_0x2b4f46cc(0x124d1d7b89b206ef854064735c9298c1420ce03715078a088329c2fdaef9e000); /* assertPre */ 
coverage_0x2b4f46cc(0x9f92fec99dd2f9330f58c8562e87e229e382eef213b6ab1febd37cd7af40a226); /* statement */ 
require(uint8(markets[marketId].consumerActors[msg.sender].joined) == 0, "ALREADY_JOINED_AS_CONSUMER");coverage_0x2b4f46cc(0xdc5bbddc5a2a8129f35469e20a0b78fdd319063e51bb01eeb60c373cf868ac86); /* assertPost */ 

coverage_0x2b4f46cc(0x0930660c71ca5fe43ae8e2e689f60d073fb654d72a5baf98f11d386d2878072f); /* line */ 
            coverage_0x2b4f46cc(0x43177820a8b675827afa19b9d1e71236e74594d5d32f6f40dc155da21134f364); /* statement */ 
security = markets[marketId].consumerSecurity;
        }

coverage_0x2b4f46cc(0xa144d3653bb7a6b41e5844f99db83b10ba7cf834a920e7fda8650670a5126ae7); /* line */ 
        coverage_0x2b4f46cc(0xb0257252d124dece1daba8786f1245c9eacc4ad0a8041b2a6ee08e8470cc0cab); /* statement */ 
if (security > 0) {coverage_0x2b4f46cc(0x2a81d2359a3c7ec9fd35c4169fc2a976935ecfce92e46937ad22072a5b8d9d73); /* branch */ 

            // Transfer (if any) security to the market owner (for ActorType.CONSUMER or ActorType.PROVIDER)
coverage_0x2b4f46cc(0x7039facf4e6aa818c92abccf75a50315a5ddd3b731bacf6b0cad05e9950cc63b); /* line */ 
            coverage_0x2b4f46cc(0x3d7c03fbfc76632ef7dac5c6c9ab7fd4a2a540282414cd0e9020648021905368); /* statement */ 
bool success = token.transferFrom(msg.sender, markets[marketId].owner, security);
coverage_0x2b4f46cc(0x9615c276ebee1a28d43ae1b8cde6d0c2750cc27a220cdc95630682b89ac5cf70); /* line */ 
            coverage_0x2b4f46cc(0xcd0ea77c53fa95b4646ca60f68726ff8a1768caf4e1cf4b759884b926e083311); /* assertPre */ 
coverage_0x2b4f46cc(0xa5157131550c58e789b4e784214f389b6dc1c7bb292d3ac5c0b55de2a3c5d93f); /* statement */ 
require(success, "JOIN_MARKET_TRANSFER_FROM_FAILED");coverage_0x2b4f46cc(0x08afb337bcc72b2e5b778711243e492707c6fea293495f26af24761f80b6780b); /* assertPost */ 

        }else { coverage_0x2b4f46cc(0x4a2fefc9bc05ab68218ddd02f365ef561f23d4e900e709ff20e9c0594c831e78); /* branch */ 
}

        // remember actor (by actor address) within market
coverage_0x2b4f46cc(0x1ebdebcc49b0a010c3adb26990dfd8eedb5a6b012025e8e666bd4e20ee709135); /* line */ 
        coverage_0x2b4f46cc(0x2fdaea2bc5fc37ca360ac1df8d580669615ec20a1d5d34fc7fe4ce5e1c7f159c); /* statement */ 
uint joined = block.timestamp;
coverage_0x2b4f46cc(0x984cbf51b80273e90051ba1f5985717524cb699b0e466e53a89b49af8989e5a0); /* line */ 
        coverage_0x2b4f46cc(0x2896cd8a4236c5bf7805280cc4508faf304995568648f4cd6034e06d11c9656d); /* statement */ 
if (actorType == uint8(XBRTypes.ActorType.PROVIDER)) {coverage_0x2b4f46cc(0x7f54362fbe20cce2413f6743631443bcf971b9f1fd2ec0266a394ed49dc4a820); /* branch */ 

coverage_0x2b4f46cc(0x3ee9f907d943af3c827adaee4689e25cdcb8da24057ecbd9993ef1a507018470); /* line */ 
            coverage_0x2b4f46cc(0x82816ae7bb11a7a8bb5db486d86d8e37aff071e6a3322c75e36005fc614b6741); /* statement */ 
markets[marketId].providerActors[msg.sender] = XBRTypes.Actor(joined, security, meta, new address[](0));
coverage_0x2b4f46cc(0x87ae1e82dd8c546e091d8a901a362a17ee35ac992c83add3318d47af8c371f30); /* line */ 
            coverage_0x2b4f46cc(0xfd15640e94081391fd9b25812ece4fb8dcb69c471fdd5954b8fdcadcf38af73c); /* statement */ 
markets[marketId].providerActorAdrs.push(msg.sender);
        } else {coverage_0x2b4f46cc(0x2056b90a6d6927c368edb05541a4352f42d6164aa44be552ef42281a65cbe902); /* branch */ 

coverage_0x2b4f46cc(0xb8df8f8907f27d83962cc3fd6a23ccb36d69635410e0752dbe34f2bec23b30d4); /* line */ 
            coverage_0x2b4f46cc(0xaf879b85a54e102c9df4499272cbc07d900a5e2439e21fdae22a3a87b295049d); /* statement */ 
markets[marketId].consumerActors[msg.sender] = XBRTypes.Actor(joined, security, meta, new address[](0));
coverage_0x2b4f46cc(0xd334e8c7d7e2bf0bdc158237a0cd4e67db37de02a40250341e86d59ab2aac3e3); /* line */ 
            coverage_0x2b4f46cc(0xf5f5db279e5b13eef78ab1fd38b16cf31268f1317fd59c12137b4d0b2cadc20d); /* statement */ 
markets[marketId].consumerActorAdrs.push(msg.sender);
        }

        // emit event ActorJoined(bytes16 marketId, address actor, ActorType actorType, uint joined,
        //                        uint256 security, string meta)
coverage_0x2b4f46cc(0x81ff435082fc7737c091230ade2b781be1cfa8bf4a14dd4c2e7df95ba46a4f65); /* line */ 
        coverage_0x2b4f46cc(0xb453f1d4461b2970898cdb0ee3aa361d4477c31e2027bac28c0b8256a75857c8); /* statement */ 
emit ActorJoined(marketId, msg.sender, actorType, joined, security, meta);

        // return effective security transferred
coverage_0x2b4f46cc(0xc9a855d84226cac629f9c4dd966dfb23b7f7cd3dd3e01a5bd8b5992b055e78ea); /* line */ 
        coverage_0x2b4f46cc(0x41911c5f7b2e49392b3f722a22ebce2edc6ea2e78c5d65ba8950ad2b2da6eacc); /* statement */ 
return security;
    }

    // FIXME: adding the following (empty!) function runs into "out of gas" during deployment, even though
    // deployment without that function succeeds with:
    //
    //    > gas used:            5502038
    //
    // function joinMarketFor (address member, bytes16 marketId, uint8 actorType,
    //     string memory meta, bytes memory signature) public returns (uint256) {
    //         return 0;
    // }

/*

    function joinMarketFor (address member, bytes16 marketId, uint8 actorType,
        string memory meta, bytes memory signature) public returns (uint256) {

        // // the joining member must be a registered member
        // require(members[member].level == MemberLevel.ACTIVE, "SENDER_NOT_A_MEMBER");

        // // the market to join must exist
        // require(markets[marketId].owner != address(0), "NO_SUCH_MARKET");

        // // the market owner cannot join as an actor (provider/consumer) in the market
        // require(markets[marketId].owner != member, "SENDER_IS_OWNER");

        // // the joining member must join as a data provider (seller) or data consumer (buyer)
        // require(actorType == uint8(ActorType.PROVIDER) ||
        //         actorType == uint8(ActorType.CONSUMER), "INVALID_ACTOR_TYPE");

        // // get the security amount required for joining the market (if any)
        uint256 security = 0;

        // if (actorType == uint8(ActorType.PROVIDER)) {
        //     // the joining member must not be joined as a provider already
        //     require(uint8(markets[marketId].providerActors[member].joined) == 0, "ALREADY_JOINED_AS_PROVIDER");
        //     security = markets[marketId].providerSecurity;
        // } else  {
        //     // the joining member must not be joined as a consumer already
        //     require(uint8(markets[marketId].consumerActors[member].joined) == 0, "ALREADY_JOINED_AS_CONSUMER");
        //     security = markets[marketId].consumerSecurity;
        // }

        // require(verify(member, EIP712MarketJoin(1, 1, address(this), member, marketId, actorType, meta), signature),
        //     "INVALID_MARKET_JOIN_SIGNATURE");

        // if (security > 0) {
        //     // Transfer (if any) security to the market owner (for ActorType.CONSUMER or ActorType.PROVIDER)
        //     bool success = token.transferFrom(member, markets[marketId].owner, security);
        //     require(success, "JOIN_MARKET_TRANSFER_FROM_FAILED");
        // }

        // // remember actor (by actor address) within market
        // uint joined = block.timestamp;
        // if (actorType == uint8(ActorType.PROVIDER)) {
        //     markets[marketId].providerActors[member] = Actor(joined, security, meta, new address[](0));
        //     markets[marketId].providerActorAdrs.push(member);
        // } else {
        //     markets[marketId].consumerActors[member] = Actor(joined, security, meta, new address[](0));
        //     markets[marketId].consumerActorAdrs.push(member);
        // }

        // emit ActorJoined(marketId, member, actorType, joined, security, meta);

        // return effective security transferred
        return security;
    }
*/

    // /**
    //  * As a market actor (participant) currently member of a market, leave that market.
    //  * A market can only be left when all payment channels of the sender are closed (or expired).
    //  *
    //  * @param marketId The ID of the market to leave.
    //  */
    // function leaveMarket (bytes16 marketId) public view {
    //     require(markets[marketId].owner != address(0), "NO_SUCH_MARKET");
    //     // FIXME
    //     // - remove sender actor from markets[marketId].providerActorAdrs|consumerActorAdrs
    //     require(false, "NOT_IMPLEMENTED");
    // }

    /**
     * Open a new payment channel and deposit an amount of XBR token for off-chain consumption.
     * Must be called by the data consumer (XBR buyer) and an off-chain buyer delegate address must be given.
     *
     * @param marketId The ID of the market to open a payment channel within.
     * @param recipient Recipient of the earned off-chain transaction amounts of this single channel,
     *                  commonly the market operator.
     * @param delegate The address of the (offchain) consumer delegate allowed to consume the channel.
     * @param amount Amount of XBR Token to deposit into the payment channel (the initial off-chain balance).
     * @param timeout Channel timeout which will apply.
     */
    function openPaymentChannel (bytes16 marketId, address recipient, address delegate,
        uint256 amount, uint32 timeout) public returns (address paymentChannel) {coverage_0x2b4f46cc(0x15f3154161f5cb94285b297f02f82f138803073d0bd097d5e1a83b5d4272c674); /* function */ 


        // market must exist
coverage_0x2b4f46cc(0x6314163c563a7095e7fd6f9ac6e9366e47b4df9843298e6aa72419bab011c4ec); /* line */ 
        coverage_0x2b4f46cc(0x19d9f8f61fee9233bfaee8663573db83fd51e5a40eee4440ed74c5463856d14a); /* assertPre */ 
coverage_0x2b4f46cc(0x716fbfeb3384845a814071e556fba3041a8f0ab629b68ce69844a6a57474e595); /* statement */ 
require(markets[marketId].owner != address(0), "NO_SUCH_MARKET");coverage_0x2b4f46cc(0x8f777ecb04ccef6e00db9e51746fa4f892da8c11b3c6de9d0e23832bbea66651); /* assertPost */ 


        // sender must be consumer in the market
coverage_0x2b4f46cc(0xf7c636b19a8075b3bc2dfca67ef0542918a61fca6224049295aabf37ae201838); /* line */ 
        coverage_0x2b4f46cc(0x0d841939cea176f35264a6289f0269dcb96400473ae850ff22612bf0aaec17b3); /* assertPre */ 
coverage_0x2b4f46cc(0x19bfcfdec6a49735660f62f3420385ed825d9c5440a010ad2aa7aef221e175d6); /* statement */ 
require(uint8(markets[marketId].consumerActors[msg.sender].joined) != 0, "NO_CONSUMER_ROLE");coverage_0x2b4f46cc(0xa86c1d78618f8ddf5916b2553a8070e63bd831587be3e30596ddfdfd43f59802); /* assertPost */ 


        // technical recipient of the unidirectional, half-legged channel must be the
        // owner (operator) of the market
coverage_0x2b4f46cc(0x569a1fc9fbdad795b0e962a868f381dc4b996bb164163b4c7b26df5dfa20576a); /* line */ 
        coverage_0x2b4f46cc(0xc0ac485a85707fcb9f75c9beb52fdd85c79c520375c0baf1857058668f2f57ef); /* assertPre */ 
coverage_0x2b4f46cc(0x81d00062ee4318ef7901cbc16ea6ff8e375f63a168ddc50d4794c4c99ce72948); /* statement */ 
require(recipient == markets[marketId].owner, "INVALID_CHANNEL_RECIPIENT");coverage_0x2b4f46cc(0x5c887f45c5064692a2c4c7c8dff5759cdacb545c26b7940efe094f36532b31a9); /* assertPost */ 


        // must provide a valid off-chain channel delegate address
coverage_0x2b4f46cc(0x072aca5a5b3a278b52da1572ca32daed5ffc8591da22d33ade0e2d5b92e5142f); /* line */ 
        coverage_0x2b4f46cc(0xde818f38c41e07d2135bac0f9e52009ce431a171cfd9e0fe194a1117e62930af); /* assertPre */ 
coverage_0x2b4f46cc(0x11c1051bb8eb1ca334b9c6de49cef04a6f446e9df656784312f6fca4cdfb027c); /* statement */ 
require(delegate != address(0), "INVALID_CHANNEL_DELEGATE");coverage_0x2b4f46cc(0x7afe601d480d02f21a35eea383712e82eb6773e25c226ee0ac51c781a8d4c68d); /* assertPost */ 


        // payment channel amount must be positive
coverage_0x2b4f46cc(0x9db66e8e71abde18c65ddc1e2e174b5fb923cd0217023a60d78dc4b5783a1696); /* line */ 
        coverage_0x2b4f46cc(0xaa0722a2658b7f44183ae1dbe9bf827dc8e8407b06ab98881d7620aad622ea66); /* assertPre */ 
coverage_0x2b4f46cc(0xc78076c32c816a163975fd1fdb9c067584e6f5e2dccbd9a5899db84e4c32f6f6); /* statement */ 
require(amount > 0 && amount <= token.totalSupply(), "INVALID_CHANNEL_AMOUNT");coverage_0x2b4f46cc(0x3691ccb1a9dcc71e685a297e2cf2acfd4b3866befeba0cc7a4343053887acd75); /* assertPost */ 


        // payment channel timeout can be [0 seconds - 10 days[
coverage_0x2b4f46cc(0x3befe35b5bb2c0687efb133f1750a6149ad6de51c0bc33fda700ceca794587f1); /* line */ 
        coverage_0x2b4f46cc(0x7368d79dac2bb4e2bc8cc3ea0f3d2ab6768e4a9d870e5cc95cf12443939443aa); /* assertPre */ 
coverage_0x2b4f46cc(0x752c244ccfc0cec37f644e4380249597f4489c0b32c6a158c6a926a67768d129); /* statement */ 
require(timeout >= 0 && timeout < 864000, "INVALID_CHANNEL_TIMEOUT");coverage_0x2b4f46cc(0x1bdf9010f2f675362982282890f587019c061a5d4cd45f7384f7d8339da667d3); /* assertPost */ 


        // create new payment channel contract
coverage_0x2b4f46cc(0x8d754798d9fbdd2afcacabf49722c74e90b9ddc6cc114d817020cb08e4b30405); /* line */ 
        coverage_0x2b4f46cc(0x2161439cca954457d704391591c97518215be046033a710839701b2c9736274c); /* statement */ 
XBRChannel channel = new XBRChannel(organization, address(token), address(this), marketId,
            markets[marketId].maker, msg.sender, delegate, recipient, amount, timeout,
            XBRChannel.ChannelType.PAYMENT);

        // transfer tokens (initial balance) into payment channel contract
coverage_0x2b4f46cc(0xfc9d27d6d5573fe86088ba7f62b24536d8b0ab4a0dee7653b702f35920b96a3d); /* line */ 
        coverage_0x2b4f46cc(0x0676dd8ad8e40cf6187a813b9a4ebfde54e0b5e13ee7691503f9555f278395d2); /* statement */ 
bool success = token.transferFrom(msg.sender, address(channel), amount);
coverage_0x2b4f46cc(0x07178e74fa785d0b699fd864ba4c53a4cc29a23b75980374a16dbb736ca7987d); /* line */ 
        coverage_0x2b4f46cc(0xe98e217ba803ef140f2c1bf7b68561abb07003da3b5d91f44a97e12623c9371d); /* assertPre */ 
coverage_0x2b4f46cc(0xf9e49a35a57151b341e3c984a05ff0b8b9e20dd47171591b5c968b9e83a47b50); /* statement */ 
require(success, "OPEN_CHANNEL_TRANSFER_FROM_FAILED");coverage_0x2b4f46cc(0x659b6965e8e06080727f81502506e0113beadb08e0202a580b4e62a7a761e56b); /* assertPost */ 


        // remember the new payment channel associated with the market
        //markets[marketId].channels.push(address(channel));
coverage_0x2b4f46cc(0x42aa5691963f0df48309d100fbc64c8242ad761a4d6a6ffedb358569c4299c84); /* line */ 
        coverage_0x2b4f46cc(0x930e233f547b11aefb6d4ff91fe6d8d335e284b203d055a8167c0284173a227d); /* statement */ 
markets[marketId].consumerActors[msg.sender].channels.push(address(channel));

        // emit event ChannelCreated(bytes16 marketId, address sender, address delegate,
        //      address recipient, address channel)
coverage_0x2b4f46cc(0x2fd0320e82d86898e55037233895d0492cefee4f08b85fd699d466a9c6ecbd7c); /* line */ 
        coverage_0x2b4f46cc(0x706c4d211f8b13cfa3cb473cfef5236a692bd541acbe0bf2b81908a8c60a9716); /* statement */ 
emit ChannelCreated(marketId, channel.sender(), channel.delegate(), channel.recipient(),
            address(channel), XBRChannel.ChannelType.PAYMENT);

        // return address of new channel contract
coverage_0x2b4f46cc(0xdca1d033ab5e607876e3515b89a5473de7f0d69a188e3c9554d06cd3262b03b5); /* line */ 
        coverage_0x2b4f46cc(0x0b18b556d858cc7ad4b34e18bfd30f5c7dd289c86e4c78a8baebca570d278c37); /* statement */ 
return address(channel);
    }

    /**
     * As a data provider, request a new payment channel to get paid by the market maker. Given sufficient
     * security amount (deposited by the data provider when joining the marker) to cover the request amount,
     * the market maker will open a payment (state) channel to allow the market maker buying data keys in
     * microtransactions, and offchain. The creation of the payment channel is asynchronously: the market maker
     * is watching the global blockchain filtering for events relevant to the market managed by the maker.
     * When a request to open a payment channel is recognized by the market maker, it will check the provider
     * for sufficient security deposit covering the requested amount, and if all is fine, create a new payment
     * channel and store the contract address for the channel request ID, so the data provider can retrieve it.
     *
     * @param marketId The ID of the market to request a paying channel within.
     * @param delegate The address of the (offchain) provider delegate allowed to sell into the channel.
     * @param amount Amount of XBR Token to deposit into the paying channel (the initial off-chain balance).
     * @param timeout Channel timeout which will apply.
     */
    function requestPayingChannel (bytes16 marketId, address recipient, address delegate,
        uint256 amount, uint32 timeout) public {coverage_0x2b4f46cc(0x191bf45f65b937dbfec3c791532c43f914118eec87e0cdb16f90339df0d31ed3); /* function */ 


        // market must exist
coverage_0x2b4f46cc(0xda47fc44abf88323c93d7943ecf2157e1922203d0b78ff4428e751d7ad380317); /* line */ 
        coverage_0x2b4f46cc(0xc2b7508167cba92ff1c64d6725f3977b954c8456d21ceb3fcd8098860b08a31a); /* assertPre */ 
coverage_0x2b4f46cc(0xf01181a6da8443063a93a69913ea4cae7f0dca6f8f63ac712acbc70f397c7216); /* statement */ 
require(markets[marketId].owner != address(0), "NO_SUCH_MARKET");coverage_0x2b4f46cc(0x00111c42a6644caf4eb9288f2cf27623513f8676ff35ae591cdd0d24eefbb651); /* assertPost */ 


        // market must have a market maker associated
coverage_0x2b4f46cc(0xdce5d392f91e6c3d6eff7b7cf6ffae8c3bd9a9d90b98e3b4690945c7f49188d9); /* line */ 
        coverage_0x2b4f46cc(0x5fb5647b655149f71f68219b71f5c2ad58c0b421455d2dba8b46d55dc44dc6a9); /* assertPre */ 
coverage_0x2b4f46cc(0x68a6c833465cd759cf38da0812bead1d7c685eb1d91e3f51d8cf3d576c1530ff); /* statement */ 
require(markets[marketId].maker != address(0), "NO_ACTIVE_MARKET_MAKER");coverage_0x2b4f46cc(0xd7238669f3c3c0968fdf0055a4f70089c18267dbd7d29a89a1e31c216dbb3467); /* assertPost */ 


        // sender must be market maker for market
coverage_0x2b4f46cc(0xf11a4d4f90eb4b2f07819a226a611cc9fc68fecc26871200564e076afc23d67a); /* line */ 
        coverage_0x2b4f46cc(0x4b15bb763f5b1e7ec21bc97b60bc81ff0154d6be384ce677e0639f5e87077373); /* assertPre */ 
coverage_0x2b4f46cc(0xe75fd3059ff7dc30e414d2351617e93142fbb274b6e091be0e740e650d969381); /* statement */ 
require(msg.sender == recipient, "SENDER_NOT_RECIPIENT");coverage_0x2b4f46cc(0x989a106cc745fdc9995b73a9ca37330bdcf4779c6ca9f7165d3c4752531aa2a0); /* assertPost */ 


        // recipient must be provider in the market
coverage_0x2b4f46cc(0x4a87f7235df9955850d003c7441e0cafffcce7da266492f61c5cffa5f428d2f4); /* line */ 
        coverage_0x2b4f46cc(0x24e9e33500fa92ef5ec8e20c9c9fbffed1afd49489d47062c190b8a7cb0cdaad); /* assertPre */ 
coverage_0x2b4f46cc(0xa2dc25dbfd8a741d040029924bdaf8cdf8261c75adde7f2e346c94ff418039c8); /* statement */ 
require(uint8(markets[marketId].providerActors[recipient].joined) != 0, "RECIPIENT_NOT_PROVIDER");coverage_0x2b4f46cc(0x1a08c8378bc6a42f4b8077db6ffda19226bc8c6a938fc84ec9d91efd2f7b25bb); /* assertPost */ 


        // must provide a valid off-chain channel delegate address
coverage_0x2b4f46cc(0xea023d1bbb6dd38e5cebd97b1e8418c77071e97c38ff938e588c501286616e2f); /* line */ 
        coverage_0x2b4f46cc(0x964f6f07268c4ccb658afdc22b7c4c458fa9c5c73235636541f517b2bd034385); /* assertPre */ 
coverage_0x2b4f46cc(0x4d3d80fb81311fa9180a41909a329cebfedb5c033649d7ecc259988aa2a1ac84); /* statement */ 
require(delegate != address(0), "INVALID_CHANNEL_DELEGATE");coverage_0x2b4f46cc(0x1ef2dd22702ee615265a454a4e582d92dd767871a51bb800a08c7b630a8edfc6); /* assertPost */ 


        // paying channel amount must be positive
coverage_0x2b4f46cc(0x887e822a53cb2dd7f556dfe58136b68da2f6a8fffac8fb327afad8a8f0b270e7); /* line */ 
        coverage_0x2b4f46cc(0xd48d27db7aee6894d19d85798bd664de564333f216acd99eb7f04adf160ab6b9); /* assertPre */ 
coverage_0x2b4f46cc(0x9986b9a1ada5a7c86c74abff720f6703ed5d6660b73296e58f9c8bce78edc851); /* statement */ 
require(amount > 0 && amount <= token.totalSupply(), "INVALID_CHANNEL_AMOUNT");coverage_0x2b4f46cc(0x889474922d8ee1e3c5bfa087fd4c141aea87a563e66599fdb7feb4173e89e0be); /* assertPost */ 


        // paying channel timeout can be [0 seconds - 10 days[
coverage_0x2b4f46cc(0x75b231acdbce903901676a98b4e2f339c5391680dd319fd14442b5bd8ac554b2); /* line */ 
        coverage_0x2b4f46cc(0xd3ad4c508cee465c971ac71236682b6c62698fb2e1093ae029b61b1d5465ec3b); /* assertPre */ 
coverage_0x2b4f46cc(0xe4fa711c358b6812fd3a9d7635da904588c556fff9211c3eae73157bb6cc5794); /* statement */ 
require(timeout >= 0 && timeout < 864000, "INVALID_CHANNEL_TIMEOUT");coverage_0x2b4f46cc(0x9383a4d2e1f7f265f83ea452fb9972517b04d2334c1867b8d3057ec8b719a180); /* assertPost */ 


        // emit event PayingChannelRequestCreated(bytes16 marketId, address sender, address recipient,
        //      address delegate, uint256 amount, uint32 timeout)
coverage_0x2b4f46cc(0xa66472f701494a7b3199bf4d9b95dad7e001f77b9d6cedd8e1b52c3a75cef5ed); /* line */ 
        coverage_0x2b4f46cc(0xb8bf66b2d1544c082448304d2c9848864f26ac37723a029f8bf1ad790f964503); /* statement */ 
emit PayingChannelRequestCreated(marketId, msg.sender, recipient, delegate, amount, timeout);
    }

    /**
     * Open a new paying channel and deposit an amount of XBR token for off-chain consumption.
     * Must be called by the market maker in response to a successful request for a paying channel.
     *
     * @param marketId The ID of the market to open a paying channel within.
     * @param recipient Ultimate recipient of tokens earned, recipient must be provider in the market.
     * @param delegate The address of the (offchain) provider delegate allowed to earn on the channel.
     * @param amount Amount of XBR Token to deposit into the paying channel (the initial off-chain balance).
     * @param timeout Channel timeout which will apply.
     */
    function openPayingChannel (bytes16 marketId, address recipient, address delegate,
        uint256 amount, uint32 timeout) public returns (address paymentChannel) {coverage_0x2b4f46cc(0xb5f4e7eeb9532a6a78349ca409e935b09e89a0c966d033605028eee311fb655b); /* function */ 


        // market must exist
coverage_0x2b4f46cc(0xa8b97812d181e7434d9e2221673e41ffb2e8216fa925f2952462b4744b683f8f); /* line */ 
        coverage_0x2b4f46cc(0xf42ae53ca6d6b01c31c73cf879aa768ec0ed6a67f4a062c332c7fabac8d0ce02); /* assertPre */ 
coverage_0x2b4f46cc(0x2652e9b65485373c22edeb6cab850ad149897eaea8ad7adf064ca2e91150ef5a); /* statement */ 
require(markets[marketId].owner != address(0), "NO_SUCH_MARKET");coverage_0x2b4f46cc(0xfc41965b2bc44c6401cfd0db1e2cacd1795bd135efad7a7b8f699a9c104a3762); /* assertPost */ 


        // sender must be market maker for market
coverage_0x2b4f46cc(0xe81c5bde0623b7b51a2595ea94f41600e05ef31fbaf53194ecbf0c350cb6f65c); /* line */ 
        coverage_0x2b4f46cc(0x18ba6a54115deb8fcc02146df1be4f91302b776cd40b2edb1824fa7e15afb5d3); /* assertPre */ 
coverage_0x2b4f46cc(0xc1333319cd5d27a012b6284f1270e3892cc8df43ad1e51b1a8279c67e0ff346d); /* statement */ 
require(markets[marketId].maker == msg.sender, "SENDER_NOT_MAKER");coverage_0x2b4f46cc(0x51779ed7c52eac92b91d43d125ae237664dac084f29d6c285853f828ad36bd6e); /* assertPost */ 


        // recipient must be provider in the market
coverage_0x2b4f46cc(0xcca5a6dcd599671c54a48dd8bd3316c3bc53e79f500358548dad703b7910c513); /* line */ 
        coverage_0x2b4f46cc(0xad3a9c20825369b3b600c90d1293b565fe162c5b828a14fa936d7b1dc439b783); /* assertPre */ 
coverage_0x2b4f46cc(0x527b77fbefa82f29b50de5e3286f793df95a96472e5225f171863d1e367bbcd8); /* statement */ 
require(uint8(markets[marketId].providerActors[recipient].joined) != 0, "RECIPIENT_NOT_PROVIDER");coverage_0x2b4f46cc(0xbedb6c4b4d1616885aa6acdef323688e8218d7cd4c6c3ef90ec4af019d3e6a0d); /* assertPost */ 


        // must provide a valid off-chain channel delegate address
coverage_0x2b4f46cc(0x8da04c2987449f03a51ef322e63cb2c08b32ab6fd8be9447630239405d07553d); /* line */ 
        coverage_0x2b4f46cc(0x835e05aa6fc177bbe489cfb23d8c92c28a089b806edea8b064637ae7bb88b573); /* assertPre */ 
coverage_0x2b4f46cc(0x00343e43365e6cd985406a1b15a2b9cd12dbe1374721430ee8af9793befd17eb); /* statement */ 
require(delegate != address(0), "INVALID_CHANNEL_DELEGATE");coverage_0x2b4f46cc(0x9ab9ff89735407d38518a54ee80e796e12942fb349460ca00ff3320896228150); /* assertPost */ 


        // payment channel amount must be positive
coverage_0x2b4f46cc(0x3c0058f0bb7e8e68158b785136f54f9951efad0e6d170749efcd3e98b8d0d366); /* line */ 
        coverage_0x2b4f46cc(0x867ac7c36d43143a97298a5711aa16e324b8e5a99d768542c79ca8a28197a845); /* assertPre */ 
coverage_0x2b4f46cc(0xf0b24c0dd8c4be9f58c593a39f32484c518bf981695aca86f85a5a03f8ea030f); /* statement */ 
require(amount > 0 && amount <= token.totalSupply(), "INVALID_CHANNEL_AMOUNT");coverage_0x2b4f46cc(0xcc338693f6946a040f4afe64787ab8deaf4ccf0083873806264e4b9920bc73c5); /* assertPost */ 


        // payment channel timeout can be [0 seconds - 10 days[
coverage_0x2b4f46cc(0x89b3b3235c1f76154c2d9884195ce0c882eb46ce81e977cf8a65805df1cf402b); /* line */ 
        coverage_0x2b4f46cc(0xe1968713c6bb4de39e164d8ddf239cfb4998f2f16b470c535b2e6e337006dc5a); /* assertPre */ 
coverage_0x2b4f46cc(0xb8db16b1ec104db05bf213492e7658fd331c61801975f358e38ac80bed373963); /* statement */ 
require(timeout >= 0 && timeout < 864000, "INVALID_CHANNEL_TIMEOUT");coverage_0x2b4f46cc(0xdc24349c28023f25736fc5e6f00ccfabf76a6d4ba6675fdcdc696d00fbdd19cc); /* assertPost */ 


        // create new paying channel contract
coverage_0x2b4f46cc(0x9de1e52de2ae943b9244f6e5dcc7ff6d16991695a515fec3b6f40de2e2346143); /* line */ 
        coverage_0x2b4f46cc(0x2627915b7e4392f4f7ab56f8ae45a56c60dbc2e201ee59397e12c145108d7148); /* statement */ 
XBRChannel channel = new XBRChannel(organization, address(token), address(this),
            marketId, markets[marketId].maker, msg.sender, delegate, recipient, amount, timeout,
            XBRChannel.ChannelType.PAYING);

        // transfer tokens (initial balance) into payment channel contract
coverage_0x2b4f46cc(0x4e657068324ad0c0ff79f1e4428aab5242e63cc1021b0e3cf2abbd845071e928); /* line */ 
        coverage_0x2b4f46cc(0x46c7e5d1ce0dfbb79c4f70afdf631ce3d74a3879d496c1939a0b366c7e37a435); /* statement */ 
XBRToken _token = XBRToken(token);
coverage_0x2b4f46cc(0xb7fe80622641dff7e02fde3adf4e1ac911e0e6d4afbfeae9a1277a56a9362965); /* line */ 
        coverage_0x2b4f46cc(0xe292f1c26b191e2c94249037c847f012138f629b66f888e295e64f3fdfa031e1); /* statement */ 
bool success = _token.transferFrom(msg.sender, address(channel), amount);
coverage_0x2b4f46cc(0xda581751a90fe188ed6eae24774c35e45de9864e39114172bd9fe26089894ff5); /* line */ 
        coverage_0x2b4f46cc(0xa93c81fb256ec2c17de1a4584b125b53a9df4ea89a84290f660eb8fe8442aaac); /* assertPre */ 
coverage_0x2b4f46cc(0x6056e474a37562314b4564bd305b884ca098447dd54e4dcd5bf1c819676bcbb3); /* statement */ 
require(success, "OPEN_CHANNEL_TRANSFER_FROM_FAILED");coverage_0x2b4f46cc(0xcd9ceeb582d6364f4d7672bce19d805464fdda3f20944f3c1436c19ce80fa8e4); /* assertPost */ 


        // remember the new payment channel associated with the market
        //markets[marketId].channels.push(address(channel));
coverage_0x2b4f46cc(0x46c53bfec6a2bdee359582519c33e9dbddbe91896d1fcfe316e9df71fc488cf6); /* line */ 
        coverage_0x2b4f46cc(0x67ca51acfdcbbf6af071bfa7b92e0e1b42c868efb4c56b8218ed7ed219e65e27); /* statement */ 
markets[marketId].providerActors[recipient].channels.push(address(channel));

        // emit event ChannelCreated(bytes16 marketId, address sender, address delegate,
        //  address recipient, address channel)
coverage_0x2b4f46cc(0xea9b2fdf3c08e394323c23e5c083ffb052279f5819c37b37fcf94f65c8e7d7b2); /* line */ 
        coverage_0x2b4f46cc(0xe3cfda8a3d01ade1daa78cb3ce7959129717d2e98c1662e4e287da650619f5f3); /* statement */ 
emit ChannelCreated(marketId, channel.sender(), channel.delegate(), channel.recipient(),
            address(channel), XBRChannel.ChannelType.PAYING);

coverage_0x2b4f46cc(0x33c925e0f6bbd2d37505807a7b754d9457b967ecedf8edcf6707f7db131040f7); /* line */ 
        coverage_0x2b4f46cc(0xce337d6210601cf7921c679e25497e7c92aad8ce18d5bf66c369af8468ca5c50); /* statement */ 
return address(channel);
    }

    /**
     * Lookup all provider actors in a XBR Market.
     *
     * @param marketId The XBR Market to provider actors for.
     * @return List of provider actor addresses in the market.
     */
    function getAllMarketProviders(bytes16 marketId) public view returns (address[] memory) {coverage_0x2b4f46cc(0x1a6114a3ee1de208b9ff2f0fde1a7e23e97faf2cdc7063f59df96e0841efce34); /* function */ 

coverage_0x2b4f46cc(0x31dfb3aacd7ad91dcb80065ff4346fbd397c7059f7c4a28f6cfa48493cedb2ab); /* line */ 
        coverage_0x2b4f46cc(0x6776e47e106d0b2053fb396d67ffb5705ea747b0e20e641d1228266afef4739b); /* statement */ 
return markets[marketId].providerActorAdrs;
    }

    /**
     * Lookup all consumer actors in a XBR Market.
     *
     * @param marketId The XBR Market to consumer actors for.
     * @return List of consumer actor addresses in the market.
     */
    function getAllMarketConsumers(bytes16 marketId) public view returns (address[] memory) {coverage_0x2b4f46cc(0xbde0d9f0583ff8cef3193265d69a2dea85e96ee5ff3c4c567c7b9ac610860723); /* function */ 

coverage_0x2b4f46cc(0x44f25bdb9335c1cf25c6716fa5522333b1c0bac9689886d4f7433060ccbcf718); /* line */ 
        coverage_0x2b4f46cc(0xbd944fc5f4f8b7e3a7857054c88183b5b77afe56f523d5cfd89ecfa5e383a9bf); /* statement */ 
return markets[marketId].consumerActorAdrs;
    }

    /**
     * Lookup all payment channels for an consumer actor in a XBR Market.
     *
     * @param marketId The XBR Market to get payment channels for.
     * @param actor The XBR actor to get payment channels for.
     * @return List of contract addresses of payment channels in the market.
     */
    function getAllPaymentChannels(bytes16 marketId, address actor) public view returns (address[] memory) {coverage_0x2b4f46cc(0xdda718f589aced190501d87715c48f6a980f331eb00d7ff98d944a5a4f7cb6bf); /* function */ 

coverage_0x2b4f46cc(0xda3074b2885d669aa88e20c0ec1f3a52e4f3f3aaef296081bb70bccf368a4a62); /* line */ 
        coverage_0x2b4f46cc(0x8d27c88b94455d35c7253376d8bcfbf77293d050f39b765da4856c782f240032); /* statement */ 
return markets[marketId].consumerActors[actor].channels;
    }

    /**
     * Lookup all paying channels for an provider actor in a XBR Market.
     *
     * @param marketId The XBR Market to get paying channels for.
     * @param actor The XBR actor to get paying channels for.
     * @return List of contract addresses of paying channels in the market.
     */
    function getAllPayingChannels(bytes16 marketId, address actor) public view returns (address[] memory) {coverage_0x2b4f46cc(0x079d27b48568b60f0cb66b508c9ba86139574e8232e95ca955d47f65ac6b9a25); /* function */ 

coverage_0x2b4f46cc(0x75d385d9888a11927b51e9bdb77dbfa90ead9f42a91fed0efbf13ae695a1fa4d); /* line */ 
        coverage_0x2b4f46cc(0x0f1a1d269ab389bd52ccff0a09138b757c454217bc8dbf4868eb5a6897d6f178); /* statement */ 
return markets[marketId].providerActors[actor].channels;
    }

    /**
     * Lookup the current payment channel to use for the given delegate in the given market.
     *
     * @param marketId The XBR Market to get the current payment channel address for.
     * @param delegate The delegate to get the current payment channel address for.
     * @return Current payment channel address for the given delegate/market.
     */
    function currentPaymentChannelByDelegate(bytes16 marketId, address delegate) public view returns (address) {coverage_0x2b4f46cc(0x93a1c498925c9ad94594767e7896f54f42ee6bb5773849529b81d6eca66fa3be); /* function */ 

coverage_0x2b4f46cc(0x8846178743051353d952f584fe300bfb537cd62293deea64ab5e54c50673956f); /* line */ 
        coverage_0x2b4f46cc(0xbcbafe47110b2b6ed6b6003adc12575e5dce5e9b03e4bed8c8fdc0ff81fdd746); /* statement */ 
return markets[marketId].currentPaymentChannelByDelegate[delegate];
    }

    /**
     * Lookup the current paying channel to use for the given delegate in the given market.
     *
     * @param marketId The XBR Market to get the current paying channel address for.
     * @param delegate The delegate to get the current paying channel address for.
     * @return Current paying channel address for the given delegate/market.
     */
    function currentPayingChannelByDelegate(bytes16 marketId, address delegate) public view returns (address) {coverage_0x2b4f46cc(0xf94143940ea210e8649339684377d85884de19f40c4a97414a8c1711d198d023); /* function */ 

coverage_0x2b4f46cc(0x7438e4235108c93476cd0c2dbb9dad8cd74db28ee2ce3f31b5c1b8a99af3df2d); /* line */ 
        coverage_0x2b4f46cc(0xcc22539bd6bd464b875f1c99daecf601f922d3e13abcce5670706abefca19b6b); /* statement */ 
return markets[marketId].currentPayingChannelByDelegate[delegate];
    }
}
