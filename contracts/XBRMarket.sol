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
import "./XBRNetwork.sol";


/**
 * @title XBR Market smart contract.
 * @author The XBR Project
 */
contract XBRMarket is XBRMaintained {

    // Add safe math functions to uint256 using SafeMath lib from OpenZeppelin
    using SafeMath for uint256;

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

    /// Instance of XBRNetwork contract this contract is linked to.
    XBRNetwork public network;

    /// Created markets are sequence numbered using this counter (to allow deterministic collision-free IDs for markets)
    uint32 private marketSeq = 1;

    /// Current XBR Markets ("market directory")
    mapping(bytes16 => XBRTypes.Market) public markets;

    /// List of IDs of current XBR Markets.
    bytes16[] public marketIds;

    /// Index: maker address => market ID
    mapping(address => bytes16) public marketsByMaker;

    /// Index: market owner address => [market ID]
    mapping(address => bytes16[]) public marketsByOwner;

    /**
     * Constructor for this contract, only called once (when deploying the network).
     *
     * @param network_ The XBR network contract this instance is associated with.
     */
    constructor (address network_) public {
        network = XBRNetwork(network_);
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
        uint256 providerSecurity, uint256 consumerSecurity, uint256 marketFee) public {

        _createMarket(msg.sender, marketId, terms, meta, maker, providerSecurity, consumerSecurity, marketFee, "");
    }

    function createMarketFor (address member, bytes16 marketId, string memory terms, string memory meta, address maker,
        uint256 providerSecurity, uint256 consumerSecurity, uint256 marketFee, bytes memory signature) public {

        require(XBRTypes.verify(member, XBRTypes.EIP712MarketCreate(network.verifyingChain(), network.verifyingContract(),
            marketId, terms, meta, maker, providerSecurity, consumerSecurity, marketFee), signature),
            "INVALID_MARKET_CREATE_SIGNATURE");

        _createMarket(member, marketId, terms, meta, maker, providerSecurity, consumerSecurity, marketFee, signature);
    }

    function _createMarket (address member, bytes16 marketId, string memory terms, string memory meta, address maker,
        uint256 providerSecurity, uint256 consumerSecurity, uint256 marketFee, bytes memory signature) private {

        (, , , XBRTypes.MemberLevel member_level, ) = network.members(member);

        // the market operator (owner) must be a registered member
        require(member_level == XBRTypes.MemberLevel.ACTIVE ||
                member_level == XBRTypes.MemberLevel.VERIFIED, "SENDER_NOT_A_MEMBER");

        // market must not yet exist (to generate a new marketId: )
        require(markets[marketId].owner == address(0), "MARKET_ALREADY_EXISTS");

        // must provide a valid market maker address already when creating a market
        require(maker != address(0), "INVALID_MAKER");

        // the market maker can only work for one market
        require(marketsByMaker[maker] == bytes16(0), "MAKER_ALREADY_WORKING_FOR_OTHER_MARKET");

        // provider security must be non-negative (and obviously smaller than the total token supply)
        require(providerSecurity >= 0 && providerSecurity <= network.token().totalSupply(), "INVALID_PROVIDER_SECURITY");

        // consumer security must be non-negative (and obviously smaller than the total token supply)
        require(consumerSecurity >= 0 && consumerSecurity <= network.token().totalSupply(), "INVALID_CONSUMER_SECURITY");

        // FIXME: treat market fee
        require(marketFee >= 0 && marketFee < (network.token().totalSupply() - 10**7) * 10**18, "INVALID_MARKET_FEE");

        // now remember out new market ..
        uint created = block.timestamp;
        markets[marketId] = XBRTypes.Market(created, marketSeq, member, terms, meta, maker,
            providerSecurity, consumerSecurity, marketFee, signature, new address[](0), new address[](0));

        // .. and the market-maker-to-market mapping
        marketsByMaker[maker] = marketId;

        // .. and the market-owner-to-market mapping
        marketsByOwner[member].push(marketId);

        // .. and list of markst IDs
        marketIds.push(marketId);

        // increment market sequence for next market
        marketSeq = marketSeq + 1;

        // notify observers (eg a dormant market maker waiting to be associated)
        emit MarketCreated(marketId, created, marketSeq, member, terms, meta, maker,
            providerSecurity, consumerSecurity, marketFee);
    }

    /**
     * Join the given XBR market as the specified type of actor, which must be PROVIDER or CONSUMER.
     *
     * @param marketId The ID of the XBR data market to join.
     * @param actorType The type of actor under which to join: PROVIDER or CONSUMER.
     * @param meta The XBR market provider/consumer metadata. IPFS Multihash pointing to a JSON file with metadata.
     */
    function joinMarket (bytes16 marketId, uint8 actorType, string memory meta) public returns (uint256) {

        return _joinMarket(msg.sender, marketId, actorType, meta, "");
    }

    function joinMarketFor (address member, uint256 joined, bytes16 marketId, uint8 actorType,
        string memory meta, bytes memory signature) public returns (uint256) {

        require(XBRTypes.verify(member, XBRTypes.EIP712MarketJoin(network.verifyingChain(), network.verifyingContract(),
            member, joined, marketId, actorType, meta), signature), "INVALID_MARKET_JOIN_SIGNATURE");

        return _joinMarket(member, marketId, actorType, meta, signature);
    }

    function _joinMarket (address member, bytes16 marketId, uint8 actorType, string memory meta, bytes memory signature) private returns (uint256) {

        (, , , XBRTypes.MemberLevel member_level, ) = network.members(member);

        // the joining sender must be a registered member
        require(member_level == XBRTypes.MemberLevel.ACTIVE, "SENDER_NOT_A_MEMBER");

        // the market to join must exist
        require(markets[marketId].owner != address(0), "NO_SUCH_MARKET");

        // the market owner cannot join as an actor (provider/consumer) in the market
        require(markets[marketId].owner != member, "SENDER_IS_OWNER");

        // the joining member must join as a data provider (seller) or data consumer (buyer)
        require(actorType == uint8(XBRTypes.ActorType.PROVIDER) ||
                actorType == uint8(XBRTypes.ActorType.CONSUMER), "INVALID_ACTOR_TYPE");

        // get the security amount required for joining the market (if any)
        uint256 security;
        // if (uint8(actorType) == uint8(ActorType.PROVIDER)) {
        if (actorType == uint8(XBRTypes.ActorType.PROVIDER)) {
            // the joining member must not be joined as a provider already
            require(uint8(markets[marketId].providerActors[member].joined) == 0, "ALREADY_JOINED_AS_PROVIDER");
            security = markets[marketId].providerSecurity;
        } else  {
            // the joining member must not be joined as a consumer already
            require(uint8(markets[marketId].consumerActors[member].joined) == 0, "ALREADY_JOINED_AS_CONSUMER");
            security = markets[marketId].consumerSecurity;
        }

        if (security > 0) {
            // Transfer (if any) security to the market owner (for ActorType.CONSUMER or ActorType.PROVIDER)
            bool success = network.token().transferFrom(member, markets[marketId].owner, security);
            require(success, "JOIN_MARKET_TRANSFER_FROM_FAILED");
        }

        // remember actor (by actor address) within market
        uint joined = block.timestamp;
        if (actorType == uint8(XBRTypes.ActorType.PROVIDER)) {
            markets[marketId].providerActors[member] = XBRTypes.Actor(joined, security, meta, signature, new address[](0));
            markets[marketId].providerActorAdrs.push(member);
        } else {
            markets[marketId].consumerActors[member] = XBRTypes.Actor(joined, security, meta, signature, new address[](0));
            markets[marketId].consumerActorAdrs.push(member);
        }

        // emit event ActorJoined(bytes16 marketId, address actor, ActorType actorType, uint joined,
        //                        uint256 security, string meta)
        emit ActorJoined(marketId, member, actorType, joined, security, meta);

        // return effective security transferred
        return security;
    }

    function countMarkets() public view returns (uint) {
        return marketIds.length;
    }

    /*
    // TypeError: Only libraries are allowed to use the mapping type in public or external functions.
    function getMarket(bytes16 marketId) public view returns (XBRTypes.Market memory) {
        return markets[marketId];
    }
    */

    function getMarketOwner(bytes16 marketId) public view returns (address) {
        return markets[marketId].owner;
    }

    function getMarketMaker(bytes16 marketId) public view returns (address) {
        return markets[marketId].maker;
    }

    function getMarketsByOwner(address owner, uint index) public view returns (bytes16) {
        return marketsByOwner[owner][index];
    }

    function isActor(bytes16 marketId, address actor, XBRTypes.ActorType actorType) public view returns (bool) {
        if (markets[marketId].owner == address(0)) {
            return false;
        } else {
            if (actorType ==  XBRTypes.ActorType.CONSUMER) {
                return markets[marketId].consumerActors[actor].joined > 0;
            } else if (actorType ==  XBRTypes.ActorType.PROVIDER) {
                return markets[marketId].providerActors[actor].joined > 0;
            } else {
                return false;
            }
        }
    }

    function countMarketsByOwner(address owner) public view returns (uint) {
        return marketsByOwner[owner].length;
    }

    function getMarketActor (bytes16 marketId, address actor, uint8 actorType) public view
        returns (uint, uint256, string memory)
    {
        // the market must exist
        require(markets[marketId].owner != address(0), "NO_SUCH_MARKET");

        // must ask for a data provider (seller) or data consumer (buyer)
        require(actorType == uint8(XBRTypes.ActorType.PROVIDER) ||
                actorType == uint8(XBRTypes.ActorType.CONSUMER), "INVALID_ACTOR_TYPE");

        if (actorType == uint8(XBRTypes.ActorType.CONSUMER)) {
            XBRTypes.Actor storage _actor = markets[marketId].consumerActors[actor];
            return (_actor.joined, _actor.security, _actor.meta);
        } else {
            XBRTypes.Actor storage _actor = markets[marketId].providerActors[actor];
            return (_actor.joined, _actor.security, _actor.meta);
        }
    }

    /**
     * Lookup all provider actors in a XBR Market.
     *
     * @param marketId The XBR Market to provider actors for.
     * @return List of provider actor addresses in the market.
     */
    function getAllMarketProviders(bytes16 marketId) public view returns (address[] memory) {
        return markets[marketId].providerActorAdrs;
    }

    /**
     * Lookup all consumer actors in a XBR Market.
     *
     * @param marketId The XBR Market to consumer actors for.
     * @return List of consumer actor addresses in the market.
     */
    function getAllMarketConsumers(bytes16 marketId) public view returns (address[] memory) {
        return markets[marketId].consumerActorAdrs;
    }

    /**
     * Lookup all payment channels for an consumer actor in a XBR Market.
     *
     * @param marketId The XBR Market to get payment channels for.
     * @param actor The XBR actor to get payment channels for.
     * @return List of contract addresses of payment channels in the market.
     */
    function getAllPaymentChannels(bytes16 marketId, address actor) public view returns (address[] memory) {
        return markets[marketId].consumerActors[actor].channels;
    }

    /**
     * Lookup all paying channels for an provider actor in a XBR Market.
     *
     * @param marketId The XBR Market to get paying channels for.
     * @param actor The XBR actor to get paying channels for.
     * @return List of contract addresses of paying channels in the market.
     */
    function getAllPayingChannels(bytes16 marketId, address actor) public view returns (address[] memory) {
        return markets[marketId].providerActors[actor].channels;
    }

    /**
     * Lookup the current payment channel to use for the given delegate in the given market.
     *
     * @param marketId The XBR Market to get the current payment channel address for.
     * @param delegate The delegate to get the current payment channel address for.
     * @return Current payment channel address for the given delegate/market.
     */
    function currentPaymentChannelByDelegate(bytes16 marketId, address delegate) public view returns (address) {
        return markets[marketId].currentPaymentChannelByDelegate[delegate];
    }

    /**
     * Lookup the current paying channel to use for the given delegate in the given market.
     *
     * @param marketId The XBR Market to get the current paying channel address for.
     * @param delegate The delegate to get the current paying channel address for.
     * @return Current paying channel address for the given delegate/market.
     */
    function currentPayingChannelByDelegate(bytes16 marketId, address delegate) public view returns (address) {
        return markets[marketId].currentPayingChannelByDelegate[delegate];
    }
}
