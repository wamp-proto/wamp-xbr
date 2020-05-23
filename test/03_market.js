///////////////////////////////////////////////////////////////////////////////
//
//  XBR Open Data Markets - https://xbr.network
//
//  Copyright (C) Crossbar.io Technologies GmbH and contributors
//
//  Licensed under the Apache 2.0 License:
//  https://opensource.org/licenses/Apache-2.0
//
///////////////////////////////////////////////////////////////////////////////

const utils = require("./utils.js");
const w3_utils = require("web3-utils");
const eth_sig_utils = require("eth-sig-util");
const eth_util = require("ethereumjs-util");
const BN = require('bn.js');

const XBRNetwork = artifacts.require("./XBRNetwork.sol");
const XBRToken = artifacts.require("./XBRToken.sol");
const XBRMarket = artifacts.require("./XBRMarket.sol");
const XBRChannel = artifacts.require("./XBRChannel.sol");


const EIP712MemberRegisterData = {
    types: {
        EIP712Domain: [
            { name: 'name', type: 'string' },
            { name: 'version', type: 'string' },
        ],
        EIP712MemberRegister: [
            {name: 'chainId', type: 'uint256'},
            {name: 'verifyingContract', type: 'address'},
            {name: 'member', type: 'address'},
            {name: 'registered', type: 'uint256'},
            {name: 'eula', type: 'string'},
            {name: 'profile', type: 'string'},
        ]
    },
    primaryType: 'EIP712MemberRegister',
    domain: {
        name: 'XBR',
        version: '1'
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
            { name: 'version', type: 'string' }
        ],
        EIP712MarketJoin: [
            {name: 'chainId', type: 'uint256'},
            {name: 'verifyingContract', type: 'address'},
            {name: 'member', type: 'address'},
            {name: 'joined', type: 'uint256'},
            {name: 'marketId', type: 'bytes16'},
            {name: 'actorType', type: 'uint8'},
            {name: 'meta', type: 'string'},
        ]
    },
    primaryType: 'EIP712MarketJoin',
    domain: {
        name: 'XBR',
        version: '1',
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

    // deployed instance of XBRMarket
    var market;

    var chainId;
    var verifyingContract;

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

    // enum ActorType { NULL, PROVIDER, CONSUMER, PROVIDER_CONSUMER }
    const ActorType_NULL = 0;
    const ActorType_PROVIDER = 1;
    const ActorType_CONSUMER = 2;
    const ActorType_PROVIDER_CONSUMER = 3;

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
    const providerSecurity = new BN(web3.utils.toWei('100', 'ether'));
    const consumerSecurity = new BN(web3.utils.toWei('100', 'ether'));

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
        token = await XBRToken.deployed();
        network = await XBRNetwork.deployed();
        market = await XBRMarket.deployed();
        channel = await XBRChannel.deployed();

        // console.log('Using XBRToken           : ' + token.address);
        // console.log('Using XBRNetwork         : ' + network.address);
        // console.log('Using XBRMarket          : ' + market.address);
        // console.log('Using XBRChannel         : ' + channel.address);

        // FIXME: none of the following works on Ganache v6.9.1 ..

        // TypeError: Cannot read property 'getChainId' of undefined
        // https://web3js.readthedocs.io/en/v1.2.6/web3-eth.html#getchainid
        // const _chainId1 = await web3.eth.getChainId();

        // DEBUG: _chainId2 undefined
        // const _chainId2 = web3.version.network;
        // console.log('DEBUG: _chainId2', _chainId2);

        chainId = await network.verifyingChain();
        verifyingContract = await network.verifyingContract();

        // console.log('Using chainId            : ' + chainId);
        // console.log('Using verifyingContract  : ' + verifyingContract);

        const eula = await network.eula();
        const profile = "QmQMtxYtLQkirCsVmc3YSTFQWXHkwcASMnu5msezGEwHLT";

        const _alice = await network.members(alice);
        const _alice_level = _alice.level.toNumber();
        if (_alice_level == MemberLevel_NULL) {
            await network.registerMember(eula, profile, {from: alice, gasLimit: gasLimit});
        }

        const _bob = await network.members(bob);
        const _bob_level = _bob.level.toNumber();
        if (_bob_level == MemberLevel_NULL) {
            await network.registerMember(eula, profile, {from: bob, gasLimit: gasLimit});
        }

        const _charlie = await network.members(charlie);
        const _charlie_level = _charlie.level.toNumber();
        if (_charlie_level == MemberLevel_NULL) {
            await network.registerMember(eula, profile, {from: charlie, gasLimit: gasLimit});
        }

        const _donald = await network.members(donald);
        const _donald_level = _donald.level.toNumber();
        if (_donald_level == MemberLevel_NULL) {
            await network.registerMember(eula, profile, {from: donald, gasLimit: gasLimit});
        }

        const _edith = await network.members(edith);
        const _edith_level = _edith.level.toNumber();
        if (_edith_level == MemberLevel_NULL) {
            await network.registerMember(eula, profile, {from: edith, gasLimit: gasLimit});
        }

        const _frank = await network.members(frank);
        const _frank_level = _frank.level.toNumber();
        if (_frank_level == MemberLevel_NULL) {
            await network.registerMember(eula, profile, {from: frank, gasLimit: gasLimit});
        }
    });

    it('XBRMarket.createMarket() : should create new market (non-free with security)', async () => {

        const maker = alice_market_maker1;

        const terms = "QmcAuALHaH9pxJP9bzo7go8QU9xUraSozBNVynRs81hpqr";
        const meta = "Qmaa4Rw81a3a1VEx4LxB7HADUAXvZFhCoRdBzsMZyZmqHD";

        // 5% market fee
        const marketFeePercent = 5;
        const totalSupply = await token.totalSupply();
        const marketFee = totalSupply.mul(new BN(marketFeePercent)).div(new BN(100));

        const marketSeq_before = await market.marketSeq();

        await market.createMarket(marketId, token.address, terms, meta, maker, providerSecurity, consumerSecurity, marketFee, {from: alice, gasLimit: gasLimit});

        const marketSeq_after = await market.marketSeq();
        assert(marketSeq_after.eq(marketSeq_before.add(new BN(1))), "market sequence not incremented");

        const market_ = await market.markets(marketId);
        assert(market_.created.gt(1), "wrong created attribute in market");
        assert(market_.seq.eq(marketSeq_before), "wrong seq attribute in market");
        assert.equal(market_.owner, alice, "wrong owner attribute in market");
        assert.equal(market_.coin, token.address, "wrong owner attribute in market");
        assert.equal(market_.terms, terms, "wrong terms attribute in market");
        assert.equal(market_.meta, meta, "wrong meta attribute in market");
        assert.equal(market_.maker, maker, "wrong maker attribute in market");
        assert(market_.providerSecurity.eq(providerSecurity), "wrong providerSecurity attribute in market");
        assert(market_.consumerSecurity.eq(consumerSecurity), "wrong consumerSecurity attribute in market");
        assert(market_.marketFee.eq(marketFee), "wrong marketFee attribute in market");
        assert.equal(market_.signature, null, "wrong signature attribute in market");

        res = await market.getMarketActor(marketId, alice, ActorType_PROVIDER);
        _joined = res["0"].toNumber();
        assert.equal(_joined, 0, "Alice should not yet be market member (provider)");

        res = await market.getMarketActor(marketId, alice, ActorType_CONSUMER);
        _joined = res["0"].toNumber();
        assert.equal(_joined, 0, "Alice should not yet be market member (consumer)");

        const marketByMaker = await market.marketsByMaker(maker)
        assert.equal(marketId, marketByMaker, "marketsByMaker not updated properly")

        // check member (network-level) stats
        const stats = await market.memberStats(alice);
        assert.equal(stats.marketsOwned, 1, "unexpected member stats for marketsOwned: " + stats.marketsOwned);
    });

    it('XBRMarket.joinMarket() : provider should join existing market', async () => {

        // the XBR provider we use here
        const provider = bob;

        // any provider meta data (for the provider actor in the joined market)
        const meta = "QmNgd5cz2jNftnAHBhcRUGdtiaMzb5Rhjqd4etondHHST8";

        if (providerSecurity.gt(new BN(0))) {
            // remember XBR token balance of network contract before joining market
            const _balance_network_before = await token.balanceOf(network.address);

            // transfer some XBR to provider
            await token.transfer(provider, providerSecurity, {from: owner, gasLimit: gasLimit});

            // approve transfer of tokens to join market
            await token.approve(market.address, providerSecurity, {from: provider, gasLimit: gasLimit});
        }

        // XBR provider joins market
        const txn = await market.joinMarket(marketId, ActorType_PROVIDER, meta, {from: provider, gasLimit: gasLimit});

        // check event logs
        assert.equal(txn.receipt.logs.length, 1, "event(s) we expected not emitted");
        const result = txn.receipt.logs[0];

        // check events
        assert.equal(result.event, "ActorJoined", "wrong event was emitted");
        assert.equal(result.args.marketId.substring(0, 34), marketId, "wrong marketId in event");
        assert.equal(result.args.actor, provider, "wrong provider address in event: " + result.args.actor);
        assert.equal(result.args.actorType, ActorType_PROVIDER, "wrong actorType in event: " + result.args.actorType);
        assert(result.args.security.eq(providerSecurity), "wrong providerSecurity in event: " + result.args.security);
        assert.equal(result.args.meta, meta, "wrong meta in event: " + result.args.meta);

        // const market_ = await market.markets(marketId);
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

    it('XBRMarket.joinMarket() : consumer should join existing market', async () => {

        // the XBR consumer we use here
        const consumer = charlie;

        // any consumer meta data (for the consumer actor in the joined market)
        const meta = "QmNgd5cz2jNftnAHBhcRUGdtiaMzb5Rhjqd4etondHHST8";

        if (consumerSecurity.gt(new BN(0))) {
            // remember XBR token balance of network contract before joining market
            const _balance_network_before = await token.balanceOf(network.address);

            // transfer security to consumer
            await token.transfer(consumer, consumerSecurity, {from: owner, gasLimit: gasLimit});

            // approve transfer of tokens to join market
            await token.approve(market.address, consumerSecurity, {from: consumer, gasLimit: gasLimit});
        }

        // XBR consumer joins market
        const txn = await market.joinMarket(marketId, ActorType_CONSUMER, meta, {from: consumer, gasLimit: gasLimit});

        // check event logs
        assert.equal(txn.receipt.logs.length, 1, "event(s) we expected not emitted");
        const result = txn.receipt.logs[0];

        // check events
        assert.equal(result.event, "ActorJoined", "wrong event was emitted");
        assert.equal(result.args.marketId.substring(0, 34), marketId, "wrong marketId in event");
        assert.equal(result.args.actor, consumer, "wrong consumer address in event");
        assert.equal(result.args.actorType, ActorType_CONSUMER, "wrong actorType in event");
        assert(result.args.security.eq(consumerSecurity), "wrong consumerSecurity in event");
        assert.equal(result.args.meta, meta, "wrong meta in event: " + result.args.meta);

        res = await market.getMarketActor(marketId, consumer, ActorType_CONSUMER, {from: consumer, gasLimit: gasLimit});

        _joined = res["0"].toNumber();
        assert.equal(_joined > 0, true, "consumer wasn't joined to market");

        _security = '' + res["1"];
        assert.equal(_security, consumerSecurity, "security differed");

        _meta = res["2"];
        assert.equal(meta, _meta, "meta stored was different");
    });

    it('XBRMarket.joinMarket() : provider should also join as consumer in market', async () => {

        // bob is already a provider in the market
        const consumer = bob;

        // any consumer meta data (for the consumer actor in the joined market)
        const meta = "QmNgd5cz2jNftnAHBhcRUGdtiaMzb5Rhjqd4etondHHST8";

        res = await market.getMarketActor(marketId, consumer, ActorType_CONSUMER);
        _joined = res["0"].toNumber();
        assert.equal(_joined, 0, "consumer is already joined to market");

        res = await market.getMarketActor(marketId, consumer, ActorType_PROVIDER);
        _joined = res["0"].toNumber();
        assert.equal(_joined > 0, true, "provider wasn't joined to market");

        if (consumerSecurity.gt(new BN(0))) {
            // remember XBR token balance of network contract before joining market
            const _balance_network_before = await token.balanceOf(network.address);

            // transfer security to consumer
            await token.transfer(consumer, consumerSecurity, {from: owner, gasLimit: gasLimit});

            // approve transfer of tokens to join market
            await token.approve(market.address, consumerSecurity, {from: consumer, gasLimit: gasLimit});
        }

        // XBR consumer joins market
        const txn = await market.joinMarket(marketId, ActorType_CONSUMER, meta, {from: consumer, gasLimit: gasLimit});

        // check event logs
        assert.equal(txn.receipt.logs.length, 1, "event(s) we expected not emitted");
        const result = txn.receipt.logs[0];

        // check events
        assert.equal(result.event, "ActorJoined", "wrong event was emitted");
        assert.equal(result.args.marketId.substring(0, 34), marketId, "wrong marketId in event");
        assert.equal(result.args.actor, consumer, "wrong consumer address in event");
        assert.equal(result.args.actorType, ActorType_CONSUMER, "wrong actorType in event");
        assert(result.args.security.eq(consumerSecurity), "wrong consumerSecurity in event");
        assert.equal(result.args.meta, meta, "wrong meta in event: " + result.args.meta);

        res = await market.getMarketActor(marketId, consumer, ActorType_CONSUMER, {from: consumer, gasLimit: gasLimit});

        _joined = res["0"].toNumber();
        assert.equal(_joined > 0, true, "consumer wasn't joined to market");

        _security = '' + res["1"];
        assert.equal(_security, consumerSecurity, "security differed");

        _meta = res["2"];
        assert.equal(meta, _meta, "meta stored was different");
    });

    it('XBRMarket.joinMarket() : consumer should also join as provider in market', async () => {

        // charlie is already consumer in the market
        const provider = charlie;

        // any provider meta data (for the consumer actor in the joined market)
        const meta = "QmNgd5cz2jNftnAHBhcRUGdtiaMzb5Rhjqd4etondHHST8";

        res = await market.getMarketActor(marketId, provider, ActorType_CONSUMER);
        _joined = res["0"].toNumber();
        assert.equal(_joined > 0, true, "consumer wasn't joined to market");

        res = await market.getMarketActor(marketId, provider, ActorType_PROVIDER);
        _joined = res["0"].toNumber();
        assert.equal(_joined, 0, "provider is already joined to market");

        if (providerSecurity.gt(new BN(0))) {
            // remember XBR token balance of network contract before joining market
            const _balance_network_before = await token.balanceOf(network.address);

            // transfer security to provider
            await token.transfer(provider, providerSecurity, {from: owner, gasLimit: gasLimit});

            // approve transfer of tokens to join market
            await token.approve(market.address, providerSecurity, {from: provider, gasLimit: gasLimit});
        }

        // XBR provider joins market
        const txn = await market.joinMarket(marketId, ActorType_PROVIDER, meta, {from: provider, gasLimit: gasLimit});

        // check event logs
        assert.equal(txn.receipt.logs.length, 1, "event(s) we expected not emitted");
        const result = txn.receipt.logs[0];

        assert.equal(result.event, "ActorJoined", "wrong event was emitted");

        // check events
        assert.equal(result.event, "ActorJoined", "wrong event was emitted");
        assert.equal(result.args.marketId.substring(0, 34), marketId, "wrong marketId in event");
        assert.equal(result.args.actor, provider, "wrong provider address in event");
        assert.equal(result.args.actorType, ActorType_PROVIDER, "wrong actorType in event");
        assert(result.args.security.eq(providerSecurity), "wrong providerSecurity in event");
        assert.equal(result.args.meta, meta, "wrong meta in event: " + result.args.meta);

        res = await market.getMarketActor(marketId, provider, ActorType_PROVIDER, {from: provider, gasLimit: gasLimit});

        _joined = res["0"].toNumber();
        assert.equal(_joined > 0, true, "provider wasn't joined to market");

        _security = '' + res["1"];
        assert.equal(_security, providerSecurity, "security differed");

        _meta = res["2"];
        assert.equal(meta, _meta, "meta stored was different");
    });

    it('XBRMarket.joinMarket() : provider+consumer should join existing market', async () => {

        // the XBR provider-consumer we use here
        const member = frank;

        // any provider meta data (for the provider-consumer actor in the joined market)
        const meta = "QmNgd5cz2jNftnAHBhcRUGdtiaMzb5Rhjqd4etondHHST8";

        security = new BN(0);
        security = security.add(providerSecurity);
        security = security.add(consumerSecurity);

        if (security.gt(new BN(0))) {
            // transfer XBR to member for test
            await token.transfer(member, security, {from: owner, gasLimit: gasLimit});

            // approve transfer of tokens to join market
            await token.approve(market.address, security, {from: member, gasLimit: gasLimit});
        }

        // XBR provider-consumer joins market
        const txn = await market.joinMarket(marketId, ActorType_PROVIDER_CONSUMER, meta, {from: member, gasLimit: gasLimit});

        // check event logs
        assert.equal(txn.receipt.logs.length, 1, "event(s) we expected not emitted");
        const result = txn.receipt.logs[0];

        // check events
        assert.equal(result.event, "ActorJoined", "wrong event was emitted");
        assert.equal(result.args.marketId.substring(0, 34), marketId, "wrong marketId in event");
        assert.equal(result.args.actor, member, "wrong member address in event: " + result.args.actor);
        assert.equal(result.args.actorType, ActorType_PROVIDER_CONSUMER, "wrong actorType in event: " + result.args.actorType);
        assert(result.args.security.eq(security), "wrong security in event: " + result.args.security);
        assert.equal(result.args.meta, meta, "wrong meta in event: " + result.args.meta);
    });

    it('XBRMarket.joinMarketFor() : provider should join existing market', async () => {

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

            const registered = await web3.eth.getBlockNumber();
            const eula = await network.eula();
            const profile = "QmQMtxYtLQkirCsVmc3YSTFQWXHkwcASMnu5msezGEwHLT";

            const msg_register = {
                'chainId': chainId,
                'verifyingContract': verifyingContract,
                'member': member,
                'registered': registered,
                'eula': eula,
                'profile': profile,
            };
            const signature_register = create_sig_register(member_key, msg_register);
            await network.registerMemberFor(member, registered, eula, profile, signature_register, {from: alice, gasLimit: gasLimit});
        }

        //
        // Join the market
        //
        const meta = "QmNgd5cz2jNftnAHBhcRUGdtiaMzb5Rhjqd4etondHHST8";

        if (providerSecurity.gt(new BN(0))) {
            // transfer some XBR to provider
            await token.transfer(member, providerSecurity, {from: owner, gasLimit: gasLimit});

            // approve transfer of tokens to join market
            await token.approve(market.address, providerSecurity, {from: member, gasLimit: gasLimit});
        }

        const joined = await web3.eth.getBlockNumber();

        const msg_join_market = {
            'chainId': chainId,
            'verifyingContract': verifyingContract,
            'member': member,
            'joined': joined,
            'marketId': marketId,
            'actorType': ActorType_PROVIDER,
            'meta': meta,
        }
        // console.log('MESSAGE', msg_join_market);

        // sign transaction data from "donald" ..
        const signature_join_market = create_sig_join_market(member_key, msg_join_market);
        // console.log('SIGNATURE', signature_join_market);

        // .. but send transaction from "alice"!
        const txn = await market.joinMarketFor(member, joined, marketId, ActorType_PROVIDER, meta, signature_join_market,
            {from: alice, gasLimit: gasLimit});

        // // check event logs
        assert.equal(txn.receipt.logs.length, 1, "event(s) we expected not emitted");
        const result = txn.receipt.logs[0];

        // check events
        assert.equal(result.event, "ActorJoined", "wrong event was emitted");

        // check events
        assert.equal(result.event, "ActorJoined", "wrong event was emitted");
        assert.equal(result.args.marketId.substring(0, 34), marketId, "wrong marketId in event");
        assert.equal(result.args.actor, member, "wrong provider address in event: " + result.args.actor);
        assert.equal(result.args.actorType, ActorType_PROVIDER, "wrong actorType in event: " + result.args.actorType);
        assert(result.args.security.eq(providerSecurity), "wrong providerSecurity in event: " + result.args.security);
        assert.equal(result.args.meta, meta, "wrong meta in event: " + result.args.meta);
    });

    it('XBRMarket.createMarket() : should create new market (free without security)', async () => {

        const marketOp = bob;
        const maker = bob_market_maker1;

        const terms = "QmcAuALHaH9pxJP9bzo7go8QU9xUraSozBNVynRs81hpqr";
        const meta = "Qmaa4Rw81a3a1VEx4LxB7HADUAXvZFhCoRdBzsMZyZmqHD";

        const marketId = utils.sha3("MyMarket2").substring(0, 34);
        const marketSeq_before = await market.marketSeq();

        // create free market, with zero security for both consumers & providers
        await market.createMarket(marketId, token.address, terms, meta, maker, 0, 0, 0, {from: marketOp, gasLimit: gasLimit});

        const marketSeq_after = await market.marketSeq();
        assert(marketSeq_after.eq(marketSeq_before.add(new BN(1))), "market sequence not incremented");

        const market_ = await market.markets(marketId);
        assert(market_.created.gt(1), "wrong created attribute in market");
        assert(market_.seq.eq(marketSeq_before), "wrong seq attribute in market");
        assert.equal(market_.owner, marketOp, "wrong owner attribute in market");
        assert.equal(market_.coin, token.address, "wrong owner attribute in market");
        assert.equal(market_.terms, terms, "wrong terms attribute in market");
        assert.equal(market_.meta, meta, "wrong meta attribute in market");
        assert.equal(market_.maker, maker, "wrong maker attribute in market");
        assert(market_.providerSecurity.eq(new BN(0)), "wrong providerSecurity attribute in market");
        assert(market_.consumerSecurity.eq(new BN(0)), "wrong consumerSecurity attribute in market");
        assert(market_.marketFee.eq(new BN(0)), "wrong marketFee attribute in market");
        assert.equal(market_.signature, null, "wrong signature attribute in market");

        const marketByMaker = await market.marketsByMaker(maker)
        assert.equal(marketId, marketByMaker, "marketsByMaker not updated properly")

        const stats = await market.memberStats(marketOp);
        assert.equal(stats.marketsOwned, 1, "unexpected member stats for marketsOwned: " + stats.marketsOwned);

        res = await market.getMarketActor(marketId, alice, ActorType_PROVIDER);
        _joined = res["0"].toNumber();
        assert.equal(_joined, 0, "Alice should not yet be market member (provider)");

        res = await market.getMarketActor(marketId, alice, ActorType_CONSUMER);
        _joined = res["0"].toNumber();
        assert.equal(_joined, 0, "Alice should not yet be market member (consumer)");
    });

    it('XBRMarket.joinMarket() : provider+consumer should join existing free market', async () => {

        const marketId = utils.sha3("MyMarket2").substring(0, 34);

        // the XBR provider-consumer we use here
        const member = frank;

        // any provider meta data (for the provider-consumer actor in the joined market)
        const meta = "QmNgd5cz2jNftnAHBhcRUGdtiaMzb5Rhjqd4etondHHST8";

        // XBR provider-consumer joins market
        const txn = await market.joinMarket(marketId, ActorType_PROVIDER_CONSUMER, meta, {from: member, gasLimit: gasLimit});

        // check event logs
        assert.equal(txn.receipt.logs.length, 1, "event(s) we expected not emitted");
        const result = txn.receipt.logs[0];

        // check events
        assert.equal(result.event, "ActorJoined", "wrong event was emitted");
        assert.equal(result.args.marketId.substring(0, 34), marketId, "wrong marketId in event");
        assert.equal(result.args.actor, member, "wrong member address in event: " + result.args.actor);
        assert.equal(result.args.actorType, ActorType_PROVIDER_CONSUMER, "wrong actorType in event: " + result.args.actorType);
        assert(result.args.security.eq(new BN(0)), "wrong security in event: " + result.args.security);
        assert.equal(result.args.meta, meta, "wrong meta in event: " + result.args.meta);


        // FIXME
        // const provider_actor = await market.markets(marketId).providerActors(member);
        // console.log("provider_actor", provider_actor);

        // const consumer_actor = await market.markets(marketId).consumerActors(member);
        // console.log("consumer_actor", consumer_actor);
    });

    it('XBRMarket.leaveMarket() : provider+consumer should leave free market (immediately)', async () => {

        const marketId = utils.sha3("MyMarket2").substring(0, 34);

        // the XBR provider-consumer we use here
        const member = frank;

        // any provider meta data (for the provider-consumer actor in the joined market)
        const meta = "QmNgd5cz2jNftnAHBhcRUGdtiaMzb5Rhjqd4etondHHST8";

        // XBR provider-consumer joins market
        const txn = await market.leaveMarket(marketId, ActorType_PROVIDER_CONSUMER, {from: member, gasLimit: gasLimit});

        // check event logs
        assert.equal(txn.receipt.logs.length, 1, "event(s) we expected not emitted");
        const result = txn.receipt.logs[0];

        // check events
        assert.equal(result.event, "ActorLeft", "wrong event was emitted");
        assert.equal(result.args.marketId.substring(0, 34), marketId, "wrong marketId in event");
        assert.equal(result.args.actor, member, "wrong member address in event: " + result.args.actor);
        assert.equal(result.args.actorType, ActorType_PROVIDER_CONSUMER, "wrong actorType in event: " + result.args.actorType);
        assert(result.args.securitiesToBeRefunded.eq(new BN(0)), "wrong security in event: " + result.args.securitiesToBeRefunded);
    });
});
