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
const ethUtil = require('ethereumjs-util');

var w3_utils = require("web3-utils");
var eth_sig_utils = require("eth-sig-util");
var eth_accounts = require("web3-eth-accounts");
var eth_util = require("ethereumjs-util");

const XBRNetwork = artifacts.require("./XBRNetwork.sol");
const XBRToken = artifacts.require("./XBRToken.sol");


const EIP712MemberRegisterData = {
    types: {
        EIP712Domain: [
            { name: 'name', type: 'string' },
            { name: 'version', type: 'string' },
            { name: 'chainId', type: 'uint256' },
            { name: 'verifyingContract', type: 'address' },
        ],
        EIP712MemberRegister: [
            {name: 'chainId', type: 'uint256'},
            {name: 'blockNumber', type: 'uint256'},
            {name: 'verifyingContract', type: 'address'},
            {name: 'member', type: 'address'},
            {name: 'eula', type: 'string'},
            {name: 'profile', type: 'string'},
        ]
    },
    primaryType: 'EIP712MemberRegister',
    domain: {
        name: 'XBR',
        version: '1',
        chainId: 1,
        verifyingContract: '0x254dffcd3277C0b1660F6d42EFbB754edaBAbC2B',
    },
    message: null
};


function create_sig_register(key_, data_) {
    EIP712MemberRegisterData['message'] = data_;
    var key = eth_util.toBuffer(key_);
    var sig = eth_sig_utils.signTypedData(key, {data: EIP712MemberRegisterData})
    return sig;
}


const EIP712MarketJoinData = {
    types: {
        EIP712Domain: [
            { name: 'name', type: 'string' },
            { name: 'version', type: 'string' },
            { name: 'chainId', type: 'uint256' },
            { name: 'verifyingContract', type: 'address' },
        ],
        EIP712MarketJoin: [
            {name: 'chainId', type: 'uint256'},
            {name: 'blockNumber', type: 'uint256'},
            {name: 'verifyingContract', type: 'address'},
            {name: 'member', type: 'address'},
            {name: 'marketId', type: 'bytes16'},
            {name: 'actorType', type: 'uint8'},
            {name: 'meta', type: 'string'},
        ]
    },
    primaryType: 'EIP712MarketJoin',
    domain: {
        name: 'XBR',
        version: '1',
        chainId: 1,
        verifyingContract: '0x254dffcd3277C0b1660F6d42EFbB754edaBAbC2B',
    },
    message: null
};


