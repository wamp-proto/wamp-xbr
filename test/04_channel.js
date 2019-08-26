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

const web3 = require("web3");
const utils = require("./utils.js");

const XBRNetwork = artifacts.require("./XBRNetwork.sol");
const XBRToken = artifacts.require("./XBRToken.sol");



contract('XBRNetwork', accounts => {

    //const gasLimit = 6721975;
    const gasLimit = 0xfffffffffff;
    //const gasLimit = 100000000;

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
    const ActorType_PROVIDER = 1;
    const ActorType_CONSUMER = 2;

    // enum NodeType { NULL, MASTER, CORE, EDGE }
    const NodeType_NULL = 0;
    const NodeType_MASTER = 1;
    const NodeType_CORE = 2;
    const NodeType_EDGE = 3;

    // 100 XBR security
    //const providerSecurity = 0;
    //const consumerSecurity = 0;
    const providerSecurity = '' + 100 * 10**18;
    const consumerSecurity = '' + 100 * 10**18;

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

        const eula = "QmU7Gizbre17x6V2VR1Q2GJEjz6m8S1bXmBtVxS2vmvb81";
        const profile = "QmQMtxYtLQkirCsVmc3YSTFQWXHkwcASMnu5msezGEwHLT";

        const _alice = await network.members(alice);
        const _alice_level = _alice.level.toNumber();
        if (_alice_level == MemberLevel_NULL) {
            await network.register(eula, profile, {from: alice, gasLimit: gasLimit});
        }

        const _bob = await network.members(bob);
        const _bob_level = _bob.level.toNumber();
        if (_bob_level == MemberLevel_NULL) {
            await network.register(eula, profile, {from: bob, gasLimit: gasLimit});
        }

        const _charlie = await network.members(charlie);
        const _charlie_level = _charlie.level.toNumber();
        if (_charlie_level == MemberLevel_NULL) {
            await network.register(eula, profile, {from: charlie, gasLimit: gasLimit});
        }

        const marketId = utils.sha3("MyMarket1").substring(0, 34);
        const market = await network.markets(marketId);

        if (market.created.toNumber() == 0) {
            /////////// market operator and market maker
            const operator = alice;
            const maker = alice_market_maker1;

            const terms = "";
            const meta = "";

            // 5% market fee
            // FIXME: how to write a large uint256 literal?
            // const marketFee = '' + Math.trunc(0.05 * 10**9 * 10**18);
            const marketFee = 0;

            await network.createMarket(marketId, terms, meta, maker, providerSecurity, consumerSecurity, marketFee, {from: operator, gasLimit: gasLimit});

            /////////// the XBR provider we use here
            const provider = bob;

            if (providerSecurity) {
                // remember XBR token balance of network contract before joining market
                const _balance_network_before = await token.balanceOf(network.address);

                // transfer 1000 XBR to provider
                await token.transfer(provider, providerSecurity, {from: owner, gasLimit: gasLimit});

                // approve transfer of tokens to join market
                await token.approve(network.address, providerSecurity, {from: provider, gasLimit: gasLimit});
            }

            // XBR provider joins market
            await network.joinMarket(marketId, ActorType_PROVIDER, meta, {from: provider, gasLimit: gasLimit});

            /////////// the XBR consumer we use here
            const consumer = charlie;

            if (consumerSecurity) {
                // remember XBR token balance of network contract before joining market
                const _balance_network_before = await token.balanceOf(network.address);

                // transfer 1000 XBR to consumer
                await token.transfer(consumer, consumerSecurity, {from: owner, gasLimit: gasLimit});

                // approve transfer of tokens to join market
                await token.approve(network.address, consumerSecurity, {from: consumer, gasLimit: gasLimit});
            }

            // XBR consumer joins market
            await network.joinMarket(marketId, ActorType_CONSUMER, meta, {from: consumer, gasLimit: gasLimit});
        }
    });


    it('XBRNetwork.openPaymentChannel() : consumer should open payment channel', async () => {

        // openPaymentChannel (bytes16 marketId, address consumer, uint256 amount)

        // the XBR consumer we use here
        const market_operator = alice;
        const consumer = charlie;
        const delegate = charlie_provider_delegate1;

        // XBR market to join
        const marketId = utils.sha3("MyMarket1").substring(0, 34);
        const market = await network.markets(marketId);

        // console.log('MARKET OWNER', market_operator, market);

        // 50 XBR channel deposit
        const amount = '' + 50 * 10**18;
        // const amount = consumerSecurity / 4;
        const timeout = 100;

        // transfer tokens to consumer
        await token.transfer(consumer, amount, {from: owner, gasLimit: gasLimit});

        // approve transfer of tokens to open payment channel
        await token.approve(network.address, amount, {from: consumer, gasLimit: gasLimit});

        // XBR consumer opens a payment channel in the market
        const txn = await network.openPaymentChannel(marketId, market.owner, delegate, amount, timeout, {from: consumer, gasLimit: gasLimit});
        //console.log('result1 txn', txn);
        //const result1 = txn.receipt.logs[0];
        //console.log('result1', result1);

        // check event logs
        assert.equal(txn.receipt.logs.length, 1, "event(s) we expected not emitted");
        const result2 = txn.receipt.logs[0];

        // check events
        assert.equal(result2.event, "ChannelCreated", "wrong event was emitted");

        // event ChannelCreated(bytes16 marketId, address sender, address delegate, address receiver, address channel)
        // FIXME: -0x9f80cc2aeb85c799e6c468af409dd6eb00000000000000000000000000000000
        //assert.equal(result2.args.marketId, marketId, "wrong marketId in event");
        assert.equal(result2.args.sender, consumer, "wrong sender address in event");
        assert.equal(result2.args.delegate, delegate, "wrong delegate address in event");
        assert.equal(result2.args.recipient, market.owner, "wrong recipient address in event");
        //assert.equal(result2.args.channel, channel, "wrong channel address in event");
    });
});
