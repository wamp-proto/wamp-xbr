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
import "./XBRNetwork.sol";
import "./XBRChannel.sol";


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

    /// Event emitted when a new payment channel was created in a market.
    event ChannelCreated (bytes16 indexed marketId, address sender, address delegate,
        address recipient, address channel, XBRChannel.ChannelType channelType);

    /// Event emitted when a new request for a paying channel was created in a market.
    event PayingChannelRequestCreated (bytes16 indexed marketId, address sender, address recipient, address delegate,
        uint256 amount, uint32 timeout);

    // Note: closing event of payment channels are emitted from XBRChannel (not from here)

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
     * Constructor.
     *
     * @param network_ The network this market is part of.
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

        XBRTypes.Member memory member = network.members(msg.sender);

        // the market operator (owner) must be a registered member
        require(member.level == XBRTypes.MemberLevel.ACTIVE ||
                member.level == XBRTypes.MemberLevel.VERIFIED, "SENDER_NOT_A_MEMBER");

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
        markets[marketId] = XBRTypes.Market(created, marketSeq, msg.sender, terms, meta, maker,
            providerSecurity, consumerSecurity, marketFee, new address[](0), new address[](0));

        // .. and the market-maker-to-market mapping
        marketsByMaker[maker] = marketId;

        // .. and the market-owner-to-market mapping
        marketsByOwner[msg.sender].push(marketId);

        // .. and list of markst IDs
        marketIds.push(marketId);

        // increment market sequence for next market
        marketSeq = marketSeq + 1;

        // notify observers (eg a dormant market maker waiting to be associated)
        emit MarketCreated(marketId, created, marketSeq, msg.sender, terms, meta, maker,
            providerSecurity, consumerSecurity, marketFee);
    }

    function countMarkets() public view returns (uint) {
        return marketIds.length;
    }

    function getMarketsByOwner(address owner, uint index) public view returns (bytes16) {
        return marketsByOwner[owner][index];
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
    function joinMarket (bytes16 marketId, uint8 actorType, string memory meta) public returns (uint256) {

        XBRTypes.Member memory member = network.members(msg.sender);

        // the joining sender must be a registered member
        require(member.level == XBRTypes.MemberLevel.ACTIVE, "SENDER_NOT_A_MEMBER");

        // the market to join must exist
        require(markets[marketId].owner != address(0), "NO_SUCH_MARKET");

        // the market owner cannot join as an actor (provider/consumer) in the market
        require(markets[marketId].owner != msg.sender, "SENDER_IS_OWNER");

        // the joining member must join as a data provider (seller) or data consumer (buyer)
        require(actorType == uint8(XBRTypes.ActorType.PROVIDER) ||
                actorType == uint8(XBRTypes.ActorType.CONSUMER), "INVALID_ACTOR_TYPE");

        // get the security amount required for joining the market (if any)
        uint256 security;
        // if (uint8(actorType) == uint8(ActorType.PROVIDER)) {
        if (actorType == uint8(XBRTypes.ActorType.PROVIDER)) {
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
            bool success = network.token().transferFrom(msg.sender, markets[marketId].owner, security);
            require(success, "JOIN_MARKET_TRANSFER_FROM_FAILED");
        }

        // remember actor (by actor address) within market
        uint joined = block.timestamp;
        if (actorType == uint8(XBRTypes.ActorType.PROVIDER)) {
            markets[marketId].providerActors[msg.sender] = XBRTypes.Actor(joined, security, meta, new address[](0));
            markets[marketId].providerActorAdrs.push(msg.sender);
        } else {
            markets[marketId].consumerActors[msg.sender] = XBRTypes.Actor(joined, security, meta, new address[](0));
            markets[marketId].consumerActorAdrs.push(msg.sender);
        }

        // emit event ActorJoined(bytes16 marketId, address actor, ActorType actorType, uint joined,
        //                        uint256 security, string meta)
        emit ActorJoined(marketId, msg.sender, actorType, joined, security, meta);

        // return effective security transferred
        return security;
    }

    function joinMarketFor (address member, uint256 joined, bytes16 marketId, uint8 actorType,
        string memory meta, bytes memory signature) public returns (uint256) {

        XBRTypes.Member memory member_ = network.members(member);

        // the joining member must be a registered member
        require(member_.level == XBRTypes.MemberLevel.ACTIVE, "SENDER_NOT_A_MEMBER");

        // the market to join must exist
        require(markets[marketId].owner != address(0), "NO_SUCH_MARKET");

        // the market owner cannot join as an actor (provider/consumer) in the market
        require(markets[marketId].owner != member, "SENDER_IS_OWNER");

        // the joining member must join as a data provider (seller) or data consumer (buyer)
        require(actorType == uint8(XBRTypes.ActorType.PROVIDER) ||
                actorType == uint8(XBRTypes.ActorType.CONSUMER), "INVALID_ACTOR_TYPE");

        // FIXME: check "joined"

        // get the security amount required for joining the market (if any)
        uint256 security = 0;

        if (actorType == uint8(XBRTypes.ActorType.PROVIDER)) {
            // the joining member must not be joined as a provider already
            require(uint8(markets[marketId].providerActors[member].joined) == 0, "ALREADY_JOINED_AS_PROVIDER");
            security = markets[marketId].providerSecurity;
        } else  {
            // the joining member must not be joined as a consumer already
            require(uint8(markets[marketId].consumerActors[member].joined) == 0, "ALREADY_JOINED_AS_CONSUMER");
            security = markets[marketId].consumerSecurity;
        }

        // FIXME:
        require(XBRTypes.verify(member, XBRTypes.EIP712MarketJoin(network.verifyingChain(), network.verifyingContract(),
            member, joined, marketId, actorType, meta), signature), "INVALID_MARKET_JOIN_SIGNATURE");

        if (security > 0) {
            // Transfer (if any) security to the market owner (for ActorType.CONSUMER or ActorType.PROVIDER)
            bool success = network.token().transferFrom(member, markets[marketId].owner, security);
            require(success, "JOIN_MARKET_TRANSFER_FROM_FAILED");
        }

        // remember actor (by actor address) within market
        if (actorType == uint8(XBRTypes.ActorType.PROVIDER)) {
            markets[marketId].providerActors[member] = XBRTypes.Actor(joined, security, meta, new address[](0));
            markets[marketId].providerActorAdrs.push(member);
        } else {
            markets[marketId].consumerActors[member] = XBRTypes.Actor(joined, security, meta, new address[](0));
            markets[marketId].consumerActorAdrs.push(member);
        }

        emit ActorJoined(marketId, member, actorType, joined, security, meta);

        // return effective security transferred
        return security;
    }

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
        require(amount > 0 && amount <= network.token().totalSupply(), "INVALID_CHANNEL_AMOUNT");

        // payment channel timeout can be [0 seconds - 10 days[
        require(timeout >= 0 && timeout < 864000, "INVALID_CHANNEL_TIMEOUT");

        // create new payment channel contract
        XBRChannel channel = new XBRChannel(network.organization(), address(network.token()), address(this), marketId,
            markets[marketId].maker, msg.sender, delegate, recipient, amount, timeout,
            XBRChannel.ChannelType.PAYMENT);

        // transfer tokens (initial balance) into payment channel contract
        bool success = network.token.transferFrom(msg.sender, address(channel), amount);
        require(success, "OPEN_CHANNEL_TRANSFER_FROM_FAILED");

        // remember the new payment channel associated with the market
        //markets[marketId].channels.push(address(channel));
        markets[marketId].consumerActors[msg.sender].channels.push(address(channel));

        // emit event ChannelCreated(bytes16 marketId, address sender, address delegate,
        //      address recipient, address channel)
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

        // sender must be market maker for market
        require(msg.sender == recipient, "SENDER_NOT_RECIPIENT");

        // recipient must be provider in the market
        require(uint8(markets[marketId].providerActors[recipient].joined) != 0, "RECIPIENT_NOT_PROVIDER");

        // must provide a valid off-chain channel delegate address
        require(delegate != address(0), "INVALID_CHANNEL_DELEGATE");

        // paying channel amount must be positive
        require(amount > 0 && amount <= network.token.totalSupply(), "INVALID_CHANNEL_AMOUNT");

        // paying channel timeout can be [0 seconds - 10 days[
        require(timeout >= 0 && timeout < 864000, "INVALID_CHANNEL_TIMEOUT");

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

        // must provide a valid off-chain channel delegate address
        require(delegate != address(0), "INVALID_CHANNEL_DELEGATE");

        // payment channel amount must be positive
        require(amount > 0 && amount <= network.token.totalSupply(), "INVALID_CHANNEL_AMOUNT");

        // payment channel timeout can be [0 seconds - 10 days[
        require(timeout >= 0 && timeout < 864000, "INVALID_CHANNEL_TIMEOUT");

        // create new paying channel contract
        XBRChannel channel = new XBRChannel(network.organization, address(network.token), address(this),
            marketId, markets[marketId].maker, msg.sender, delegate, recipient, amount, timeout,
            XBRChannel.ChannelType.PAYING);

        // transfer tokens (initial balance) into payment channel contract
        bool success = network.token.transferFrom(msg.sender, address(channel), amount);
        require(success, "OPEN_CHANNEL_TRANSFER_FROM_FAILED");

        // remember the new payment channel associated with the market
        //markets[marketId].channels.push(address(channel));
        markets[marketId].providerActors[recipient].channels.push(address(channel));

        // emit event ChannelCreated(bytes16 marketId, address sender, address delegate,
        //  address recipient, address channel)
        emit ChannelCreated(marketId, channel.sender(), channel.delegate(), channel.recipient(),
            address(channel), XBRChannel.ChannelType.PAYING);

        return address(channel);
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
