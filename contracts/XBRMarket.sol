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

pragma solidity ^0.5.2;
//pragma experimental ABIEncoderV2;

// https://openzeppelin.org/api/docs/math_SafeMath.html
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./Ownable.sol";
// import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./OwnedUpgradeabilityProxy.sol";

import "./XBRToken.sol";
import "./XBRMaintained.sol";
import "./XBRChannel.sol";


/**
 * @title XBR Network main smart contract.
 * @author The XBR Project
 XBRMaintained
 */
contract XBRMarket is Ownable {

    bool internal _initialized;

    // Add safe math functions to uint256 using SafeMath lib from OpenZeppelin
    using SafeMath for uint256;

    /// XBR Network ERC20 token (XBR for the CrossbarFX technology stack)
    XBRToken public token;

    /// Address of the `XBR Network Organization <https://xbr.network/>`_
    address private organization;

    //uint8 public MEMBER_ALREADY_REGISTERED = 1;

    // //////// enums

    /// XBR Market Actor types
    enum ActorType { NULL, PROVIDER, CONSUMER }

    // //////// container types

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

    address marketOwner;

    /// Time (block.timestamp) when the market was created.
    uint created;

    /// Market sequence number.
    uint32 marketSeq;

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

    /// Container type for holding paying channel request information.
    struct PayingChannelRequest {
        address marketId;
        address sender;
        address delegate;
        address recipient;
        uint256 amount;
        uint32 timeout;
    }

    // //////// events for MARKETS

    /// Event emitted when a new actor joined a market.
    event ActorJoined (address indexed marketId, address actor, uint8 actorType, uint joined,
        uint256 security, string meta);

    /// Event emitted when an actor has left a market.
    event ActorLeft (address indexed marketId, address actor, uint8 actorType);

    /// Event emitted when a new payment channel was created in a market.
    event ChannelCreated (address indexed marketId, address sender, address delegate,
        address recipient, address channel, XBRChannel.ChannelType channelType);

    /// Event emitted when a new request for a paying channel was created in a market.
    event PayingChannelRequestCreated (address indexed marketId, address sender, address recipient, address delegate,
        uint256 amount, uint32 timeout);

    // Note: closing event of payment channels are emitted from XBRChannel (not from here)

    function initialize (address owner_, address proxy_) public {
        require(!_initialized);
        setOwner(owner_);
        _initialized = true;
    }

    function getMarketActor (address actor, uint8 actorType) public view
        returns (uint, uint256, string memory)
    {
        // must ask for a data provider (seller) or data consumer (buyer): INVALID_ACTOR_TYPE
        require(actorType == uint8(ActorType.PROVIDER) ||
                actorType == uint8(ActorType.CONSUMER), "1");

        if (actorType == uint8(ActorType.CONSUMER)) {
            Actor storage _actor = consumerActors[actor];
            return (_actor.joined, _actor.security, _actor.meta);
        } else {
            Actor storage _actor = providerActors[actor];
            return (_actor.joined, _actor.security, _actor.meta);
        }
    }

    /**
     * Join the given XBR market as the specified type of actor, which must be PROVIDER or CONSUMER.
     *
     * @param actorType_ The type of actor under which to join: PROVIDER or CONSUMER.
     * @param meta_ The XBR market provider/consumer metadata. IPFS Multihash pointing to a JSON file with metadata.
     */
    function joinMarket (uint8 actorType_, string memory meta_) public returns (uint256) {

        // the joining sender must be a registered member: SENDER_NOT_A_MEMBER
        // require(members[msg.sender].level == MemberLevel.ACTIVE, "1");

        // the joining member must join as a data provider (seller) or data consumer (buyer): INVALID_ACTOR_TYPE
        require(actorType_ == uint8(ActorType.PROVIDER) ||
                actorType_ == uint8(ActorType.CONSUMER), "1");

        // get the security amount required for joining the market (if any)
        uint256 security;
        // if (uint8(actorType_) == uint8(ActorType.PROVIDER)) {
        if (actorType_ == uint8(ActorType.PROVIDER)) {
            // the joining member must not be joined as a provider already: ALREADY_JOINED_AS_PROVIDER
            require(uint8(providerActors[msg.sender].joined) == 0, "2");
            security = providerSecurity;
        } else  {
            // the joining member must not be joined as a consumer already: ALREADY_JOINED_AS_CONSUMER
            require(uint8(consumerActors[msg.sender].joined) == 0, "3");
            security = consumerSecurity;
        }

        if (security > 0) {
            // Transfer (if any) security to the market owner (for ActorType.CONSUMER or ActorType.PROVIDER): JOIN_MARKET_TRANSFER_FROM_FAILED
            bool success = token.transferFrom(msg.sender, marketOwner, security);
            require(success, "4");
        }

        // remember actor (by actor address) within market
        uint joined = block.timestamp;
        if (actorType_ == uint8(ActorType.PROVIDER)) {
            providerActors[msg.sender] = Actor(joined, security, meta_, new address[](0));
            providerActorAdrs.push(msg.sender);
        } else {
            consumerActors[msg.sender] = Actor(joined, security, meta_, new address[](0));
            consumerActorAdrs.push(msg.sender);
        }

        // emit event ActorJoined(address actor, ActorType actorType, uint joined,
        //                        uint256 security, string meta)
        emit ActorJoined(address(this), msg.sender, actorType_, joined, security, meta_);

        // return effective security transferred
        return security;
    }

    // /**
    //  * As a market actor (participant) currently member of a market, leave that market.
    //  * A market can only be left when all payment channels of the sender are closed (or expired).
    //  *
    //  * @param marketId The ID of the market to leave.
    //  */
    // function leaveMarket () public view {
    //     require(marketOwner != address(0), "NO_SUCH_MARKET");
    //     // FIXME
    //     // - remove sender actor from providerActorAdrs|consumerActorAdrs
    //     require(false, "NOT_IMPLEMENTED");
    // }

    /**
     * Open a new payment channel and deposit an amount of XBR token for off-chain consumption.
     * Must be called by the data consumer (XBR buyer) and an off-chain buyer delegate address must be given.
     *
     * @param recipient Recipient of the earned off-chain transaction amounts of this single channel,
     *                  commonly the market operator.
     * @param delegate The address of the (offchain) consumer delegate allowed to consume the channel.
     * @param amount Amount of XBR Token to deposit into the payment channel (the initial off-chain balance).
     * @param timeout Channel timeout which will apply.
     */
    function openPaymentChannel (address recipient, address delegate,
        uint256 amount, uint32 timeout) public returns (address paymentChannel) {

        // market must exist: NO_SUCH_MARKET
        require(marketOwner != address(0), "1");

        // sender must be consumer in the market: NO_CONSUMER_ROLE
        require(uint8(consumerActors[msg.sender].joined) != 0, "2");

        // technical recipient of the unidirectional, half-legged channel must be the
        // owner (operator) of the market: INVALID_CHANNEL_RECIPIENT
        require(recipient == marketOwner, "3");

        // must provide a valid off-chain channel delegate address: INVALID_CHANNEL_DELEGATE
        require(delegate != address(0), "4");

        // payment channel amount must be positive: INVALID_CHANNEL_AMOUNT
        require(amount > 0 && amount <= token.totalSupply(), "5");

        // payment channel timeout can be [0 seconds - 10 days[: INVALID_CHANNEL_TIMEOUT
        require(timeout >= 0 && timeout < 864000, "6");
        // create new payment channel contract
        XBRChannel channel = new XBRChannel(organization, address(token), address(this), address(this),
            maker, msg.sender, delegate, recipient, amount, timeout,
            XBRChannel.ChannelType.PAYMENT);

        // transfer tokens (initial balance) into payment channel contract
        bool success = token.transferFrom(msg.sender, address(channel), amount);
        // OPEN_CHANNEL_TRANSFER_FROM_FAILED
        require(success, "7");

        // remember the new payment channel associated with the market
        //channels.push(address(channel));
        consumerActors[msg.sender].channels.push(address(channel));

        // emit event ChannelCreated(address sender, address delegate,
        //      address recipient, address channel)
        emit ChannelCreated(address(this), channel.sender(), channel.delegate(), channel.recipient(),
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
     * @param delegate The address of the (offchain) provider delegate allowed to sell into the channel.
     * @param amount Amount of XBR Token to deposit into the paying channel (the initial off-chain balance).
     * @param timeout Channel timeout which will apply.
     */
    function requestPayingChannel (address recipient, address delegate,
        uint256 amount, uint32 timeout) public {

        // market must exist: NO_SUCH_MARKET
        require(marketOwner != address(0), "1");

        // market must have a market maker associated: NO_ACTIVE_MARKET_MAKER
        require(maker != address(0), "2");

        // sender must be market maker for market: SENDER_NOT_RECIPIENT
        require(msg.sender == recipient, "3");

        // recipient must be provider in the market: RECIPIENT_NOT_PROVIDER
        require(uint8(providerActors[recipient].joined) != 0, "4");

        // must provide a valid off-chain channel delegate address: INVALID_CHANNEL_DELEGATE
        require(delegate != address(0), "5");

        // paying channel amount must be positive: INVALID_CHANNEL_AMOUNT
        require(amount > 0 && amount <= token.totalSupply(), "6");

        // paying channel timeout can be [0 seconds - 10 days[: INVALID_CHANNEL_TIMEOUT
        require(timeout >= 0 && timeout < 864000, "7");

        // emit event PayingChannelRequestCreated(address sender, address recipient,
        //      address delegate, uint256 amount, uint32 timeout)
        emit PayingChannelRequestCreated(address(this), msg.sender, recipient, delegate, amount, timeout);
    }

    /**
     * Open a new paying channel and deposit an amount of XBR token for off-chain consumption.
     * Must be called by the market maker in response to a successful request for a paying channel.
     *
     * @param recipient Ultimate recipient of tokens earned, recipient must be provider in the market.
     * @param delegate The address of the (offchain) provider delegate allowed to earn on the channel.
     * @param amount Amount of XBR Token to deposit into the paying channel (the initial off-chain balance).
     * @param timeout Channel timeout which will apply.
     */
    function openPayingChannel (address recipient, address delegate,
        uint256 amount, uint32 timeout) public returns (address paymentChannel) {

        // market must exist: NO_SUCH_MARKET
        require(marketOwner != address(0), "1");

        // sender must be market maker for market: SENDER_NOT_MAKER
        require(maker == msg.sender, "2");

        // recipient must be provider in the market: RECIPIENT_NOT_PROVIDER
        require(uint8(providerActors[recipient].joined) != 0, "3");

        // must provide a valid off-chain channel delegate address: INVALID_CHANNEL_DELEGATE
        require(delegate != address(0), "4");

        // payment channel amount must be positive: INVALID_CHANNEL_AMOUNT
        require(amount > 0 && amount <= token.totalSupply(), "5");

        // payment channel timeout can be [0 seconds - 10 days[: INVALID_CHANNEL_TIMEOUT
        require(timeout >= 0 && timeout < 864000, "6");

        // create new paying channel contract
        XBRChannel channel = new XBRChannel(organization, address(token), address(this),
            address(this), maker, msg.sender, delegate, recipient, amount, timeout,
            XBRChannel.ChannelType.PAYING);

        // transfer tokens (initial balance) into payment channel contract
        XBRToken _token = XBRToken(token);
        bool success = _token.transferFrom(msg.sender, address(channel), amount);
        // OPEN_CHANNEL_TRANSFER_FROM_FAILED
        require(success, "7");

        // remember the new payment channel associated with the market
        //channels.push(address(channel));
        providerActors[recipient].channels.push(address(channel));

        // emit event ChannelCreated(address sender, address delegate,
        //  address recipient, address channel)
        emit ChannelCreated(address(this), channel.sender(), channel.delegate(), channel.recipient(),
            address(channel), XBRChannel.ChannelType.PAYING);

        return address(channel);
    }

    /**
     * Lookup all provider actors in a XBR Market.
     *
     * @return List of provider actor addresses in the market.
     */
    function getAllMarketProviders() public view returns (address[] memory) {
        return providerActorAdrs;
    }

    /**
     * Lookup all consumer actors in a XBR Market.
     *
     * @return List of consumer actor addresses in the market.
     */
    function getAllMarketConsumers() public view returns (address[] memory) {
        return consumerActorAdrs;
    }

    /**
     * Lookup all payment channels for an consumer actor in a XBR Market.
     *
     * @param actor The XBR actor to get payment channels for.
     * @return List of contract addresses of payment channels in the market.
     */
    function getAllPaymentChannels(address actor) public view returns (address[] memory) {
        return consumerActors[actor].channels;
    }

    /**
     * Lookup all paying channels for an provider actor in a XBR Market.
     *
     * @param actor The XBR actor to get paying channels for.
     * @return List of contract addresses of paying channels in the market.
     */
    function getAllPayingChannels(address actor) public view returns (address[] memory) {
        return providerActors[actor].channels;
    }
}
