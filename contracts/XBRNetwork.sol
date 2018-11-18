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
 * @title XBR Network main smart contract.
 * @author The XBR Project
 */
contract XBRNetwork is XBRMaintained {

    // //////// enums

    /// XBR Network membership levels
    enum MemberLevel { NULL, ACTIVE, VERIFIED, RETIRED, PENALTY, BLOCKED }

    /// XBR Market Actor types
    enum ActorType { NULL, NETWORK, MARKET, PROVIDER, CONSUMER }

    /// XBR Carrier Node types
    enum NodeType { NULL, MASTER, CORE, EDGE }

    // //////// container types

    /// Container type for holding XBR Network membership information.
    struct Member {
        string eula;
        string profile;
        MemberLevel level;
    }

    /// Container type for holding XBR Domain information.
    struct Domain {
        /// Domain sequence.
        uint32 domainSeq;

        /// Domain owner.
        address owner;

        /// Domain signing key (Ed25519 public key).
        bytes32 domainKey;

        /// Software stack license file on IPFS (required).
        string license;

        /// Optional domain terms on IPFS.
        string terms;

        /// Optional domain metadata on IPFS.
        string meta;

        /// Nodes within the domain.
        bytes16[] nodes;
    }

    /// Container type for holding XBR Domain Nodes information.
    struct Node {
        bytes16 domain;

        /// Type of node.
        NodeType nodeType;

        /// Node key (Ed25519 public key).
        bytes32 key;

        /// Optional (encrypted) node configuration on IPFS.
        string config;
    }

    /// Container type for holding XBR Market information.
    struct Market {
        uint32 marketSeq;
        address owner;
        string terms;
        string meta;
        address maker;
        uint256 providerSecurity;
        uint256 consumerSecurity;
        uint256 marketFee;
        address[] channels;
        address[] actorAddresses;
        mapping(address => Actor) actors;
    }

    /// Container type for holding XBR Market Actors information.
    struct Actor {
        ActorType actorType;
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
    event MemberCreated (address indexed member, string eula, string profile, MemberLevel level);

    /// Event emitted when a member leaves the XBR Network.
    event MemberRetired (address member);

    // //////// events for DOMAINS

    /// Event emitted when a new domain was created.
    event DomainCreated (bytes16 domainId, uint32 domainSeq, address owner,
        bytes32 domainKey, string license, string terms, string meta);

    /// Event emitted when a domain was updated.
    event DomainUpdated (bytes16 domainId, uint32 domainSeq, address owner,
        bytes32 domainKey, string license, string terms, string meta);

    /// Event emitted when a domain was closed.
    event DomainClosed (bytes16 domainId);

    /// Event emitted when a new node was paired with the domain.
    event NodePaired (bytes16 domainId, bytes16 nodeId, bytes32 nodeKey, string config);

    /// Event emitted when a node was updated.
    event NodeUpdated (bytes16 domainId, bytes16 nodeId, bytes32 nodeKey, string config);

    /// Event emitted when a node was released from a domain.
    event NodeReleased (bytes16 domainId, bytes16 nodeId);

    // //////// events for MARKETS

    /// Event emitted when a new market was created.
    event MarketCreated (bytes16 marketId, uint32 marketSeq, address owner, string terms, string meta,
        address maker, uint256 providerSecurity, uint256 consumerSecurity, uint256 marketFee);

    /// Event emitted when a market was updated.
    event MarketUpdated (bytes16 marketId, uint32 marketSeq, address owner, string terms, string meta,
        address maker, uint256 providerSecurity, uint256 consumerSecurity, uint256 marketFee);

    /// Event emitted when a market was closed.
    event MarketClosed (bytes16 marketId);

    /// Event emitted when a new actor joined a market.
    event ActorJoined (bytes16 marketId, address actor, ActorType actorType);

    /// Event emitted when an actor has left a market.
    event ActorLeft (bytes16 marketId, address actor);

    /// Event emitted when a new payment channel was created in a market.
    event PaymentChannelCreated (bytes16 marketId, address sender, address delegate,
        address receiver, address channel);

    /// Event emitted when a new request for a paying channel was created in a market.
    event PayingChannelRequestCreated (bytes16 marketId, address sender, address delegate,
        address receiver, uint256 amount, uint32 timeout);

    // Note: closing event of payment channels are emitted from XBRPaymentChannel (not from here)

    // Created markets are sequence numbered using this counter (to allow deterministic collison-free IDs for markets)
    uint32 private marketSeq = 1;

    // Created domains are sequence numbered using this counter (to allow deterministic collison-free IDs for domains)
    uint32 private domainSeq = 1;

    /// Address of the XBR Network ERC20 token (XBR for the CrossbarFX technology stack)
    address public token;

    /// Address of the `XBR Network Organization <https://xbr.network/>`_
    address public organization;

    /// Current XBR Network members ("member directory").
    mapping(address => Member) private members;

    /// Current XBR Domains ("domain directory")
    mapping(bytes16 => Domain) private domains;

    /// Current XBR Nodes ("node directory");
    mapping(bytes16 => Node) private nodes;

    /// Index: node public key => (market ID, node ID)
    mapping(bytes32 => bytes16) private nodesByKey;

    /// Current XBR Markets ("market directory")
    mapping(bytes16 => Market) private markets;

    /// Index: maker address => market ID
    mapping(address => bytes16) private marketsByMaker;

    /**
     * Create a new network.
     *
     * @param token_ The token to run this network on.
     * @param organization_ The network technology provider and ecoystem sponsor.
     */
    constructor (address token_, address organization_) public {
        token = token_;
        organization = organization_;

        members[msg.sender] = Member("", "", MemberLevel.VERIFIED);
    }

    /**
     * Join the XBR Network. All XBR stakeholders, namely XBR Data Providers,
     * XBR Data Consumers, XBR Data Markets and XBR Data Clouds, must register
     * with the XBR Network on the global blockchain by calling this function.
     *
     * @param eula The IPFS Multihash of the XBR EULA being agreed to and stored as one ZIP file archive on IPFS.
     *             Currently, this must be equal to "QmU7Gizbre17x6V2VR1Q2GJEjz6m8S1bXmBtVxS2vmvb81"
     * @param profile Optional public member profile: the IPFS Multihash of the member profile stored in IPFS.
     */
    function register (string eula, string profile) public {
        require(uint(members[msg.sender].level) == 0, "MEMBER_ALREADY_EXISTS");
        require(keccak256(abi.encode(eula)) ==
                keccak256(abi.encode("QmU7Gizbre17x6V2VR1Q2GJEjz6m8S1bXmBtVxS2vmvb81")), "INVALID_EULA");

        members[msg.sender] = Member(eula, profile, MemberLevel.ACTIVE);

        emit MemberCreated(msg.sender, eula, profile, MemberLevel.ACTIVE);
    }

    /**
     * Leave the XBR Network.
     */
    function unregister () public {
        require(uint(members[msg.sender].level) != 0, "NO_SUCH_MEMBER");

        members[msg.sender].level = MemberLevel.RETIRED;

        emit MemberRetired(msg.sender);
    }

    /**
     * Returns XBR Network member level given an address.
     *
     * @param member The address to lookup the XBR Network member level for.
     */
    function getMemberLevel (address member) public view returns (MemberLevel) {
        return members[member].level;
    }

    /**
     * Returns XBR Network member EULA given an address.
     *
     * @param member The address to lookup the XBR Network member EULA for.
     */
    function getMemberEula (address member) public view returns (string) {
        return members[member].eula;
    }

    /**
     * Returns XBR Network member profile given an address.
     *
     * @param member The address to lookup the XBR Network member profile for.
     */
    function getMemberProfile (address member) public view returns (string) {
        return members[member].profile;
    }

    /**
     * Manually override the member level of a XBR Network member. Being able to do so
     * currently serves two purposes:
     *
     * - having a last resort to handle situation where members violated the EULA
     * - being able to manually patch things in error/bug cases
     */
    function setMemberLevel (address member, MemberLevel level) public onlyMaintainer {
        require(uint(members[msg.sender].level) != 0, "NO_SUCH_MEMBER");

        members[member].level = level;
    }

    /**
     *  Create a new XBR domain. Then sender ot the transaction must be XBR network member
     *  and automatically becomes owner of the new domain.
     *
     *  @param domainId The ID of the domain to create. Must be unique (not yet existing).
     *  @param domainKey The domain signing key. A Ed25519 (https://ed25519.cr.yp.to/) public key.
     *  @param license The license for the software stack running the domain. IPFS Multihash
     *                 pointing to a JSON/YAML file signed by the project release key.
     */
    function createDomain (bytes16 domainId, bytes32 domainKey, string license,
        string terms, string meta) public {

        require(domains[domainId].owner == address(0), "DOMAIN_ALREADY_EXISTS");

        domains[domainId] = Domain(domainSeq, msg.sender, domainKey, license, terms, meta, new bytes16[](0));

        domainSeq = domainSeq + 1;

        emit DomainCreated(domainId, domainSeq, msg.sender, domainKey, license, terms, meta);
    }

    /**
     *
     */
    function pairNode (bytes16 nodeId, bytes16 domainId, NodeType nodeType, bytes32 nodeKey, string config) public {
        require(domains[domainId].owner != address(0), "NO_SUCH_DOMAIN");
        require(nodesByKey[nodeKey] == bytes16(0), "DUPLICATE_NODE_KEY");

        require(uint8(nodes[nodeId].nodeType) == 0, "NODE_ALREADY_PAIRED");
        require(uint8(nodeType) == uint8(NodeType.MASTER) || uint8(nodeType) == uint8(NodeType.EDGE));

        nodes[nodeId] = Node(domainId, nodeType, nodeKey, config);
        domains[domainId].nodes.push(nodeId);
    }

    /**
     * Create a new XBR market. The sender of the transaction must be XBR network member
     * and automatically becomes owner of the new market.
     *
     * @param marketId The ID of the market to create. Must be unique (not yet existing).
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
    function createMarket (bytes16 marketId, string terms, string meta, address maker, uint256 providerSecurity,
        uint256 consumerSecurity, uint256 marketFee) public {

        XBRToken _token = XBRToken(token);
        
        require(markets[marketId].owner == address(0), "MARKET_ALREADY_EXISTS");
        require(maker != address(0), "INVALID_MAKER");
        require(marketsByMaker[maker] == bytes16(0), "MAKER_ALREADY_WORKING_FOR_OTHER_MARKET");
        require(providerSecurity >= 0 && providerSecurity <= _token.totalSupply(), "INVALID_PROVIDER_SECURITY");
        require(consumerSecurity >= 0 && consumerSecurity <= _token.totalSupply(), "INVALID_CONSUMER_SECURITY");
        require(marketFee >= 0 && marketFee < (_token.totalSupply() - 10**7) * 10**18, "INVALID_MARKET_FEE");

        markets[marketId] = Market(marketSeq, msg.sender, terms, meta, maker, providerSecurity,
            consumerSecurity, marketFee, new address[](0), new address[](0));

        markets[marketId].actors[msg.sender] = Actor(ActorType.MARKET);
        markets[marketId].actorAddresses.push(maker);

        marketsByMaker[maker] = marketId;

        marketSeq = marketSeq + 1;

        emit MarketCreated(marketId, marketSeq, msg.sender, terms, meta, maker,
                                providerSecurity, consumerSecurity, marketFee);
    }

    /**
     *
     */
    function getMarketByMaker (address maker) public view returns (bytes16) {
        return marketsByMaker[maker];
    }

    /**
     *
     */
    function getMarketOwner (bytes16 marketId) public view returns (address) {
        return markets[marketId].owner;
    }

    /**
     *
     */
    function getMarketTerms (bytes16 marketId) public view returns (string) {
        return markets[marketId].terms;
    }

    /**
     *
     */
    function getMarketMeta (bytes16 marketId) public view returns (string) {
        return markets[marketId].meta;
    }

    /**
     *
     */
    function getMarketMaker (bytes16 marketId) public view returns (address) {
        return markets[marketId].maker;
    }

    /**
     *
     */
    function getMarketProviderSecurity (bytes16 marketId) public view returns (uint256) {
        return markets[marketId].providerSecurity;
    }

    /**
     *
     */
    function getMarketConsumerSecurity (bytes16 marketId) public view returns (uint256) {
        return markets[marketId].consumerSecurity;
    }

    /**
     *
     */
    function getMarketFee (bytes16 marketId) public view returns (uint256) {
        return markets[marketId].marketFee;
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
     */
    function updateMarket(bytes16 marketId, string terms, string meta, address maker,
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
    }

    /**
     * Join the given XBR market as the specified type of actor, which must be PROVIDER or CONSUMER.
     *
     * @param marketId The ID of the XBR data market to join.
     * @param actorType The type of actor under which to join: PROVIDER or CONSUMER.
     */
    function joinMarket (bytes16 marketId, ActorType actorType) public {
        require(markets[marketId].owner != address(0), "NO_SUCH_MARKET");
        require(uint8(markets[marketId].actors[msg.sender].actorType) == 0, "ACTOR_ALREADY_JOINED");
        require(uint8(actorType) == uint8(ActorType.MARKET) ||
            uint8(actorType) == uint8(ActorType.PROVIDER) || uint8(actorType) == uint8(ActorType.CONSUMER));

        markets[marketId].actors[msg.sender] = Actor(actorType);
        markets[marketId].actorAddresses.push(msg.sender);
    }

    /**
     *
     */
    function getAllMarketActors(bytes16 marketId) public view returns (address[]) {
        return markets[marketId].actorAddresses;
    }

    /**
     *
     */
    function getMarketActorType (bytes16 marketId, address actor) public view returns (ActorType) {
        return markets[marketId].actors[actor].actorType;
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
    }

    /**
     * Open a new payment channel and deposit an amount of XBR token into a market.
     * The procedure returns
     */
    function openPaymentChannel (bytes16 marketId, address consumer, uint256 amount) public returns
        (address paymentChannel) {

        require(markets[marketId].owner != address(0), "NO_SUCH_MARKET");

        // bytes16 marketId, address sender, address delegate, address recipient, uint256 amount, uint32 timeout
        XBRPaymentChannel channel = new XBRPaymentChannel(marketId, msg.sender, consumer, address(0), amount, 60);

        XBRToken _token = XBRToken(token);
        bool success = _token.transferFrom(msg.sender, channel, amount);
        require(success, "OPEN_CHANNEL_TRANSFER_FROM_FAILED");

        markets[marketId].channels.push(channel);

        // bytes16 marketId, address sender, address delegate, address receiver, address channel);
        emit PaymentChannelCreated(marketId, msg.sender, consumer, markets[marketId].owner, channel);

        return channel;
    }

    /**
     * Lookup all payment channels for a XBR Market.
     *
     * @param marketId The XBR Market to get payment channels for.
     */
    function getAllMarketPaymentChannels(bytes16 marketId) public view returns (address[]) {
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
    function requestPayingChannel (bytes16 marketId, address provider, uint256 amount) public {

        require(markets[marketId].owner != address(0), "NO_SUCH_MARKET");
        require(markets[marketId].maker != address(0), "NO_ACTIVE_MARKET_MAKER");

        // bytes16 marketId, address sender, address delegate, address receiver, uint256 amount, uint32 timeout);
        emit PayingChannelRequestCreated(marketId, markets[marketId].maker, provider, msg.sender, amount, 10);
    }
}
