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

pragma solidity 0.4.24;

import "./XBRMaintained.sol";
import "./XBRPaymentChannel.sol";


/**
 * @title XBR Network root SC
 * @author The XBR Project
 */
contract XBRNetwork is XBRMaintained {

    /// XBR Network membership levels
    enum MemberLevel { NULL, ACTIVE, VERIFIED, RETIRED, PENALTY, BLOCKED }

    /// XBR Market Actor types
    enum ActorType { NULL, MAKER, PROVIDER, CONSUMER }

    /// Value type for holding XBR Network membership information.
    struct Member {
        bytes32 eula;
        bytes32 profile;
        MemberLevel level;
    }

    /// Value type for holding XBR Market information.
    struct Market {
        address owner;
        address maker;
        bytes32 terms;
        address[] channels;
    }

    /// Address of the XBR Network ERC20 token (XBR for the CrossbarFX technology stack)
    address public network_token;

    /// Address of the `XBR Network Organization <https://xbr.network/>`_
    address public network_organization;

    /// Current XBR Network members.
    mapping(address => Member) public members;

    /// Current XBR Markets ("market repository")
    mapping(bytes32 => Market) public markets;

    /**
     * Create a new network.
     *
     * @param _network_token The token to run this network on.
     * @param _network_organization The network technology provider and ecoystem sponsor.
     */
    constructor (address _network_token, address _network_organization) public {
        network_token = _network_token;
        network_organization = _network_organization;
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
    }

    /**
     * Leave the XBR Network.
     */
    function unregister () public {
        require(uint(members[msg.sender].level) != 0, "NO_SUCH_MEMBER");

        members[msg.sender].level = MemberLevel.RETIRED;
    }

    /**
     * Manually override the member level of a XBR Network member. Being able to do so
     * currently serves two purposes:
     *
     * - having a last resort to handle situation where members violated the EULA
     * - being able to manually patch things in error/bug cases
     */
    function set_member_level (address member, MemberLevel level) public onlyMaintainer {
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
     * @param provider_security The amount of XBR tokens a XBR provider joining the market must deposit.
     * @param consumer_security The amount of XBR tokens a XBR consumer joining the market must deposit.
     */
    function open_market (address maker, bytes32 terms, uint64 provider_security, uint64 consumer_security) public {

        // generate new market_id
        bytes32 market_id = keccak256(abi.encodePacked(msg.sender, blockhash(block.number - 1)));

        // FIXME: gracefully handle multiple market registrations from one user within one block!
        require(markets[market_id].owner != address(0), "MARKET_ALREADY_EXISTS");

        markets[market_id] = Market(msg.sender, maker, terms, new address[](1));
    }

    /**
     * Join the given XBR market as the specified type of actor, which must be PROVIDER or CONSUMER.
     *
     * @param market_id The ID of the XBR data market to join.
     * @param actor_type The type of actor under which to join: PROVIDER or CONSUMER.
     */
    function join_market (bytes32 market_id, ActorType actor_type) public payable {
    }

    /**
     * Open a new payment channel and deposit an amount of XBR token into a market.
     * The procedure returns
     */
    function open_payment_channel (bytes32 market_id) public payable returns (address payment_channel) {
        XBRPaymentChannel channel = new XBRPaymentChannel(market_id, address(0), 60);
        markets[market_id].channels.push(channel);
        return channel;
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
    function request_paying_channel (bytes32 market_id, uint256 amount) public returns (bytes32 channel_request_id) {
    }

    /**
     * As a market actor (participant) currently member of a market, leave that market.
     * A market can only be left when all payment channels of the sender are closed (or expired).
     *
     * @param market_id The ID of the market to leave.
     */
    function leave_market (bytes32 market_id) public {
    }

    /**
     * Close a market. A closed market will not accept new memberships.
     *
     * @param market_id The ID of the market to close.
     */
    function close_market (bytes32 market_id) public {
    }
}
