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

import "./XBRToken.sol";
import "./XBRMaintained.sol";
import "./XBRPaymentChannel.sol";


/**
 * @title XBR Network root SC
 * @author The XBR Project
 */
contract XBRNetwork is XBRMaintained {

    /// XBR Network membership levels
    enum MemberLevel { NULL, ACTIVE, VERIFIED, RETIRED, PENALTY, BLOCKED }

    /// Value type for holding XBR Network membership information.
    struct Member {
        bytes32 eula;
        bytes32 profile;
        MemberLevel level;
    }

    event MemberCreated (bytes32 eula, bytes32 profile, MemberLevel level);

    /// XBR Market Actor types
    enum ActorType { NULL, NETWORK, MAKER, PROVIDER, CONSUMER }

    struct Actor {
        ActorType actorType;
    }

    event ActorJoined ();

    event PaymentChannelCreated (address channel, bytes32 marketId);

    event PayingChannelRequestCreated (bytes32 payingChannelRequestId, bytes32 marketId);

    struct PayingChannelRequest {
        bytes32 marketId;
        address sender;
        address delegate;
        address recipient;
        uint256 amount;
        uint32 timeout;
    }

    /// Value type for holding XBR Market information.
    struct Market {
        uint32 sequence;
        address owner;
        address maker;
        bytes32 terms;
        uint providerSecurity;
        uint consumerSecurity;
        address[] channels;
        address[] actorAddresses;
        mapping(address => Actor) actors;
        mapping(bytes32 => PayingChannelRequest) channelRequests;
    }

    uint32 private marketSeq = 1;

    /// Address of the XBR Network ERC20 token (XBR for the CrossbarFX technology stack)
    address public network_token;

    /// Address of the `XBR Network Organization <https://xbr.network/>`_
    address public network_organization;

    /// Current XBR Network members.
    mapping(address => Member) private members;

    /// Current XBR Markets ("market repository")
    mapping(bytes32 => Market) private markets;

    /// Index: maker address => market ID
    mapping(address => bytes32) private marketByMaker;

    /**
     * Create a new network.
     *
     * @param _network_token The token to run this network on.
     * @param _network_organization The network technology provider and ecoystem sponsor.
     */
    constructor (address _network_token, address _network_organization) public {
        network_token = _network_token;
        network_organization = _network_organization;

        members[msg.sender] = Member("", "", MemberLevel.VERIFIED);
    }

    /**
     * Join the XBR Network. All XBR stakeholders, namely XBR Data Providers,
     * XBR Data Consumers, XBR Data Markets and XBR Data Clouds, must register
     * with the XBR Network on the global blockchain by calling this function.
     *
     * @param eula The file hash (SHA2-256) of the XBR Network EULA documents
     *             being agreed to and stored as one ZIP file archive on IPFS.
     * @param profile Optional public member profile: the file hash (SHA2-256)
     *                of the member profile file stored on a well-known location
     *                (suchas as IPFS).
     */
    function register (bytes32 eula, bytes32 profile) public {
        require(uint(members[msg.sender].level) == 0, "MEMBER_ALREADY_EXISTS");

        members[msg.sender] = Member(eula, profile, MemberLevel.ACTIVE);

        emit MemberCreated(eula, profile, MemberLevel.ACTIVE);
    }

    /**
     * Leave the XBR Network.
     */
    function unregister () public {
        require(uint(members[msg.sender].level) != 0, "NO_SUCH_MEMBER");

        members[msg.sender].level = MemberLevel.RETIRED;
    }

    function getMemberLevel (address member) public view returns (MemberLevel) {
        return members[member].level;
    }

    /**
     * Manually override the member level of a XBR Network member. Being able to do so
     * currently serves two purposes:
     *
     * - having a last resort to handle situation where members violated the EULA
     * - being able to manually patch things in error/bug cases
     */
    function setMemberLevel (address member, MemberLevel level) public onlyMaintainer {
        // only network admins are allowed to override member level
        //require(network_admins.has(msg.sender), "DOES_NOT_HAVE_NETWORK_ADMIN_ROLE");

        members[member].level = level;
    }

    /**
     * Register a new XBR market. The sender of the transaction must be XBR network member
     * and automatically becomes owner of the new market.
     *
     * @param maker The address of the XBR market maker that will run this market.
     * @param terms The XBR market terms set by the market owner.
     * @param providerSecurity The amount of XBR tokens a XBR provider joining the market must deposit.
     * @param consumerSecurity The amount of XBR tokens a XBR consumer joining the market must deposit.
     */
    function openMarket (bytes32 marketId, address maker, bytes32 terms, uint providerSecurity,
        uint consumerSecurity) public {

        // generate new market_id
        // bytes32 marketId = keccak256(abi.encodePacked(marketSeq, msg.sender, blockhash(block.number)));
        require(markets[marketId].owner == address(0), "MARKET_ALREADY_EXISTS");
        require(marketByMaker[maker] == bytes32(0), "MAKER_ALREADY_WORKING_FOR_OTHER_MARKET");

        markets[marketId] = Market(marketSeq, msg.sender, maker, terms, providerSecurity,
            consumerSecurity, new address[](0), new address[](0));

        marketByMaker[maker] = marketId;

        marketSeq = marketSeq + 1;
    }

    function getMarketByMaker (address maker) public view returns (bytes32) {
        return marketByMaker[maker];
    }

    function getMarketOwner (bytes32 marketId) public view returns (address) {
        return markets[marketId].owner;
    }

    function getMarketMaker (bytes32 marketId) public view returns (address) {
        return markets[marketId].maker;
    }

    function getMarketTerms (bytes32 marketId) public view returns (bytes32) {
        return markets[marketId].terms;
    }

    function getMarketProviderSecurity (bytes32 marketId) public view returns (uint) {
        return markets[marketId].providerSecurity;
    }

    function getMarketConsumerSecurity (bytes32 marketId) public view returns (uint) {
        return markets[marketId].consumerSecurity;
    }

    /**
     * Join the given XBR market as the specified type of actor, which must be PROVIDER or CONSUMER.
     *
     * @param marketId The ID of the XBR data market to join.
     * @param actorType The type of actor under which to join: PROVIDER or CONSUMER.
     */
    function joinMarket (bytes32 marketId, ActorType actorType) public {
        require(markets[marketId].owner != address(0), "NO_SUCH_MARKET");
        require(uint8(markets[marketId].actors[msg.sender].actorType) == 0, "ACTOR_ALREADY_JOINED");
        require(uint8(actorType) == uint8(ActorType.MAKER) ||
            uint8(actorType) == uint8(ActorType.PROVIDER) || uint8(actorType) == uint8(ActorType.CONSUMER));

        markets[marketId].actors[msg.sender] = Actor(actorType);
        markets[marketId].actorAddresses.push(msg.sender);
    }

    function getAllMarketActors(bytes32 marketId) public view returns (address[]) {
        return markets[marketId].actorAddresses;
    }

    function getMarketActorType (bytes32 marketId, address actor) public view returns (ActorType) {
        return markets[marketId].actors[actor].actorType;
    }

    /**
     * Open a new payment channel and deposit an amount of XBR token into a market.
     * The procedure returns
     */
    function openPaymentChannel (bytes32 marketId, address consumer, uint256 amount) public returns
        (address paymentChannel) {

        // bytes32 marketId, address sender, address delegate, address recipient, uint256 amount, uint32 timeout
        XBRPaymentChannel channel = new XBRPaymentChannel(marketId, msg.sender, consumer, address(0), amount, 60);

        XBRToken token = XBRToken(network_token);
        bool success = token.transferFrom(msg.sender, channel, amount);
        require(success, "OPEN_CHANNEL_TRANSFER_FROM_FAILED");

        markets[marketId].channels.push(channel);

        emit PaymentChannelCreated(channel, marketId);

        return channel;
    }

    function getAllMarketPaymentChannels(bytes32 marketId) public view returns (address[]) {
        return markets[marketId].channels;
    }

    /**
     * As a data provider, request a new payment channel to get paid by the market maker. Given sufficient
     * security amount (deposited by the data provider when joining the marker) to cover the request amount,
     * the market maker will open a payment (state) channel to allow the market maker buying data keys in
     * microtransactions, and offchain. The creation of the payment channel is asynchronously: the market maker
     * is watching the global blockchain filtering for events relevant to the market managed by the maker.
     * When a request to open a payment channel is recognized by the market maker, it will check the provider
     * for sufficient security despoit covering the requested amount, and if all is fine, create a new payment
     * channel and store the contract address for the channel request ID, so the data provider can retrieve it.
     */
    function requestPayingChannel (bytes32 payingChannelRequestId, bytes32 marketId, address provider,
        uint256 amount) public {

        require(markets[marketId].owner != address(0), "NO_SUCH_MARKET");
        require(markets[marketId].channelRequests[payingChannelRequestId].sender == address(0),
            "PAYING_CHANNEL_REQUEST_ALREADY_EXISTS");

        markets[marketId].channelRequests[payingChannelRequestId] =
            PayingChannelRequest(marketId, msg.sender, provider, address(0), amount, 60);

        emit PayingChannelRequestCreated(payingChannelRequestId, marketId);
    }

    /**
     * As a market actor (participant) currently member of a market, leave that market.
     * A market can only be left when all payment channels of the sender are closed (or expired).
     *
     * @param marketId The ID of the market to leave.
     */
    function leaveMarket (bytes32 marketId) public view {
        require(markets[marketId].owner != address(0), "NO_SUCH_MARKET");
        // FIXME
    }

    /**
     * Close a market. A closed market will not accept new memberships.
     *
     * @param marketId The ID of the market to close.
     */
    function closeMarket (bytes32 marketId) public view {
        require(markets[marketId].owner != address(0), "NO_SUCH_MARKET");
        // FIXME
    }
}