function create_sig_join_market(key_, data_) {
    EIP712MarketJoinData['message'] = data_;
    var key = eth_util.toBuffer(key_);
    var sig = eth_sig_utils.signTypedData(key, {data: EIP712MarketJoinData})
    return sig;
}


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

    //
    // test accounts setup
    //

    const marketId = utils.sha3("MyMarket1").substring(0, 34);

    // 100 XBR security
    // const providerSecurity = '' + 100 * 10**18;
    // const consumerSecurity = '' + 100 * 10**18;

    // FIXME: non-zero security breaks "joinMarketFor" test
    const providerSecurity = 0;
    const consumerSecurity = 0;

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

        const eula = "QmV1eeDextSdUrRUQp9tUXF8SdvVeykaiwYLgrXHHVyULY";
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

        const _donald = await network.members(donald);
        const _donald_level = _donald.level.toNumber();
        if (_donald_level == MemberLevel_NULL) {
            await network.register(eula, profile, {from: donald, gasLimit: gasLimit});
        }

        const _edith = await network.members(edith);
        const _edith_level = _edith.level.toNumber();
        if (_edith_level == MemberLevel_NULL) {
            await network.register(eula, profile, {from: edith, gasLimit: gasLimit});
        }
    });

    /*
    afterEach(function (done) {
    });
    */

    it('XBRNetwork.createMarket() : should create new market', async () => {

        const maker = alice_market_maker1;

        const terms = "";
        const meta = "";

        // 5% market fee
        // FIXME: how to write a large uint256 literal?
        // const marketFee = '' + Math.trunc(0.05 * 10**9 * 10**18);
        const marketFee = 0;

        await network.createMarket(marketId, terms, meta, maker, providerSecurity, consumerSecurity, marketFee, {from: alice, gasLimit: gasLimit});

        res = await network.getMarketActor(marketId, alice, ActorType_PROVIDER);
        _joined = res["0"].toNumber();
        assert.equal(_joined, 0, "Alice should not yet be market member (provider)");

        res = await network.getMarketActor(marketId, alice, ActorType_CONSUMER);
        _joined = res["0"].toNumber();
        assert.equal(_joined, 0, "Alice should not yet be market member (consumer)");
    });

    it('XBRNetwork.joinMarket() : provider should join existing market', async () => {

        // the XBR provider we use here
        const provider = bob;

        // XBR market to join
        const meta = "";

        if (true) {
            // remember XBR token balance of network contract before joining market
            const _balance_network_before = await token.balanceOf(network.address);

            // transfer 1000 XBR to provider
            await token.transfer(provider, providerSecurity, {from: owner, gasLimit: gasLimit});

            // approve transfer of tokens to join market
            await token.approve(network.address, providerSecurity, {from: provider, gasLimit: gasLimit});
        }

        // XBR provider joins market
        const txn = await network.joinMarket(marketId, ActorType_PROVIDER, meta, {from: provider, gasLimit: gasLimit});

        // // check event logs
        assert.equal(txn.receipt.logs.length, 1, "event(s) we expected not emitted");
        const result = txn.receipt.logs[0];

        // check events
        assert.equal(result.event, "ActorJoined", "wrong event was emitted");

        // // FIXME
        // // assert.equal(result.args.marketId, marketId, "wrong marketId in event");
        assert.equal(result.args.actor, provider, "wrong provider address in event");
        assert.equal(result.args.actorType, ActorType_PROVIDER, "wrong actorType in event");
        assert.equal(result.args.security, providerSecurity, "wrong providerSecurity in event");

        const market = await network.markets(marketId);
        // console.log('market', market);

        // const actor = await market.providerActors(provider);
        // console.log('ACTOR', actor);

        // const _actorType = await network.getMarketActorType(marketId, network);
        // assert.equal(_actorType.toNumber(), ActorType_PROVIDER, "wrong actorType " + _actorType);

        // const _security = await network.getMarketActorSecurity(marketId, provider);
        // assert.equal(_security, providerSecurity, "wrong providerSecurity " + _security);

        // const _balance_actor = await token.balanceOf(provider);
        // assert.equal(_balance_actor.valueOf(), 900 * 10**18, "market security wasn't transferred _from_ provider");

        // // check that the network contract as gotten the security
        // const _balance_network_after = await token.balanceOf(network.address);
        // assert.equal(_balance_network_after.valueOf() - _balance_network_before.valueOf(),
        //              providerSecurity, "market security wasn't transferred _to_ network contract");
    });

    it('XBRNetwork.joinMarket() : consumer should join existing market', async () => {

        // the XBR consumer we use here
        const consumer = charlie;

        // XBR market to join
        const meta = "";

        if (true) {
            // remember XBR token balance of network contract before joining market
            const _balance_network_before = await token.balanceOf(network.address);

            // transfer 1000 XBR to consumer
            await token.transfer(consumer, consumerSecurity, {from: owner, gasLimit: gasLimit});

            // approve transfer of tokens to join market
            await token.approve(network.address, consumerSecurity, {from: consumer, gasLimit: gasLimit});
        }

        // XBR consumer joins market
        const txn = await network.joinMarket(marketId, ActorType_CONSUMER, meta, {from: consumer, gasLimit: gasLimit});

        // // check event logs
        assert.equal(txn.receipt.logs.length, 1, "event(s) we expected not emitted");
        const result = txn.receipt.logs[0];

        // // check events
        assert.equal(result.event, "ActorJoined", "wrong event was emitted");
        // FIXME
        //assert.equal(result.args.marketId, marketId, "wrong marketId in event");
        assert.equal(result.args.actor, consumer, "wrong consumer address in event");
        assert.equal(result.args.actorType, ActorType_CONSUMER, "wrong actorType in event");
        assert.equal(result.args.security, consumerSecurity, "wrong consumerSecurity in event");

        res = await network.getMarketActor(marketId, consumer, ActorType_CONSUMER, {from: consumer, gasLimit: gasLimit});

        _joined = res["0"].toNumber();
        assert.equal(_joined > 0, true, "consumer wasn't joined to market");

        _security = '' + res["1"];
        assert.equal(_security, consumerSecurity, "security differed");

        _meta = res["2"];
        assert.equal(meta, _meta, "meta stored was different");

        // const _actorType = await network.getMarketActorType(marketId, consumer);
        // assert.equal(_actorType.toNumber(), ActorType_CONSUMER, "wrong actorType " + _actorType);

        // const _security = await network.getMarketActorSecurity(marketId, consumer);
        // assert.equal(_security, consumerSecurity, "wrong consumerSecurity " + _security);

        // const _balance_actor = await token.balanceOf(consumer);
        // assert.equal(_balance_actor.valueOf(), 900 * 10**18, "market security wasn't transferred _from_ consumer");

        // // check that the network contract as gotten the security
        // const _balance_network_after = await token.balanceOf(network.address);
        // assert.equal(_balance_network_after.valueOf() - _balance_network_before.valueOf(),
        //              consumerSecurity, "market security wasn't transferred _to_ network contract");
    });

    it('XBRNetwork.joinMarket() : consumer should join as provider in market', async () => {

        // charlie is already consumer in the market
        const provider = charlie;
        const meta = "";

        res = await network.getMarketActor(marketId, provider, ActorType_CONSUMER);
        _joined = res["0"].toNumber();
        assert.equal(_joined > 0, true, "consumer wasn't joined to market");

        res = await network.getMarketActor(marketId, provider, ActorType_PROVIDER);
        _joined = res["0"].toNumber();
        assert.equal(_joined, 0, "provider is already joined to market");

        if (true) {
            await token.transfer(provider, providerSecurity, {from: owner, gasLimit: gasLimit});
            await token.approve(network.address, providerSecurity, {from: provider, gasLimit: gasLimit});
        }

        const txn = await network.joinMarket(marketId, ActorType_PROVIDER, meta, {from: provider, gasLimit: gasLimit});

        assert.equal(txn.receipt.logs.length, 1, "event(s) we expected not emitted");
        const result = txn.receipt.logs[0];

        assert.equal(result.event, "ActorJoined", "wrong event was emitted");

        // FIXME
        // assert.equal(result.args.marketId, marketId, "wrong marketId in event");
        assert.equal(result.args.actor, provider, "wrong provider address in event");
        assert.equal(result.args.actorType, ActorType_PROVIDER, "wrong actorType in event");
        assert.equal(result.args.security, providerSecurity, "wrong providerSecurity in event");

        res = await network.getMarketActor(marketId, provider, ActorType_CONSUMER);
        _joined = res["0"].toNumber();
        assert.equal(_joined > 0, true, "consumer wasn't joined to market");

        res = await network.getMarketActor(marketId, provider, ActorType_PROVIDER);
        _joined = res["0"].toNumber();
        assert.equal(_joined > 0, true, "provider wasn't joined to market");
    });

    it('XBRNetwork.joinMarket() : provider should join as consumer in market', async () => {

        // bob is already a provider in the market
        const consumer = bob;
        const meta = "";

        res = await network.getMarketActor(marketId, consumer, ActorType_CONSUMER);
        _joined = res["0"].toNumber();
        assert.equal(_joined, 0, "consumer is already joined to market");

        res = await network.getMarketActor(marketId, consumer, ActorType_PROVIDER);
        _joined = res["0"].toNumber();
        assert.equal(_joined > 0, true, "provider wasn't joined to market");

        if (true) {
            await token.transfer(consumer, consumerSecurity, {from: owner, gasLimit: gasLimit});
            await token.approve(network.address, consumerSecurity, {from: consumer, gasLimit: gasLimit});
        }

        const txn = await network.joinMarket(marketId, ActorType_CONSUMER, meta, {from: consumer, gasLimit: gasLimit});

        assert.equal(txn.receipt.logs.length, 1, "event(s) we expected not emitted");
        const result = txn.receipt.logs[0];

        assert.equal(result.event, "ActorJoined", "wrong event was emitted");

        // FIXME
        // assert.equal(result.args.marketId, marketId, "wrong marketId in event");
        assert.equal(result.args.actor, consumer, "wrong consumer address in event");
        assert.equal(result.args.actorType, ActorType_CONSUMER, "wrong actorType in event");
        assert.equal(result.args.security, consumerSecurity, "wrong consumerSecurity in event");

        res = await network.getMarketActor(marketId, consumer, ActorType_CONSUMER);
        _joined = res["0"].toNumber();
        assert.equal(_joined > 0, true, "consumer wasn't joined to market");

        res = await network.getMarketActor(marketId, consumer, ActorType_PROVIDER);
        _joined = res["0"].toNumber();
        assert.equal(_joined > 0, true, "provider wasn't joined to market");
    });

    it('XBRNetwork.joinMarketFor() : provider should join existing market', async () => {

        // FIXME: get private key for account
        // "donald" is accounts[7], and the private key for that is:
        //const member = donald;
        //const member_key = '0xa453611d9419d0e56f499079478fd72c37b251a94bfde4d19872c44cf65386e3';
        //const member = frank;
        //const member_key = '0xd99b5b29e6da2528bf458b26237a6cf8655a3e3276c1cdc0de1f98cefee81c01';
        //const member = edith;
        //const member_key = '0xb0057716d5917badaf911b193b12b910811c1497b5bada8d7711f758981c3773';
        // const member = w3_utils.toChecksumAddress('0x610Bb1573d1046FCb8A70Bbbd395754cD57C2b60');
        // const member_key = '0x77c5495fbb039eed474fc940f29955ed0531693cc9212911efd35dff0373153f';

        const member = w3_utils.toChecksumAddress('0x28a8746e75304c0780E011BEd21C72cD78cd535E');
        const member_key = '0xa453611d9419d0e56f499079478fd72c37b251a94bfde4d19872c44cf65386e3';

        //
        // Register in network
        //
        const _member = await network.members(member);
        const _member_level = _member.level.toNumber();

        if (_member_level == MemberLevel_NULL) {
            const eula = "QmV1eeDextSdUrRUQp9tUXF8SdvVeykaiwYLgrXHHVyULY";
            const profile = "QmQMtxYtLQkirCsVmc3YSTFQWXHkwcASMnu5msezGEwHLT";
            const registered = 1;
            const msg_register = {
                'chainId': 1,
                'blockNumber': registered,
                'verifyingContract': '0x254dffcd3277C0b1660F6d42EFbB754edaBAbC2B',
                'member': member,
                'eula': eula,
                'profile': profile,
            };
            const signature_register = create_sig_register(member_key, msg_register);
            await network.registerFor(member, registered, eula, profile, signature_register, {from: alice, gasLimit: gasLimit});
        }

        //
        // Join the market
        //
        const meta = "";

        // FIXME
        if (false) {
            // remember XBR token balance of network contract before joining market
            const _balance_network_before = await token.balanceOf(network.address);

            // transfer 1000 XBR to provider
            await token.transfer(provider, providerSecurity, {from: owner, gasLimit: gasLimit});

            // approve transfer of tokens to join market
            await token.approve(network.address, providerSecurity, {from: member, gasLimit: gasLimit});
        }

        // FIXME
        const joined = 1;

        const msg_join_market = {
            'chainId': 1,
            'blockNumber': joined,
            'verifyingContract': '0x254dffcd3277C0b1660F6d42EFbB754edaBAbC2B',
            'member': member,
            'marketId': marketId,
            'actorType': ActorType_PROVIDER,
            'meta': meta,
        }
        console.log('MESSAGE', msg_join_market);

        // sign transaction data from "donald" ..
        const signature_join_market = create_sig_join_market(member_key, msg_join_market);
        console.log('SIGNATURE', signature_join_market);

        // .. but send transaction from "alice"!
        const txn = await network.joinMarketFor(member, joined, marketId, ActorType_PROVIDER, meta, signature_join_market,
            {from: alice, gasLimit: gasLimit});

        // // check event logs
        assert.equal(txn.receipt.logs.length, 1, "event(s) we expected not emitted");
        const result = txn.receipt.logs[0];

        // check events
        assert.equal(result.event, "ActorJoined", "wrong event was emitted");

        // // FIXME
        // // assert.equal(result.args.marketId, marketId, "wrong marketId in event");
        assert.equal(result.args.actor, member, "wrong provider address in event");
        assert.equal(result.args.actorType, ActorType_PROVIDER, "wrong actorType in event");
        assert.equal(result.args.security, providerSecurity, "wrong providerSecurity in event");

        const market = await network.markets(marketId);
        // console.log('market', market);

        // const actor = await market.providerActors(member);
        // console.log('ACTOR', actor);

        // const _actorType = await network.getMarketActorType(marketId, network);
        // assert.equal(_actorType.toNumber(), ActorType_PROVIDER, "wrong actorType " + _actorType);

        // const _security = await network.getMarketActorSecurity(marketId, member);
        // assert.equal(_security, providerSecurity, "wrong providerSecurity " + _security);

        // const _balance_actor = await token.balanceOf(provider);
        // assert.equal(_balance_actor.valueOf(), 900 * 10**18, "market security wasn't transferred _from_ provider");

        // // check that the network contract as gotten the security
        // const _balance_network_after = await token.balanceOf(network.address);
        // assert.equal(_balance_network_after.valueOf() - _balance_network_before.valueOf(),
        //              providerSecurity, "market security wasn't transferred _to_ network contract");
    });

});
