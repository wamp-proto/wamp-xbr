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
import "./OwnedUpgradeabilityProxy.sol";

import "./XBRToken.sol";
import "./XBRMaintained.sol";
import "./XBRChannel.sol";
import "./XBRCatalog.sol";
import "./XBRMarket.sol";


/**
 * @title XBR Network main smart contract.
 * @author The XBR Project
 */
contract XBRNetwork is XBRMaintained {

    // Add safe math functions to uint256 using SafeMath lib from OpenZeppelin
    using SafeMath for uint256;

    //uint8 public MEMBER_ALREADY_REGISTERED = 1;

    // //////// enums

    /// XBR Network membership levels
    enum MemberLevel { NULL, ACTIVE, VERIFIED, RETIRED, PENALTY, BLOCKED }

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

    // //////// events for MEMBERS

    /// Event emitted when a new member joined the XBR Network.
    event MemberCreated (address indexed member, uint registered, string eula, string profile, MemberLevel level);

    /// Event emitted when a member leaves the XBR Network.
    event MemberRetired (address member);

    // //////// events for MARKETS

    /// Event emitted when a new market was created.
    event MarketCreated (address indexed market, uint created, address owner, string terms,
        string meta, address maker, uint256 providerSecurity, uint256 consumerSecurity, uint256 marketFee);

    /// Event emitted when a market was updated.
    event MarketUpdated (address indexed market, uint updated, address owner, string terms, string meta,
        address maker, uint256 providerSecurity, uint256 consumerSecurity, uint256 marketFee);

    /// Event emitted when a market was closed.
    event MarketClosed (address indexed market);

    // Note: closing event of payment channels are emitted from XBRChannel (not from here)

    /// XBR network EULA (IPFS Multihash). Source: https://github.com/crossbario/xbr-protocol/tree/master/ipfs/xbr-eula
    //string public constant eula = "QmV1eeDextSdUrRUQp9tUXF8SdvVeykaiwYLgrXHHVyULY";

    /// XBR Network ERC20 token (XBR for the CrossbarFX technology stack)
    XBRToken public token;

    XBRCatalog public catalog;

    XBRMarket public market;

    /// Address of the `XBR Network Organization <https://xbr.network/>`_
    address private organization;

    /// Current XBR Network members ("member directory").
    mapping(address => Member) public members;

    address[] public markets;

    /// Index: market address =>Current XBR Markets ("market directory")
    mapping(address => address) public ownerByMarket;

    /// Index: market maker address => market contract address
    mapping(address => address) public marketByMaker;

    /// Index: catalog address => owner ("catalog directory")
    mapping(address => address) public ownerByCatalog;

    /// Index: market owner address => [market ID]
    mapping(address => address[]) public marketsByOwner;

    /// Index: catalog owner address => [catalog address]
    mapping(address => address[]) public catalogsByOwner;

    /**
     * Create a new network.
     *
     * @param token_ The token to run this network on.
     * @param organization_ The network technology provider and ecosystem sponsor.
     */
    constructor (address token_, address catalog_, address market_, address organization_) public {

        token = XBRToken(token_);
        catalog = XBRCatalog(catalog_);
        market = XBRMarket(market_);
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

        // check that sender is not already a member: MEMBER_ALREADY_REGISTERED
        require(uint8(members[msg.sender].level) == 0, "1");

        // check that the EULA the member accepted is the one we expect: INVALID_EULA
        require(keccak256(abi.encode(eula_)) ==
                keccak256(abi.encode("QmV1eeDextSdUrRUQp9tUXF8SdvVeykaiwYLgrXHHVyULY")), "2");

        // remember the member
        uint registered = block.timestamp;
        members[msg.sender] = Member(registered, eula_, profile_, MemberLevel.ACTIVE);

        // notify observers of new member
        emit MemberCreated(msg.sender, registered, eula_, profile_, MemberLevel.ACTIVE);
    }

    // /**
    //  * Leave the XBR Network.
    //  */
    // function unregister () public {
    //     require(uint8(members[msg.sender].level) != 0, "NO_SUCH_MEMBER");
    //     require((uint8(members[msg.sender].level) == uint8(MemberLevel.ACTIVE)) ||
    //             (uint8(members[msg.sender].level) == uint8(MemberLevel.VERIFIED)), "MEMBER_NOT_ACTIVE");

    //     // FIXME: check that the member has no active objects associated anymore
    //     require(false, "NOT_IMPLEMENTED");

    //     members[msg.sender].level = MemberLevel.RETIRED;

    //     emit MemberRetired(msg.sender);
    // }

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
/*
        require(uint(members[msg.sender].level) != 0, "NO_SUCH_MEMBER");
*/
        members[member].level = level;
    }

    /**
     * Create a new XBR market. The sender of the transaction must be XBR network member
     * and automatically becomes owner of the new market.
     *
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
    function createMarket (string memory terms, string memory meta, address maker,
        uint256 providerSecurity, uint256 consumerSecurity, uint256 marketFee) public {

        // the market operator (owner) must be a registered member: SENDER_NOT_A_MEMBER
        require(members[msg.sender].level == MemberLevel.ACTIVE ||
                members[msg.sender].level == MemberLevel.VERIFIED, "1");

        // must provide a valid market maker address already when creating a market: INVALID_MAKER
        require(maker != address(0), "3");

        // the market maker can only work for one market: MAKER_ALREADY_WORKING_FOR_OTHER_MARKET
        require(marketByMaker[maker] == address(0), "4");

        // provider security must be non-negative (and obviously smaller than the total token supply): INVALID_PROVIDER_SECURITY
        require(providerSecurity >= 0 && providerSecurity <= token.totalSupply(), "5");

        // consumer security must be non-negative (and obviously smaller than the total token supply): INVALID_CONSUMER_SECURITY
        require(consumerSecurity >= 0 && consumerSecurity <= token.totalSupply(), "6");

        // FIXME: treat market fee: INVALID_MARKET_FEE
        require(marketFee >= 0 && marketFee < (token.totalSupply() - 10**7) * 10**18, "7");

        // now remember out new market ..
        uint created = block.timestamp;

        // create new market contract proxy instance
        OwnedUpgradeabilityProxy market_proxy = new OwnedUpgradeabilityProxy();

        // FIXME: upgradeAndCall
        // markets[marketId] = Market(created, marketSeq, msg.sender, terms, meta, maker,
        //    providerSecurity, consumerSecurity, marketFee, new address[](0), new address[](0));

        // set current implementation of market
        market_proxy.upgradeTo(address(market));
        XBRMarket mymarket = XBRMarket(address(market_proxy));
        mymarket.initialize(msg.sender, address(market_proxy));
        // FIXME:
        // market_proxy.upgradeToAndCall(address(market), encodeCall('initialize', ['address', 'address'], [msg.sender, address(market_proxy)]));

        // set sender as owner
        market_proxy.transferProxyOwnership(msg.sender);

        // update indexes
        markets.push(address(market_proxy));
        ownerByMarket[address(market_proxy)] = msg.sender;
        marketByMaker[maker] = address(market_proxy);
        marketsByOwner[msg.sender].push(address(market_proxy));

        // notify observers (eg a dormant market maker waiting to be associated)
        emit MarketCreated(address(market_proxy), created, msg.sender, terms, meta, maker,
                                providerSecurity, consumerSecurity, marketFee);
    }

    function countMarkets() public view returns (uint) {
        return markets.length;
    }

    function getMarketsByOwner(address owner, uint index) public view returns (address) {
        return marketsByOwner[owner][index];
    }

    function countMarketsByOwner(address owner) public view returns (uint) {
        return marketsByOwner[owner].length;
    }

    /**
     * Update market information, like market terms, metadata or maker address.
     *
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
    function updateMarket(string memory terms, string memory meta, address maker,
        uint256 providerSecurity, uint256 consumerSecurity, uint256 marketFee) public returns (bool) {
/*
        Market storage market = markets[marketId];

        // NO_SUCH_MARKET
        require(market.owner != address(0), "1");

        // NOT_AUTHORIZED
        require(market.owner == msg.sender, "2");

        // INVALID_MARKET_FEE
        require(marketFee >= 0 && marketFee < (10**9 - 10**7) * 10**18, "3");

        // MAKER_ALREADY_WORKING_FOR_OTHER_MARKET
        // require(marketByMaker[maker] == address(0), "4");

        bool wasChanged = false;

        // for these knobs, only update when non-zero values provided
        if (maker != address(0) && maker != market.maker) {
            markets[marketId].maker = maker;
            wasChanged = true;
        }

        // FIXME: find out why including the following code leas to "out of gas" issues when deploying contracts

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
*/
    }

    function createCatalog (string memory terms, string memory meta) public returns (address) {

        // catalog owner must be a registered member
        require(members[msg.sender].level == MemberLevel.ACTIVE || members[msg.sender].level == MemberLevel.VERIFIED);

        // create new catalog contract proxy instance
        OwnedUpgradeabilityProxy catalog_proxy = new OwnedUpgradeabilityProxy();

        // set current implementation of catalog
        catalog_proxy.upgradeTo(address(catalog));

        // set sender as owner
        catalog_proxy.transferProxyOwnership(msg.sender);

        // update indexes
        catalogsByOwner[msg.sender].push(address(catalog_proxy));
        ownerByCatalog[address(catalog_proxy)] = msg.sender;

        // return address of new catalog contract
        return address(catalog_proxy);
    }
}
