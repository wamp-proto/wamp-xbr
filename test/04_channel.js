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

const XBRNetwork = artifacts.require("./XBRNetwork.sol");
const XBRToken = artifacts.require("./XBRToken.sol");
const XBRChannel = artifacts.require("./XBRChannel.sol");


// dicether/eip712
// eth-sig-util
// eth_sig_utils.signTypedData
// eth_sig_utils.recoverTypedSignature
// https://github.com/MetaMask/eth-sig-util#signtypeddata-privatekeybuffer-msgparams
// https://github.com/MetaMask/eth-sig-util#signtypeddata-privatekeybuffer-msgparams

var w3_utils = require("web3-utils");
var eth_sig_utils = require("eth-sig-util");
var eth_accounts = require("web3-eth-accounts");
var eth_util = require("ethereumjs-util");

var buyer_key = "0x" + "a4985a2ed93107886e9a1f12c7b8e2e351cc1d26c42f3aab7f220f3a7d08fda6";
var buyer_key_bytes = w3_utils.hexToBytes(buyer_key);
var account = new eth_accounts().privateKeyToAccount(buyer_key);
var addr = eth_util.toBuffer(account.address);

console.log("Using private key: " + buyer_key);
//console.log(buyer_key_bytes);
//console.log(account);
console.log("Account canonical address: " + account.address);
//console.log(addr);


//console.log(data);

const DomainData = {
    types: {
        EIP712Domain: [
            { name: 'name', type: 'string' },
            { name: 'version', type: 'string' },
            { name: 'chainId', type: 'uint256' },
            { name: 'verifyingContract', type: 'address' },
        ],
        ChannelClose: [
            {'name': 'channel_adr', 'type': 'address'},
            {'name': 'channel_seq', 'type': 'uint32'},
            {'name': 'balance', 'type': 'uint256'},
        ]
    },
    primaryType: 'ChannelClose',
    domain: {
        name: 'XBR',
        version: '1',
        chainId: 1,
        verifyingContract: '0x254dffcd3277C0b1660F6d42EFbB754edaBAbC2B',
    },
    message: null,
};



