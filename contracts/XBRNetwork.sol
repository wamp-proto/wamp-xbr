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
    enum ActorType { NULL, NETWORK, MARKET, PROVIDER, CONSUMER }

    /// XBR Domain status values
    enum DomainStatus { NULL, ACTIVE, CLOSED }

    /// XBR Carrier Node types
    enum NodeType { NULL, MASTER, CORE, EDGE }

    // //////// container types

    /// Container type for holding XBR Network membership information.
    struct Member {
        /// The IPFS Multihash of the XBR EULA being agreed to and stored as one ZIP file archive on IPFS. Currently, this must be equal to "QmU7Gizbre17x6V2VR1Q2GJEjz6m8S1bXmBtVxS2vmvb81"
        string eula;

        /// Optional public member profile: the IPFS Multihash of the member profile stored in IPFS.
        string profile;

        /// Current member level.
        MemberLevel level;
    }

    /// Container type for holding XBR Market Actors information.
    struct Actor {
        /// The type of the actor within the market.
        ActorType actorType;

        /// Security deposited by actor.
        uint256 security;

        /// Metadata attached to an actor in a market.
        string meta;

        /// Actor WAMP key (Ed25519 public key).
        bytes32 key;
    }

    /// Container type for holding XBR Domain information.
    struct Domain {
        /// Domain sequence.
        uint32 domainSeq;

        /// Domain status
        DomainStatus status;

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
        mapping(address => address) currentPaymentChannelByDelegate;
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

    struct DelegateAssociation {
        address delegate;
        bytes32 pubkey;
        bytes16 marketId;
        ActorType actorType;
    }

    // //////// events for MEMBERS

    /// Event emitted when a new member joined the XBR Network.
    event MemberCreated (address indexed member, string eula, string profile, MemberLevel level);

    /// Event emitted when a member leaves the XBR Network.
    event MemberRetired (address member);

    // //////// events for DOMAINS

    /// Event emitted when a new domain was created.
    event DomainCreated (bytes16 indexed domainId, uint32 domainSeq, DomainStatus status, address owner,
        bytes32 domainKey, string license, string terms, string meta);

    /// Event emitted when a domain was updated.
    event DomainUpdated (bytes16 indexed domainId, uint32 domainSeq, DomainStatus status, address owner,
        bytes32 domainKey, string license, string terms, string meta);

    /// Event emitted when a domain was closed.
    event DomainClosed (bytes16 indexed domainId, DomainStatus status);

    /// Event emitted when a new node was paired with the domain.
    event NodePaired (bytes16 indexed domainId, bytes16 nodeId, bytes32 nodeKey, string config);

    /// Event emitted when a node was updated.
    event NodeUpdated (bytes16 indexed domainId, bytes16 nodeId, bytes32 nodeKey, string config);

    /// Event emitted when a node was released from a domain.
    event NodeReleased (bytes16 indexed domainId, bytes16 nodeId);

    // //////// events for MARKETS

    /// Event emitted when a new market was created.
    event MarketCreated (bytes16 indexed marketId, uint32 marketSeq, address owner, string terms, string meta,
        address maker, uint256 providerSecurity, uint256 consumerSecurity, uint256 marketFee);

    /// Event emitted when a market was updated.
    event MarketUpdated (bytes16 indexed marketId, uint32 marketSeq, address owner, string terms, string meta,
        address maker, uint256 providerSecurity, uint256 consumerSecurity, uint256 marketFee);

    /// Event emitted when a market was closed.
    event MarketClosed (bytes16 indexed marketId);

    /// Event emitted when a new actor joined a market.
    event ActorJoined (bytes16 indexed marketId, address actor, ActorType actorType, uint256 security, string meta);

    /// Event emitted when an actor has left a market.
    event ActorLeft (bytes16 indexed marketId, address actor, ActorType actorType);

    /// Event emitted when a new payment channel was created in a market.
    event ChannelCreated (bytes16 indexed marketId, address sender, address delegate,
        address receiver, address channel, XBRChannel.ChannelType channelType);

    /// Event emitted when a new request for a paying channel was created in a market.
    event PayingChannelRequestCreated (bytes16 indexed marketId, address sender, address recipient, address delegate,
        uint256 amount, uint32 timeout);

    // Note: closing event of payment channels are emitted from XBRChannel (not from here)

    // Created markets are sequence numbered using this counter (to allow deterministic collison-free IDs for markets)
    uint32 private marketSeq = 1;

    // Created domains are sequence numbered using this counter (to allow deterministic collison-free IDs for domains)
    uint32 private domainSeq = 1;

    /// XBR Network ERC20 token (XBR for the CrossbarFX technology stack)
    XBRToken private token;

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

    /// Index: delegate address =>
    mapping(address => address) private paymentChannels;

    /**
     * Create a new network.
     *
     * @param token_ The token to run this network on.
     * @param organization_ The network technology provider and ecosystem sponsor.
     */
    constructor (address token_, address organization_) public {
        token = XBRToken(token_);
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
    function register (string memory eula, string memory profile) public {
        require(uint(members[msg.sender].level) == 0, "MEMBER_ALREADY_REGISTERED");
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

        // FIXME: check that the member has no active objects associated anymore

        members[msg.sender].level = MemberLevel.RETIRED;

        emit MemberRetired(msg.sender);
    }

    /**
     * Returns XBR Network member level given an address.
     *
     * @param member The address to lookup the XBR Network member level for.
     * @return The current member level of the member.
     */
    function getMemberLevel (address member) public view returns (MemberLevel) {
        return members[member].level;
    }

    /**
     * Returns XBR Network member EULA given an address.
     *
     * @param member The address to lookup the XBR Network member EULA for.
     * @return IPFS Multihash pointing to XBR Network EULA file on IPFS.
     */
    function getMemberEula (address member) public view returns (string memory) {
        return members[member].eula;
    }

    /**
     * Returns XBR Network member profile given an address.
     *
     * @param member The address to lookup the XBR Network member profile for.
     * @return IPFS Multihash pointing to member profile file on IPFS.
     */
    function getMemberProfile (address member) public view returns (string memory) {
        return members[member].profile;
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
     *  Create a new XBR domain. Then sender to the transaction must be XBR network member
     *  and automatically becomes owner of the new domain.
     *
     *  @param domainId The ID of the domain to create. Must be globally unique (not yet existing).
     *  @param domainKey The domain signing key. A Ed25519 (https://ed25519.cr.yp.to/) public key.
     *  @param license The license for the software stack running the domain. IPFS Multihash
     *                 pointing to a JSON/YAML file signed by the project release key.
     */
    function createDomain (bytes16 domainId, bytes32 domainKey, string memory license,
        string memory terms, string memory meta) public {

        require(members[msg.sender].level == MemberLevel.ACTIVE ||
                members[msg.sender].level == MemberLevel.VERIFIED, "NOT_A_MEMBER");

        require(domains[domainId].owner == address(0), "DOMAIN_ALREADY_EXISTS");

        domains[domainId] = Domain(domainSeq, DomainStatus.ACTIVE, msg.sender, domainKey,
                                    license, terms, meta, new bytes16[](0));

        emit DomainCreated(domainId, domainSeq, DomainStatus.ACTIVE, msg.sender, domainKey,
                            license, terms, meta);

        domainSeq = domainSeq + 1;
    }

    /**
     * Close an existing XBR domain. The sender must be owner of the domain, and the domain
     * must not have any nodes paired (anymore).
     *
     * @param domainId The ID of the domain to close.
     */
    function closeDomain (bytes16 domainId) public {
        require(members[msg.sender].level == MemberLevel.ACTIVE ||
                members[msg.sender].level == MemberLevel.VERIFIED, "NOT_A_MEMBER");
        require(domains[domainId].owner != address(0), "NO_SUCH_DOMAIN");
        require(domains[domainId].owner == msg.sender, "NOT_AUTHORIZED");
        require(domains[domainId].status == DomainStatus.ACTIVE, "DOMAIN_NOT_ACTIVE");

        // FIXME: check that the domain has no active objects associated anymore

        domains[domainId].status = DomainStatus.CLOSED;

        emit DomainClosed(domainId, DomainStatus.CLOSED);
    }

    /**
     * Returns domain status.
     *
     * @param domainId The ID of the domain to lookup status.
     * @return The current status of the domain.
     */
    function getDomainStatus(bytes16 domainId) public view returns (DomainStatus) {
        return domains[domainId].status;
    }

    /**
     * Returns domain owner.
     *
     * @param domainId The ID of the domain to lookup owner.
     * @return The address of the owner of the domain.
     */
    function getDomainOwner(bytes16 domainId) public view returns (address) {
        return domains[domainId].owner;
    }

    /**
     * Returns domain (signing) key.
     *
     * @param domainId The ID of the domain to lookup key.
     * @return The Ed25519 public signing key for the domain.
     */
    function getDomainKey(bytes16 domainId) public view returns (bytes32) {
        return domains[domainId].domainKey;
    }

    /**
     * Returns domain license.
     *
     * @param domainId The ID of the domain to lookup license.
     * @return IPFS Multihash pointer to domain license file on IPFS.
     */
    function getDomainLicense(bytes16 domainId) public view returns (string memory) {
        return domains[domainId].license;
    }

    /**
     * Returns domain terms.
     *
     * @param domainId The ID of the domain to lookup terms.
     * @return IPFS Multihash pointer to domain terms on IPFS.
     */
    function getDomainTerms(bytes16 domainId) public view returns (string memory) {
        return domains[domainId].terms;
    }

    /**
     * Returns domain meta data.
     *
     * @param domainId The ID of the domain to lookup meta data.
     * @return IPFS Multihash pointer to domain metadata file on IPFS.
     */
    function getDomainMeta(bytes16 domainId) public view returns (string memory) {
        return domains[domainId].meta;
    }

    /**
     * Pair a node with an existing XBR Domain. The sender must be owner of the domain.
     *
     * @param nodeId The ID of the node to pair. Must be globally unique (not yet existing).
     * @param domainId The ID of the domain to pair the node with.
     * @param nodeType The type of node to pair the node under.
     * @param nodeKey The Ed25519 public node key.
     * @param config Optional IPFS Multihash pointing to node configuration stored on IPFS
     */
    function pairNode (bytes16 nodeId, bytes16 domainId, NodeType nodeType, bytes32 nodeKey,
        string memory config) public {

        require(domains[domainId].owner != address(0), "NO_SUCH_DOMAIN");
        require(domains[domainId].owner == msg.sender, "NOT_AUTHORIZED");
        require(uint8(nodes[nodeId].nodeType) == 0, "NODE_ALREADY_PAIRED");
        require(nodesByKey[nodeKey] == bytes16(0), "DUPLICATE_NODE_KEY");
        require(uint8(nodeType) == uint8(NodeType.MASTER) ||
                uint8(nodeType) == uint8(NodeType.EDGE), "INVALID_NODE_TYPE");

        nodes[nodeId] = Node(domainId, nodeType, nodeKey, config);
        nodesByKey[nodeKey] = nodeId;
        domains[domainId].nodes.push(nodeId);

        emit NodePaired(domainId, nodeId, nodeKey, config);
    }

    /**
     * Release a node currently paired with an XBR domain. The sender must be owner of the domain.
     *
     * @param nodeId The ID of the node to release.
     */
    function releaseNode (bytes16 nodeId) public {
        require(uint8(nodes[nodeId].nodeType) != 0, "NO_SUCH_NODE");
        require(domains[nodes[nodeId].domain].owner == msg.sender, "NOT_AUTHORIZED");

        bytes16 domainId = nodes[nodeId].domain;
        bytes32 nodeKey = nodes[nodeId].key;

        nodes[nodeId].domain = bytes16(0);
        nodes[nodeId].nodeType = NodeType.NULL;
        nodes[nodeId].key = bytes32(0);
        nodes[nodeId].config = "";

        nodesByKey[nodeKey] = bytes16(0);

        emit NodeReleased(domainId, nodeId);
    }

    /**
     * Lookup node ID by node public key.
     *
     * @param nodeKey The node public key to lookup
     * @return The Ed25519 public key of the node.
     */
    function getNodeByKey(bytes32 nodeKey) public view returns (bytes16) {
        return nodesByKey[nodeKey];
    }

    /**
     * Returns domain for a node.
     *
     * @param nodeId The ID of the node to lookup the domain for.
     * @return The domain the node is currently paired with.
     */
    function getNodeDomain(bytes16 nodeId) public view returns (bytes16) {
        return nodes[nodeId].domain;
    }

    /**
     * Returns node type for a node.
     *
     * @param nodeId The ID of the node to lookup the node type for.
     * @return The node type.
     */
    function getNodeType(bytes16 nodeId) public view returns (NodeType) {
        return nodes[nodeId].nodeType;
    }

    /**
     * Returns node public key for a node.
     *
     * @param nodeId The ID of the node to lookup the node public key for.
     * @return The node public key.
     */
    function getNodeKey(bytes16 nodeId) public view returns (bytes32) {
        return nodes[nodeId].key;
    }

    /**
     * Returns config for a node.
     *
     * @param nodeId The ID of the node to lookup the config for.
     * @return IPFS Multihash pointer to node config.
     */
    function getNodeConfig(bytes16 nodeId) public view returns (string memory) {
        return nodes[nodeId].config;
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
    function createMarket (bytes16 marketId, string memory terms, string memory meta, address maker,
        uint256 providerSecurity, uint256 consumerSecurity, uint256 marketFee) public {

        require(markets[marketId].owner == address(0), "MARKET_ALREADY_EXISTS");
        require(maker != address(0), "INVALID_MAKER");
        require(marketsByMaker[maker] == bytes16(0), "MAKER_ALREADY_WORKING_FOR_OTHER_MARKET");
        require(providerSecurity >= 0 && providerSecurity <= token.totalSupply(), "INVALID_PROVIDER_SECURITY");
        require(consumerSecurity >= 0 && consumerSecurity <= token.totalSupply(), "INVALID_CONSUMER_SECURITY");
        require(marketFee >= 0 && marketFee < (token.totalSupply() - 10**7) * 10**18, "INVALID_MARKET_FEE");

        markets[marketId] = Market(marketSeq, msg.sender, terms, meta, maker, providerSecurity,
            consumerSecurity, marketFee, new address[](0), new address[](0));

        markets[marketId].actors[msg.sender] = Actor(ActorType.MARKET, 0, '', 0);
        markets[marketId].actorAddresses.push(maker);

        marketsByMaker[maker] = marketId;

        marketSeq = marketSeq + 1;

        emit MarketCreated(marketId, marketSeq, msg.sender, terms, meta, maker,
                                providerSecurity, consumerSecurity, marketFee);
    }

    /**
     * Lookup market ID by market maker address.
     *
     * @param maker The market maker address to lookup market for
     * @return ID of the market maker.
     */
    function getMarketByMaker (address maker) public view returns (bytes16) {
        return marketsByMaker[maker];
    }

    /**
     * Returns owner for a market.
     *
     * @param marketId The ID of the market to lookup owner for.
     * @return Address of the owner of the market.
     */
    function getMarketOwner (bytes16 marketId) public view returns (address) {
        return markets[marketId].owner;
    }

    /**
     * Returns terms for a market.
     *
     * @param marketId The ID of the market to lookup terms for.
     * @return IPFS Multihash pointer to market terms.
     */
    function getMarketTerms (bytes16 marketId) public view returns (string memory) {
        return markets[marketId].terms;
    }

    /**
     * Returns metadata for a market.
     *
     * @param marketId The ID of the market to lookup metadata for.
     * @return IPFS Multihash pointer to market metadata.
     */
    function getMarketMeta (bytes16 marketId) public view returns (string memory) {
        return markets[marketId].meta;
    }

    /**
     * Returns market maker for a market.
     *
     * @param marketId The ID of the market to lookup the market maker address for.
     * @return The address of the (offchain) market maker delegate responsible for this market.
     */
    function getMarketMaker (bytes16 marketId) public view returns (address) {
        return markets[marketId].maker;
    }

    /**
     * Returns provider security for a market.
     *
     * @param marketId The ID of the market to lookup provider security for.
     * @return The provider security defined in the market.
     */
    function getMarketProviderSecurity (bytes16 marketId) public view returns (uint256) {
        return markets[marketId].providerSecurity;
    }

    /**
     * Returns consumer security for a market.
     *
     * @param marketId The ID of the market to lookup consumer security for.
     * @return The consumer security defined in the market.
     */
    function getMarketConsumerSecurity (bytes16 marketId) public view returns (uint256) {
        return markets[marketId].consumerSecurity;
    }

    /**
     * Returns market fee for a market.
     *
     * @param marketId The ID of the market to lookup market fee for.
     * @return The fee defined in the market.
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
    function joinMarket (bytes16 marketId, ActorType actorType, string memory meta) public returns (uint256) {
        require(markets[marketId].owner != address(0), "NO_SUCH_MARKET");
        require(uint8(markets[marketId].actors[msg.sender].actorType) == 0, "ACTOR_ALREADY_JOINED");
        require(uint8(actorType) == uint8(ActorType.MARKET) ||
            uint8(actorType) == uint8(ActorType.PROVIDER) || uint8(actorType) == uint8(ActorType.CONSUMER));

        uint256 security;
        if (uint8(actorType) == uint8(ActorType.PROVIDER)) {
            security = markets[marketId].providerSecurity;
        } else if (uint8(actorType) == uint8(ActorType.CONSUMER)) {
            security = markets[marketId].consumerSecurity;
        } else {
            // ActorType.MARKET
            security = 0;
        }

        if (security > 0) {
            // ActorType.CONSUMER, ActorType.PROVIDER
            bool success = token.transferFrom(msg.sender, address(this), security);
            require(success, "JOIN_MARKET_TRANSFER_FROM_FAILED");
        }

        // remember actor (by address+type) within market
        markets[marketId].actors[msg.sender] = Actor(actorType, security, meta, 0);
        markets[marketId].actorAddresses.push(msg.sender);

        // emit event ActorJoined(bytes16 marketId, address actor, ActorType actorType, uint256 security, string meta)
        emit ActorJoined(marketId, msg.sender, actorType, security, meta);

        return security;
    }

    /**
     * Returns all actors in a given market.
     *
     * @param marketId The ID of the market to lookup actors.
     * @return  List of addresses of market actors in the market.
     */
    function getAllMarketActors (bytes16 marketId) public view returns (address[] memory) {
        return markets[marketId].actorAddresses;
    }

    /**
     * Returns the type of an actor within a market.
     *
     * @param marketId The ID of the market to lookup actor type.
     * @param actor The address of the actor to lookup.
     * @return The type under which the actor is joined in the market.
     */
    function getMarketActorType (bytes16 marketId, address actor) public view returns (ActorType) {
        return markets[marketId].actors[actor].actorType;
    }

    /**
     * Returns the current security deposit of an actor within a market.
     *
     * @param marketId The ID of the market to lookup actor type.
     * @param actor The address of the actor to lookup.
     * @return The security deposit of the actor in the given market.
     */
    function getMarketActorSecurity (bytes16 marketId, address actor) public view returns (uint256) {
        return markets[marketId].actors[actor].security;
    }

    /**
     * Returns any meta associated with the actor in the market.
     *
     * @param marketId The ID of the market to lookup actor meta within.
     * @param actor The address of the actor to lookup in the market.
     * @return IPFS Multihash pointing to actor meta file on IPFS.
     */
    function getMarketActorMeta (bytes16 marketId, address actor) public view returns (string memory) {
        return markets[marketId].actors[actor].meta;
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
        require(uint8(markets[marketId].actors[msg.sender].actorType) == uint8(ActorType.CONSUMER), "NO_CONSUMER_ROLE");

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
        require(uint8(markets[marketId].actors[msg.sender].actorType) == uint8(ActorType.PROVIDER),
            "NO_PROVIDER_ROLE");

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
        require(uint8(markets[marketId].actors[recipient].actorType) == uint8(ActorType.PROVIDER),
            "RECIPIENT_NOT_PROVIDER");

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

    /**
     * Lookup all payment and paying channels for a XBR Market.
     *
     * @param marketId The XBR Market to get channels for.
     * @return List of contract addresses of channels in the market.
     */
    function getAllMarketChannels(bytes16 marketId) public view returns (address[] memory) {
        return markets[marketId].channels;
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
