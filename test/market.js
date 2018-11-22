///////////////////////////////////////////////////////////////////////////////
//
//  XBR Open Data Markets - https://xbr.network
//
//  JavaScript client library for the XBR Network.
//
//  Copyright (C) Crossbar.io Technologies GmbH and contributors
//
//  Licensed under the Apache 2.0 License:
//  https://opensource.org/licenses/Apache-2.0
//
///////////////////////////////////////////////////////////////////////////////

// https://truffleframework.com/docs/truffle/testing/writing-tests-in-javascript

// let reward = web3.toWei(1, 'ether');

const XBRNetwork = artifacts.require("./XBRNetwork.sol");
const XBRToken = artifacts.require("./XBRToken.sol");


contract('XBRNetwork', accounts => {

    // deployed instance of XBRNetwork
    var network;

    // deployed instance of XBRNetwork
    var token;

    // https://solidity.readthedocs.io/en/latest/frequently-asked-questions.html#if-i-return-an-enum-i-only-get-integer-values-in-web3-js-how-to-get-the-named-values

    // enum MemberLevel { NULL, ACTIVE, VERIFIED, RETIRED, PENALTY, BLOCKED }
    const MemberLevel_NULL = 0;
    const MemberLevel_ACTIVE = 1;
    const MemberLevel_VERIFIED = 2;
    const MemberLevel_RETIRED = 3;
    const MemberLevel_PENALTY = 4;
    const MemberLevel_BLOCKED = 5;

    // enum DomainStatus { NULL, ACTIVE, CLOSED }
    const DomainStatus_NULL = 0;
    const DomainStatus_ACTIVE = 1;
    const DomainStatus_CLOSED = 2;

    // enum ActorType { NULL, NETWORK, MARKET, PROVIDER, CONSUMER }
    const ActorType_NULL = 0;
    const ActorType_NETWORK = 1;
    const ActorType_MARKET = 2;
    const ActorType_PROVIDER = 3;
    const ActorType_CONSUMER = 4;

    // enum NodeType { NULL, MASTER, CORE, EDGE }
    const NodeType_NULL = 0;
    const NodeType_MASTER = 1;
    const NodeType_CORE = 2;
    const NodeType_EDGE = 3;

    //
    // test accounts setup
    //

    // the XBR Project
    const owner = accounts[0];

    // 2 test XBR market owners
    const alice = accounts[1];
    const alice_market_maker1 = accounts[2];

    const bob = accounts[3];
    const bob_market_maker1 = accounts[4];

    // 2 test XBR data providers
    const charlie = accounts[5];
    const charlie_provider_delegate1 = accounts[6];

    const donald = accounts[7];
    const donald_provider_delegate1 = accounts[8];

    // 2 test XBR data consumers
    const edith = accounts[9];
    const edith_provider_delegate1 = accounts[10];

    const frank = accounts[11];
    const frank_provider_delegate1 = accounts[12];

    beforeEach('setup contract for each test', async function () {
        network = await XBRNetwork.deployed();
        token = await XBRToken.deployed();
    });

    /*
    afterEach(function (done) {
    });
    */

    it('XBRNetwork.createMarket() : should create new market', async () => {

        if (false) {
            const eula = "QmU7Gizbre17x6V2VR1Q2GJEjz6m8S1bXmBtVxS2vmvb81";
            const profile = "QmQMtxYtLQkirCsVmc3YSTFQWXHkwcASMnu5msezGEwHLT";

            await network.register(eula, profile, {from: alice});
        }

        const marketId = web3.sha3("MyMarket1").substring(0, 34);
        const maker = alice_market_maker1;

        const terms = "";
        const meta = "";

        // 100 XBR security
        const providerSecurity = 100 * 10**18;
        const consumerSecurity = 100 * 10**18;

        // 5% market fee
        const marketFee = 0.05 * 10**9 * 10**18

        await network.createMarket(marketId, terms, meta, maker, providerSecurity, consumerSecurity, marketFee, {from: alice});
    });

    it('XBRNetwork.joinMarket() : should join existing market', async () => {

        const marketId = web3.sha3("MyMarket1").substring(0, 34);

        var actorType = 3; // PROVIDER
        await network.joinMarket(marketId, actorType, {from: bob});

        actorType = 4; // CONSUMER
        await network.joinMarket(marketId, actorType, {from: charlie});
    });
});