function create_sig(key_, message_) {

    DomainData['message'] = message_;

    const key = eth_util.toBuffer(key_);

    const sig = eth_sig_utils.signTypedData(key, {data: DomainData})

    return eth_util.toBuffer(sig);
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

    // 100 XBR security
    //const providerSecurity = 0;
    //const consumerSecurity = 0;
    const providerSecurity = '' + 100 * 10**18;
    const consumerSecurity = '' + 100 * 10**18;

    //
    // test accounts setup
    //
    const owner = accounts[0];
    const alice = accounts[1];
    const alice_market_maker1 = accounts[2];
    const alice_market_maker1_key = '0x6cbed15c793ce57650b9877cf6fa156fbef513c4e6134f022a85b1ffdd59b2a1';
    const bob = accounts[3];
    const bob_delegate1 = accounts[4];
    const bob_delegate1_key = '0x646f1ce2fdad0e6deeeb5c7e8e5543bdde65e86029e2fd9fc169899c440a7913';
    const charlie = accounts[5];
    const charlie_delegate1 = accounts[6];
    const donald = accounts[7];
    const donald_delegate1 = accounts[8];
    const edith = accounts[9];
    const edith_delegate1 = accounts[10];
    const frank = accounts[11];
    const frank_delegate1 = accounts[12];

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

        // the XBR consumer we use here
        const market_operator = alice;
        const consumer = charlie;
        const delegate = charlie_delegate1;

        // XBR market to join
        const marketId = utils.sha3("MyMarket1").substring(0, 34);
        const market = await network.markets(marketId);

        // console.log('MARKET OWNER', market_operator, market);

        // 50 XBR channel deposit
        const amount = '' + 50 * 10**18;
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

        //     event ChannelCreated (bytes16 indexed marketId, address sender, address delegate,
        //                           address recipient, address channel, XBRChannel.ChannelType channelType);
        assert.equal(result2.args.marketId.substring(0, 34), marketId, "wrong marketId in event");
        assert.equal(result2.args.sender, consumer, "wrong sender address in event");
        assert.equal(result2.args.delegate, delegate, "wrong delegate address in event");
        assert.equal(result2.args.recipient, market.owner, "wrong recipient address in event");
        //assert.equal(result2.args.channel, channel, "wrong channel address in event");
        assert.equal(result2.args.channelType, 1, "wrong channelType in event");

        const channel = await XBRChannel.at(result2.args.channel);
        const _ctype = await channel.ctype();
        const _state = await channel.state();
        const _marketId = await channel.marketId();
        const _sender = await channel.sender();
        const _delegate = await channel.delegate();
        const _recipient = await channel.recipient();
        const _amount = await channel.amount();
        const _timeout = await channel.timeout();
        const _openedAt = await channel.openedAt();
        const _closedAt = await channel.closedAt();

        console.log('CHANNEL_address', result2.args.channel);
        console.log('CHANNEL_ctype', _ctype.toNumber());
        console.log('CHANNEL_state', _state.toNumber());
        console.log('CHANNEL_marketId', _marketId);
        console.log('CHANNEL_sender', _sender);
        console.log('CHANNEL_delegate', _delegate);
        console.log('CHANNEL_recipient', _recipient);
        console.log('CHANNEL_amount', '' + _amount);
        console.log('CHANNEL_timeout', _timeout.toNumber());
        console.log('CHANNEL_openedAt', _openedAt.toNumber());
        console.log('CHANNEL_closedAt', _closedAt.toNumber());
    });

    it('XBRNetwork.requestPayingChannel() : provider should request paying channel', async () => {

        // the XBR provider we use here
        const market_operator = alice;
        const maker = alice_market_maker1;
        const provider = bob;
        const delegate = bob_delegate1;

        // XBR market to join
        const marketId = utils.sha3("MyMarket1").substring(0, 34);
        const market = await network.markets(marketId);

        // console.log('MARKET OWNER', market_operator, market);

        // 50 XBR channel deposit
        const amount = '' + 50 * 10**18;
        const timeout = 100;

        // transfer tokens to provider
        await token.transfer(provider, amount, {from: owner, gasLimit: gasLimit});

        // approve transfer of tokens to open paying channel
        await token.approve(maker, amount, {from: provider, gasLimit: gasLimit});

        // XBR provider requests a paying channel in the market
        const txn = await network.requestPayingChannel(marketId, provider, delegate, amount, timeout, {from: provider, gasLimit: gasLimit});
        //console.log('result1 txn', txn);
        //const result1 = txn.receipt.logs[0];
        //console.log('result1', result1);

        // check event logs
        assert.equal(txn.receipt.logs.length, 1, "event(s) we expected not emitted");
        const result2 = txn.receipt.logs[0];

        // check events
        assert.equal(result2.event, "PayingChannelRequestCreated", "wrong event was emitted");

        //event PayingChannelRequestCreated (bytes16 indexed marketId, address sender, address recipient, address delegate,
        //                                   uint256 amount, uint32 timeout);
        assert.equal(result2.args.marketId.substring(0, 34), marketId, "wrong marketId in event");
        assert.equal(result2.args.sender, provider, "wrong sender address in event");
        assert.equal(result2.args.delegate, delegate, "wrong delegate address in event");
        assert.equal(result2.args.recipient, provider, "wrong recipient address in event");
        assert.equal(result2.args.amount, amount, "wrong amount in event");
        assert.equal(result2.args.timeout, timeout, "wrong timeout in event");
    });

    it('XBRNetwork.openPayingChannel() : maker should open paying channel', async () => {

        // the XBR provider we use here
        const market_operator = alice;
        const maker = alice_market_maker1;
        const provider = bob;
        const delegate = bob_delegate1;

        // XBR market to join
        const marketId = utils.sha3("MyMarket1").substring(0, 34);
        const market = await network.markets(marketId);

        // console.log('MARKET OWNER', market_operator, market);

        // 50 XBR channel deposit
        const amount = '' + 50 * 10**18;
        const timeout = 100;

        if (true) {
            // transfer tokens to provider
            await token.transfer(maker, amount, {from: owner, gasLimit: gasLimit});

            // approve transfer of tokens to open paying channel
            await token.approve(network.address, amount, {from: maker, gasLimit: gasLimit});
        }

        // XBR consumer opens a payment channel in the market
        const txn = await network.openPayingChannel(marketId, provider, delegate, amount, timeout, {from: maker, gasLimit: gasLimit});
        //console.log('result1 txn', txn);
        //const result1 = txn.receipt.logs[0];
        //console.log('result1', result1);

        // check event logs
        assert.equal(txn.receipt.logs.length, 1, "event(s) we expected not emitted");
        const result2 = txn.receipt.logs[0];

        // check events
        assert.equal(result2.event, "ChannelCreated", "wrong event was emitted");

        // event ChannelCreated(bytes16 marketId, address sender, address delegate, address receiver, address channel)
        assert.equal(result2.args.marketId.substring(0, 34), marketId, "wrong marketId in event");
        assert.equal(result2.args.sender, maker, "wrong sender address in event");
        assert.equal(result2.args.delegate, delegate, "wrong delegate address in event");
        assert.equal(result2.args.recipient, provider, "wrong recipient address in event");
        //assert.equal(result2.args.channel, channel, "wrong channel address in event");
        assert.equal(result2.args.channelType, 2, "wrong channelType in event");

        const channel = await XBRChannel.at(result2.args.channel);
        const _ctype = await channel.ctype();
        const _state = await channel.state();
        const _marketId = await channel.marketId();
        const _sender = await channel.sender();
        const _delegate = await channel.delegate();
        const _recipient = await channel.recipient();
        const _amount = await channel.amount();
        const _timeout = await channel.timeout();
        const _openedAt = await channel.openedAt();
        const _closedAt = await channel.closedAt();

        console.log('CHANNEL_address', result2.args.channel);
        console.log('CHANNEL_ctype', _ctype.toNumber());
        console.log('CHANNEL_state', _state.toNumber());
        console.log('CHANNEL_marketId', _marketId);
        console.log('CHANNEL_sender', _sender);
        console.log('CHANNEL_delegate', _delegate);
        console.log('CHANNEL_recipient', _recipient);
        console.log('CHANNEL_amount', '' + _amount);
        console.log('CHANNEL_timeout', _timeout.toNumber());
        console.log('CHANNEL_openedAt', _openedAt.toNumber());
        console.log('CHANNEL_closedAt', _closedAt.toNumber());
    });

    it('XBRChannel.close() : consumer should close payment channel', async () => {

        const market_operator = alice;

        const marketmaker = w3_utils.toChecksumAddress('0x22d491bde2303f2f43325b2108d26f1eaba1e32b');
        const marketmaker_key = '0x6370fd033278c143179d81c5526140625662b8daa446c22ee2d73db3707e620c';

        // Charlie
        const consumer = '0x95ced938f7991cd0dfcb48f0a06a40fa1af46ebc';
        const consumer_key = '0x395df67f0c2d2d9fe1ad08d1bc8b6627011959b79c53d7dd6a3536a33ab8a4fd';

        // Bob
        const provider = '0xe11ba2b4d45eaed5996cd0823791e0c93114882d';
        const provider_key = null;

        // Charlies buyer delegate
        const delegate = w3_utils.toChecksumAddress('0x3e5e9111ae8eb78fe1cc3bb8915d5d461f3ef9a9');
        const delegate_key = '0xe485d098507f54e7733a205420dfddbe58db035fa577fc294ebd14db90767a52';

        // XBR market to join
        const marketId = utils.sha3("MyMarket1").substring(0, 34);
        const market = await network.markets(marketId);

        // 50 XBR channel deposit
        const amount = '' + 50 * 10**18;
        const timeout = 100;

        // transfer tokens to consumer
        await token.transfer(consumer, amount, {from: owner, gasLimit: gasLimit});

        // approve transfer of tokens to open payment channel
        await token.approve(network.address, amount, {from: consumer, gasLimit: gasLimit});

        // XBR consumer opens a payment channel in the market
        const txn = await network.openPaymentChannel(marketId, market.owner, delegate,
            amount, timeout, {from: consumer, gasLimit: gasLimit});
        const channel_adr = txn.receipt.logs[0].args.channel;
        const channel = await XBRChannel.at(channel_adr);
        console.log('CHANNEL', channel_adr);

        const network_balance_before = '' + (await token.balanceOf(await network.organization()));
        const channel_balance_before = '' + (await token.balanceOf(channel_adr));
        const market_balance_before = '' + (await token.balanceOf(market_operator));
        const maker_balance_before = '' + (await token.balanceOf(marketmaker));
        const provider_balance_before = '' + (await token.balanceOf(provider));
        const consumer_balance_before = '' + (await token.balanceOf(consumer));
        const consumer_delegate_balance_before = '' + (await token.balanceOf(delegate));

        const msg = {
            'channel_adr': channel_adr,
            'channel_seq': 117,
            'balance': 13,
        }
        console.log('MESSAGE', msg);

        const delegate_sig = create_sig(delegate_key, msg);
        console.log('DELEGATE_SIG', delegate_sig);

        const marketmaker_sig = create_sig(marketmaker_key, msg);
        console.log('MARKETMAKER_SIG', marketmaker_sig);

        res = await channel.verifyClose(delegate, msg['channel_adr'], msg['channel_seq'], msg['balance'], delegate_sig);
        assert.equal(res, true, "close verification by delegate should succeed");

        res = await channel.verifyClose(marketmaker, msg['channel_adr'], msg['channel_seq'], msg['balance'], marketmaker_sig);
        assert.equal(res, true, "close verification by market maker should succeed");

        await channel.close(msg['channel_seq'], msg['balance'], delegate_sig, marketmaker_sig,
            {from: consumer, gasLimit: gasLimit});

        const network_balance_after = '' + (await token.balanceOf(await network.organization()));
        const channel_balance_after = '' + (await token.balanceOf(channel_adr));
        const market_balance_after = '' + (await token.balanceOf(market_operator));
        const maker_balance_after = '' + (await token.balanceOf(marketmaker));
        const provider_balance_after = '' + (await token.balanceOf(provider));
        const consumer_balance_after = '' + (await token.balanceOf(consumer));
        const consumer_delegate_balance_after = '' + (await token.balanceOf(delegate));

        console.log('--------------------------------------------')
        console.log('NETWORK_BALANCE', network_balance_before, network_balance_after);
        console.log('MARKET_BALANCE', market_balance_before, market_balance_after);
        console.log('MAKER_BALANCE', maker_balance_before, maker_balance_after);
        console.log('CHANNEL_BALANCE', channel_balance_before, channel_balance_after);
        console.log('PROVIDER_BALANCE', provider_balance_before, provider_balance_after);
        console.log('CONSUMER_BALANCE', consumer_balance_before, consumer_balance_after);
        console.log('CONSUMER_DELEGATE_BALANCE', consumer_delegate_balance_before, consumer_delegate_balance_after);
        console.log('--------------------------------------------')

        const _ctype = await channel.ctype();
        const _state = await channel.state();
        const _marketId = await channel.marketId();
        const _sender = await channel.sender();
        const _delegate = await channel.delegate();
        const _recipient = await channel.recipient();
        const _amount = await channel.amount();
        const _timeout = await channel.timeout();
        const _openedAt = await channel.openedAt();
        const _closedAt = await channel.closedAt();

        console.log('CHANNEL_address', channel_adr);
        console.log('CHANNEL_ctype', _ctype.toNumber());
        console.log('CHANNEL_state', _state.toNumber());
        console.log('CHANNEL_marketId', _marketId);
        console.log('CHANNEL_sender', _sender);
        console.log('CHANNEL_delegate', _delegate);
        console.log('CHANNEL_recipient', _recipient);
        console.log('CHANNEL_amount', '' + _amount);
        console.log('CHANNEL_timeout', _timeout.toNumber());
        console.log('CHANNEL_openedAt', _openedAt.toNumber());
        console.log('CHANNEL_closedAt', _closedAt.toNumber());
    });

    it('XBRChannel.close() : maker should close paying channel', async () => {

        /*
        const market_operator = alice;
        const marketmaker = alice_market_maker1;
        const marketmaker_key = alice_market_maker1_key;
        const consumer = charlie;
        const provider = bob;
        const delegate = bob_delegate1;
        const delegate_key = bob_delegate1_key
        */

       const market_operator = alice;

       const marketmaker = w3_utils.toChecksumAddress('0x22d491bde2303f2f43325b2108d26f1eaba1e32b');
       const marketmaker_key = '0x6370fd033278c143179d81c5526140625662b8daa446c22ee2d73db3707e620c';

       // Charlie
       const consumer = '0x95ced938f7991cd0dfcb48f0a06a40fa1af46ebc';
       const consumer_key = '0x395df67f0c2d2d9fe1ad08d1bc8b6627011959b79c53d7dd6a3536a33ab8a4fd';

       // Bob
       const provider = '0xe11ba2b4d45eaed5996cd0823791e0c93114882d';
       const provider_key = null;

       // Bobs seller delegate
       const delegate = w3_utils.toChecksumAddress('0xe11ba2b4d45eaed5996cd0823791e0c93114882d');
       const delegate_key = '0x646f1ce2fdad0e6deeeb5c7e8e5543bdde65e86029e2fd9fc169899c440a7913';

        // XBR market to join
        const marketId = utils.sha3("MyMarket1").substring(0, 34);
        const market = await network.markets(marketId);

        // console.log('MARKET OWNER', market_operator, market);

        // 50 XBR channel deposit
        const amount = '' + 50 * 10**18;
        const timeout = 100;

        // transfer tokens to provider
        await token.transfer(marketmaker, amount, {from: owner, gasLimit: gasLimit});

        // approve transfer of tokens to open paying channel
        await token.approve(network.address, amount, {from: marketmaker, gasLimit: gasLimit});

        // XBR market maker opens paying channel in the market
        const txn = await network.openPayingChannel(marketId, provider, delegate,
            amount, timeout, {from: marketmaker, gasLimit: gasLimit});
        const channel_adr = txn.receipt.logs[0].args.channel;
        const channel = await XBRChannel.at(channel_adr);
        console.log('CHANNEL', channel_adr);

        const network_balance_before = '' + (await token.balanceOf(await network.organization()));
        const channel_balance_before = '' + (await token.balanceOf(channel_adr));
        const market_balance_before = '' + (await token.balanceOf(market_operator));
        const maker_balance_before = '' + (await token.balanceOf(marketmaker));
        const provider_balance_before = '' + (await token.balanceOf(provider));
        const consumer_balance_before = '' + (await token.balanceOf(consumer));
        const consumer_delegate_balance_before = '' + (await token.balanceOf(delegate));

        const channel_delegate = await channel.delegate();
        assert.equal(delegate, w3_utils.toChecksumAddress(channel_delegate), "channel should match delegate");

        const channel_marketmaker = await channel.marketmaker();
        assert.equal(marketmaker, w3_utils.toChecksumAddress(channel_marketmaker), "channel should match market maker");

        const msg = {
            'channel_adr': channel_adr,
            'channel_seq': 117,
            'balance': 13,
        }
        console.log('MESSAGE', msg);

        const delegate_sig = create_sig(delegate_key, msg);
        console.log('DELEGATE_SIG', delegate_sig);

        const marketmaker_sig = create_sig(marketmaker_key, msg);
        console.log('MARKETMAKER_SIG', marketmaker_sig);

        res = await channel.verifyClose(delegate, msg['channel_adr'], msg['channel_seq'], msg['balance'], delegate_sig);
        assert.equal(res, true, "close verification by delegate should succeed");

        res = await channel.verifyClose(marketmaker, msg['channel_adr'], msg['channel_seq'], msg['balance'], marketmaker_sig);
        assert.equal(res, true, "close verification by market maker should succeed");

        await channel.close(msg['channel_seq'], msg['balance'], delegate_sig, marketmaker_sig,
            {from: marketmaker, gasLimit: gasLimit});

        const network_balance_after = '' + (await token.balanceOf(await network.organization()));
        const channel_balance_after = '' + (await token.balanceOf(channel_adr));
        const market_balance_after = '' + (await token.balanceOf(market_operator));
        const maker_balance_after = '' + (await token.balanceOf(marketmaker));
        const provider_balance_after = '' + (await token.balanceOf(provider));
        const consumer_balance_after = '' + (await token.balanceOf(consumer));
        const consumer_delegate_balance_after = '' + (await token.balanceOf(delegate));

        console.log('--------------------------------------------')
        console.log('NETWORK_BALANCE', network_balance_before, network_balance_after);
        console.log('MARKET_BALANCE', market_balance_before, market_balance_after);
        console.log('MAKER_BALANCE', maker_balance_before, maker_balance_after);
        console.log('CHANNEL_BALANCE', channel_balance_before, channel_balance_after);
        console.log('PROVIDER_BALANCE', provider_balance_before, provider_balance_after);
        console.log('CONSUMER_BALANCE', consumer_balance_before, consumer_balance_after);
        console.log('CONSUMER_DELEGATE_BALANCE', consumer_delegate_balance_before, consumer_delegate_balance_after);
        console.log('--------------------------------------------')

        const _ctype = await channel.ctype();
        const _state = await channel.state();
        const _marketId = await channel.marketId();
        const _sender = await channel.sender();
        const _delegate = await channel.delegate();
        const _recipient = await channel.recipient();
        const _amount = await channel.amount();
        const _timeout = await channel.timeout();
        const _openedAt = await channel.openedAt();
        const _closedAt = await channel.closedAt();

        console.log('CHANNEL_address', channel_adr);
        console.log('CHANNEL_ctype', _ctype.toNumber());
        console.log('CHANNEL_state', _state.toNumber());
        console.log('CHANNEL_marketId', _marketId);
        console.log('CHANNEL_sender', _sender);
        console.log('CHANNEL_delegate', _delegate);
        console.log('CHANNEL_recipient', _recipient);
        console.log('CHANNEL_amount', '' + _amount);
        console.log('CHANNEL_timeout', _timeout.toNumber());
        console.log('CHANNEL_openedAt', _openedAt.toNumber());
        console.log('CHANNEL_closedAt', _closedAt.toNumber());
    });
});
