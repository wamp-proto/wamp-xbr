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

pragma solidity ^0.5.2;

// https://openzeppelin.org/api/docs/math_SafeMath.html
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "./XBRToken.sol";
import "./XBRMaintained.sol";
import "./XBRChannel.sol";


/**
 * @title XBR Network main smart contract.
 * @author The XBR Project
 */
contract XBRNetwork is XBRMaintained {

    // Add safe math functions to uint256 using SafeMath lib from OpenZeppelin
    using SafeMath for uint256;

    // //////// enums

    /// XBR Network membership levels
    enum MemberLevel { NULL, ACTIVE, VERIFIED, RETIRED, PENALTY, BLOCKED }

    /// XBR Market Actor types
    enum ActorType { NULL, PROVIDER, CONSUMER }

    // //////// container types

    /// Container type for holding XBR Network membership information.
    struct Member {
        /// Time (block.timestamp) when the member was (initially) registered.
        uint registered;

        /// The IPFS Multihash of the XBR EULA being agreed to and stored as one ZIP file archive on IPFS. Currently, this must be equal to "QmU7Gizbre17x6V2VR1Q2GJEjz6m8S1bXmBtVxS2vmvb81"
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

        /// All market payment/paying channels.
        address[] channels;

        /// Provider (seller) actors joined in the market by actor address.
        mapping(address => Actor) providerActors;

        /// Consumer (buyer) actors joined in the market by actor address.
        mapping(address => Actor) consumerActors;

        /// Current payment channel by (buyer) delegate.
        mapping(address => address) currentPaymentChannelByDelegate;

        /// Current paying channel by (seller) delegate.
        mapping(address => address) currentPayingChannelByDelegate;
    }

    /// Container type for holding paying channel request information. FIXME: make this event-based (to save gas).
    struct PayingChannelRequest {
        bytes16 marketId;
        address sender;
        address delegate;
        address recipient;
        uint256 amount;
        uint32 timeout;
    }

    // //////// events for MEMBERS

    /// Event emitted when a new member joined the XBR Network.
    event MemberCreated (address indexed member, uint registered, string eula, string profile, MemberLevel level);

    /// Event emitted when a member leaves the XBR Network.
    event MemberRetired (address member);

    // //////// events for MARKETS

    /// Event emitted when a new market was created.
    event MarketCreated (bytes16 indexed marketId, uint created, uint32 marketSeq, address owner, string terms, string meta,
        address maker, uint256 providerSecurity, uint256 consumerSecurity, uint256 marketFee);

    /// Event emitted when a market was updated.
    event MarketUpdated (bytes16 indexed marketId, uint32 marketSeq, address owner, string terms, string meta,
        address maker, uint256 providerSecurity, uint256 consumerSecurity, uint256 marketFee);

    /// Event emitted when a market was closed.
    event MarketClosed (bytes16 indexed marketId);

    /// Event emitted when a new actor joined a market.
    event ActorJoined (bytes16 indexed marketId, address actor, uint8 actorType, uint joined, uint256 security, string meta);

    /// Event emitted when an actor has left a market.
    event ActorLeft (bytes16 indexed marketId, address actor, uint8 actorType);

    /// Event emitted when a new payment channel was created in a market.
    event ChannelCreated (bytes16 indexed marketId, address sender, address delegate,
        address receiver, address channel, XBRChannel.ChannelType channelType);

    /// Event emitted when a new request for a paying channel was created in a market.
    event PayingChannelRequestCreated (bytes16 indexed marketId, address sender, address recipient, address delegate,
        uint256 amount, uint32 timeout);

    // Note: closing event of payment channels are emitted from XBRChannel (not from here)

    /// Created markets are sequence numbered using this counter (to allow deterministic collison-free IDs for markets)
    uint32 public marketSeq = 1;

    /// XBR network EULA (IPFS Multihash).
    string public constant eula = "QmU7Gizbre17x6V2VR1Q2GJEjz6m8S1bXmBtVxS2vmvb81";

    /// XBR Network ERC20 token (XBR for the CrossbarFX technology stack)
    XBRToken public token;

    /// Address of the `XBR Network Organization <https://xbr.network/>`_
    address public organization;

    /// Current XBR Network members ("member directory").
    mapping(address => Member) public members;

    /// Current XBR Markets ("market directory")
    mapping(bytes16 => Market) public markets;

    /// Index: maker address => market ID
    mapping(address => bytes16) public marketsByMaker;

    /// Index: delegate address =>
    mapping(address => address) public paymentChannels;

    /**
     * Create a new network.
     *
     * @param token_ The token to run this network on.
     * @param organization_ The network technology provider and ecosystem sponsor.
     */
    constructor (address token_, address organization_) public {

        token = XBRToken(token_);
        organization = organization_;

        // Technical creator is XBR member (by definition).
        members[msg.sender] = Member(block.timestamp, "", "", MemberLevel.VERIFIED);
    }

    /**
     * Register sender in the XBR Network. All XBR stakeholders, namely XBR Data Providers,
     * XBR Data Consumers and XBR Data Market Operators, must first register
     * with the XBR Network on the global blockchain by calling this function.
     *
     * @param eula_ The IPFS Multihash of the XBR EULA being agreed to and stored as one ZIP file archive on IPFS.
     * @param profile_ Optional public member profile: the IPFS Multihash of the member profile stored in IPFS.
     */
    function register (string memory eula_, string memory profile_) public {
        // check that sender is not already a member
        require(uint8(members[msg.sender].level) == 0, "MEMBER_ALREADY_REGISTERED");

        // check that the EULA the member accepted is the one we expect
        require(keccak256(abi.encode(eula_)) ==
                keccak256(abi.encode(eula)), "INVALID_EULA");

        // remember the member
        uint registered = block.timestamp;
        members[msg.sender] = Member(registered, eula_, profile_, MemberLevel.ACTIVE);

        // notify observers of new member
        emit MemberCreated(msg.sender, registered, eula_, profile_, MemberLevel.ACTIVE);
    }

    /**
     * Leave the XBR Network.
     */
    function unregister () public {
        require(uint8(members[msg.sender].level) != 0, "NO_SUCH_MEMBER");
        require((uint8(members[msg.sender].level) == uint8(MemberLevel.ACTIVE)) ||
                (uint8(members[msg.sender].level) == uint8(MemberLevel.VERIFIED)), "MEMBER_NOT_ACTIVE");

        // FIXME: check that the member has no active objects associated anymore

        members[msg.sender].level = MemberLevel.RETIRED;

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
    function setMemberLevel (address member, MemberLevel level) public onlyMaintainer {
        require(uint(members[msg.sender].level) != 0, "NO_SUCH_MEMBER");

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
        uint256 providerSecurity, uint256 consumerSecurity, uint256 marketFee) public {

        // the market operator (owner) must be a registered member
        require(members[msg.sender].level == MemberLevel.ACTIVE ||
                members[msg.sender].level == MemberLevel.VERIFIED, "SENDER_NOT_A_MEMBER");

        // market must not yet exist (to generate a new marketId: )
        require(markets[marketId].owner == address(0), "MARKET_ALREADY_EXISTS");

        // must provide a valid market maker address already when creating a market
        require(maker != address(0), "INVALID_MAKER");

        // the market maker can only work for one market
        require(marketsByMaker[maker] == bytes16(0), "MAKER_ALREADY_WORKING_FOR_OTHER_MARKET");

        // provider security must be non-negative (and obviously smaller than the total token supply)
        require(providerSecurity >= 0 && providerSecurity <= token.totalSupply(), "INVALID_PROVIDER_SECURITY");

        // consumer security must be non-negative (and obviously smaller than the total token supply)
        require(consumerSecurity >= 0 && consumerSecurity <= token.totalSupply(), "INVALID_CONSUMER_SECURITY");

        // FIXME: treat market fee
        require(marketFee >= 0 && marketFee < (token.totalSupply() - 10**7) * 10**18, "INVALID_MARKET_FEE");

        // now remember out new market ..
        uint created = block.timestamp;
        markets[marketId] = Market(created, marketSeq, msg.sender, terms, meta, maker, providerSecurity,
            consumerSecurity, marketFee, new address[](0));

        // .. and the market-maker-to-market mapping
        marketsByMaker[maker] = marketId;

        // increment market sequence for next market
        marketSeq = marketSeq + 1;

        // notify observers (eg a dormant market maker waiting to be associated)
        emit MarketCreated(marketId, created, marketSeq, msg.sender, terms, meta, maker,
                                providerSecurity, consumerSecurity, marketFee);
    }

    /**
     * Update market information, like market terms, metadata or maker address.
     *
     * @param marketId The ID of the market to update.
     * @param terms When terms should be updated, provide a string of non-zero length with
     *              an IPFS Multihash pointing to the new ZIP file with market terms.
     * @param meta When metadata should be updated, provide a string of non-zero length with
     *             an IPFS Multihash pointing to the new RDF/Turtle file with market metadata.
     * @param maker When maker should be updated, provide a non-zero address.
     * @param providerSecurity Provider security to set that will apply for new members (providers) joining
     *                         the market. It will NOT apply to current market members.
     * @param consumerSecurity Consumer security to set that will apply for new members (consumers) joining
     *                         the market. It will NOT apply to current market members.
     * @param marketFee New market fee to set. The new market fee will apply to all new payment channels
     *                  opened. It will NOT apply to already opened (or closed) payment channels.
     * @return Flag indicating weather the market information was actually updated or left unchanged.
     */
    function updateMarket(bytes16 marketId, string memory terms, string memory meta, address maker,
        uint256 providerSecurity, uint256 consumerSecurity, uint256 marketFee) public returns (bool) {

        Market storage market = markets[marketId];

        require(market.owner != address(0), "NO_SUCH_MARKET");
        require(market.owner == msg.sender, "NOT_AUTHORIZED");
        require(marketsByMaker[maker] == bytes16(0), "MAKER_ALREADY_WORKING_FOR_OTHER_MARKET");
        require(marketFee >= 0 && marketFee < (10**9 - 10**7) * 10**18, "INVALID_MARKET_FEE");

        bool wasChanged = false;

        // for these knobs, only update when non-zero values provided
        if (maker != address(0) && maker != market.maker) {
            markets[marketId].maker = maker;
            wasChanged = true;
        }
        if (bytes(terms).length > 0 && keccak256(abi.encode(terms)) != keccak256(abi.encode(market.terms))) {
            markets[marketId].terms = terms;
            wasChanged = true;
        }
        if (bytes(meta).length > 0 && keccak256(abi.encode(meta)) != keccak256(abi.encode(market.meta))) {
            markets[marketId].meta = meta;
            wasChanged = true;
        }

        // for these knobs, we allow updating to zero value
        if (providerSecurity != market.providerSecurity) {
            markets[marketId].providerSecurity = providerSecurity;
            wasChanged = true;
        }
        if (consumerSecurity != market.consumerSecurity) {
            markets[marketId].consumerSecurity = consumerSecurity;
            wasChanged = true;
        }
        if (marketFee != market.marketFee) {
            markets[marketId].marketFee = marketFee;
            wasChanged = true;
        }

        if (wasChanged) {
            emit MarketUpdated(marketId, market.marketSeq, market.owner, market.terms, market.meta, market.maker,
                    market.providerSecurity, market.consumerSecurity, market.marketFee);
        }

        return wasChanged;
    }

    /**
     * Close a market. A closed market will not accept new memberships.
     *
     * @param marketId The ID of the market to close.
     */
    function closeMarket (bytes16 marketId) public view {
        require(markets[marketId].owner != address(0), "NO_SUCH_MARKET");
        require(markets[marketId].owner == msg.sender, "NOT_AUTHORIZED");
        // FIXME
        require(false, "NOT_IMPLEMENTED");
    }

    /**
     * Join the given XBR market as the specified type of actor, which must be PROVIDER or CONSUMER.
     *
     * @param marketId The ID of the XBR data market to join.
     * @param actorType The type of actor under which to join: PROVIDER or CONSUMER.
     * @param meta The XBR market provider/consumer metadata. IPFS Multihash pointing to a JSON file with metadata.
     */
    function joinMarket (bytes16 marketId, uint8 actorType, string memory meta) public returns (uint256) {

        // the joining sender must be a registered member
        require(members[msg.sender].level == MemberLevel.ACTIVE, "SENDER_NOT_A_MEMBER");

        // the market to join must exist
        require(markets[marketId].owner != address(0), "NO_SUCH_MARKET");

        // the joining member must join as a data provider (seller) or data consumer (buyer)
        require(actorType == uint8(ActorType.PROVIDER) ||
                actorType == uint8(ActorType.CONSUMER), "INVALID_ACTOR_TYPE");

        // get the security amount required for joining the market (if any)
        uint256 security;
        // if (uint8(actorType) == uint8(ActorType.PROVIDER)) {
        if (actorType == uint8(ActorType.PROVIDER)) {
            // the joining member must not be joined as a provider already
            require(uint8(markets[marketId].providerActors[msg.sender].joined) == 0, "ALREADY_JOINED_AS_PROVIDER");
            security = markets[marketId].providerSecurity;
        } else  {
            // the joining member must not be joined as a consumer already
            require(uint8(markets[marketId].consumerActors[msg.sender].joined) == 0, "ALREADY_JOINED_AS_CONSUMER");
            security = markets[marketId].consumerSecurity;
        }

        if (security > 0) {
            // Transfer (if any) security to the market owner (for ActorType.CONSUMER or ActorType.PROVIDER)
            bool success = token.transferFrom(msg.sender, markets[marketId].owner, security);
            require(success, "JOIN_MARKET_TRANSFER_FROM_FAILED");
        }

        // remember actor (by actor address) within market
        uint joined = block.timestamp;
        if (actorType == uint8(ActorType.PROVIDER)) {
            markets[marketId].providerActors[msg.sender] = Actor(joined, security, meta);
        } else {
            markets[marketId].consumerActors[msg.sender] = Actor(joined, security, meta);
        }

        // emit event ActorJoined(bytes16 marketId, address actor, ActorType actorType, uint joined, uint256 security, string meta)
        emit ActorJoined(marketId, msg.sender, actorType, joined, security, meta);

        // return effective security transferred
        return security;
    }

    /**
     * As a market actor (participant) currently member of a market, leave that market.
     * A market can only be left when all payment channels of the sender are closed (or expired).
     *
     * @param marketId The ID of the market to leave.
     */
    function leaveMarket (bytes16 marketId) public view {
        require(markets[marketId].owner != address(0), "NO_SUCH_MARKET");
        // FIXME
        require(false, "NOT_IMPLEMENTED");
    }

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
        uint256 amount, uint32 timeout) public returns (address paymentChannel) {

        // market must exist
        require(markets[marketId].owner != address(0), "NO_SUCH_MARKET");

        // sender must be consumer in the market
        require(uint8(markets[marketId].consumerActors[msg.sender].joined) != 0, "NO_CONSUMER_ROLE");

        // technical recipient of the unidirectional, half-legged channel must be the
        // owner (operator) of the market
        require(recipient == markets[marketId].owner, "INVALID_CHANNEL_RECIPIENT");

        // must provide a valid off-chain channel delegate address
        require(delegate != address(0), "INVALID_CHANNEL_DELEGATE");

        // payment channel amount must be positive
        require(amount > 0 && amount <= token.totalSupply(), "INVALID_CHANNEL_AMOUNT");

        // create new payment channel contract
        XBRChannel channel = new XBRChannel(address(token), marketId, msg.sender, delegate, recipient, amount, timeout,
            XBRChannel.ChannelType.PAYMENT);

        // transfer tokens (initial balance) into payment channel contract
        bool success = token.transferFrom(msg.sender, address(channel), amount);
        require(success, "OPEN_CHANNEL_TRANSFER_FROM_FAILED");

        // remember the new payment channel associated with the market
        markets[marketId].channels.push(address(channel));

        // emit event ChannelCreated(bytes16 marketId, address sender, address delegate,
        //      address receiver, address channel)
        emit ChannelCreated(marketId, channel.sender(), channel.delegate(), channel.recipient(),
            address(channel), XBRChannel.ChannelType.PAYMENT);

        // return address of new channel contract
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
        uint256 amount, uint32 timeout) public {

        // market must exist
        require(markets[marketId].owner != address(0), "NO_SUCH_MARKET");

        // market must have a market maker associated
        require(markets[marketId].maker != address(0), "NO_ACTIVE_MARKET_MAKER");

        // sender must be provider in the market
        require(uint8(markets[marketId].providerActors[msg.sender].joined) != 0, "NO_PROVIDER_ROLE");

        // emit event PayingChannelRequestCreated(bytes16 marketId, address sender, address recipient,
        //      address delegate, uint256 amount, uint32 timeout)
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
        uint256 amount, uint32 timeout) public returns (address paymentChannel) {

        // market must exist
        require(markets[marketId].owner != address(0), "NO_SUCH_MARKET");

        // sender must be market maker for market
        require(markets[marketId].maker == msg.sender, "SENDER_NOT_MAKER");

        // recipient must be provider in the market
        require(uint8(markets[marketId].providerActors[recipient].joined) != 0, "RECIPIENT_NOT_PROVIDER");

        // create new paying channel contract
        XBRChannel channel = new XBRChannel(address(token), marketId, msg.sender, delegate, recipient, amount,
            timeout, XBRChannel.ChannelType.PAYING);

        // transfer tokens (initial balance) into payment channel contract
        XBRToken _token = XBRToken(token);
        bool success = _token.transferFrom(msg.sender, address(channel), amount);
        require(success, "OPEN_CHANNEL_TRANSFER_FROM_FAILED");

        // remember the new payment channel associated with the market
        markets[marketId].channels.push(address(channel));

        // emit event ChannelCreated(bytes16 marketId, address sender, address delegate,
        //  address receiver, address channel)
        emit ChannelCreated(marketId, channel.sender(), channel.delegate(), channel.recipient(),
            address(channel), XBRChannel.ChannelType.PAYING);

        return address(channel);
    }
}
