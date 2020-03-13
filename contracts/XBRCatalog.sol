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
contract XBRCatalog is XBRMaintained {

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
}
