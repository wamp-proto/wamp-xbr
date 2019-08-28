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

function create_sig(key_, message_) {

    const data = {
        'types': {
            'EIP712Domain': [
                {'name': 'name', 'type': 'string'},
                {'name': 'version', 'type': 'string'},
                {'name': 'chainId', 'type': 'uint256'},
                {'name': 'verifyingContract', 'type': 'address'},
            ],
            'Transaction': [
                // The channel address (cross-contract replay protection).
                {'name': 'channel', 'type': 'address'},

                // Channel transaction sequence number.
                {'name': 'channel_seq', 'type': 'uint32'},

                // Amount remaining in the payment/paying channel after the transaction.
                {'name': 'balance', 'type': 'uint256'},
            ],
        },
        'primaryType': 'Transaction',
        'domain': {
            'name': 'XBR',
            'version': '1',

            // test chain/network ID
            'chainId': 5777,

            // XBRNetwork contract address
            'verifyingContract': '0x254dffcd3277c0b1660f6d42efbb754edababc2b',
        },
        'message': message_
    }

    const key = eth_util.toBuffer(key_);

    if (false) {
        const message = eth_sig_utils.TypedDataUtils.sign(data, false);
        const sig = ethUtil.ecsign(message, key)
        return (sig.v, sig.r, sig.s)
    } else {
        const sig = eth_sig_utils.signTypedData(key, {data: data})
        return eth_util.toBuffer(sig);
    }
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
    const bob = accounts[3];
    const bob_delegate1 = accounts[4];
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

        // the XBR consumer we use here
        const market_operator = alice;
        const maker = alice_market_maker1;
        const provider = bob;
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
        const result2 = txn.receipt.logs[0];

        // bytes32 tx_pubkey, bytes16 tx_key_id, uint32 tx_channel_seq, uint256 tx_amount, uint256 tx_balance,
        // uint8 delegate_v, bytes32 delegate_r, bytes32 delegate_s,
        // uint8 marketmaker_v, bytes32 marketmaker_r, bytes32 marketmaker_s
        // await channel.close();

        const network_balance_before = '' + (await token.balanceOf(await network.organization()));
        const channel_balance_before = '' + (await token.balanceOf(result2.args.channel));
        const market_balance_before = '' + (await token.balanceOf(market_operator));
        const maker_balance_before = '' + (await token.balanceOf(maker));
        const provider_balance_before = '' + (await token.balanceOf(provider));
        const consumer_balance_before = '' + (await token.balanceOf(consumer));
        const consumer_delegate_balance_before = '' + (await token.balanceOf(delegate));

        const maker_key = '0x6370fd033278c143179d81c5526140625662b8daa446c22ee2d73db3707e620c';
        const consumer_key = '0x395df67f0c2d2d9fe1ad08d1bc8b6627011959b79c53d7dd6a3536a33ab8a4fd';
        const consumer_delegate_key = '0xe485d098507f54e7733a205420dfddbe58db035fa577fc294ebd14db90767a52';

        const msg = {
            'channel': result2.args.channel,
            'channel_seq': 1,
            'balance': 2000,
        }
        const delegate_sig = create_sig(consumer_delegate_key, msg);
        console.log('DELEGATE_SIG', delegate_sig);

        const marketmaker_sig = create_sig(maker_key, msg);
        console.log('MARKETMAKER_SIG', marketmaker_sig);

        const channel = await XBRChannel.at(result2.args.channel);
        await channel.close(msg['channel_seq'], msg['balance'], delegate_sig, marketmaker_sig,
            {from: consumer, gasLimit: gasLimit});

        const network_balance_after = '' + (await token.balanceOf(await network.organization()));
        const channel_balance_after = '' + (await token.balanceOf(result2.args.channel));
        const market_balance_after = '' + (await token.balanceOf(market_operator));
        const maker_balance_after = '' + (await token.balanceOf(maker));
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

    it('XBRChannel.close() : maker should close paying channel', async () => {

        // the XBR provider we use here
        const market_operator = alice;
        const maker = alice_market_maker1;
        const consumer = charlie;
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

        const network_balance_before = '' + (await token.balanceOf(await network.organization()));
        const market_balance_before = '' + (await token.balanceOf(market_operator));
        const maker_balance_before = '' + (await token.balanceOf(maker));
        const provider_balance_before = '' + (await token.balanceOf(provider));
        const consumer_balance_before = '' + (await token.balanceOf(consumer));
        const consumer_delegate_balance_before = '' + (await token.balanceOf(delegate));

        // XBR consumer opens a payment channel in the market
        const txn = await network.openPayingChannel(marketId, provider, delegate, amount, timeout, {from: maker, gasLimit: gasLimit});
        //console.log('result1 txn', txn);
        const result1 = txn.receipt.logs[0];
        //console.log('result1', result1);

        const channel_balance_before = '' + (await token.balanceOf(result1.args.channel));

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

        const maker_key = '0x6370fd033278c143179d81c5526140625662b8daa446c22ee2d73db3707e620c';
        const provider_key = '0x646f1ce2fdad0e6deeeb5c7e8e5543bdde65e86029e2fd9fc169899c440a7913';
        const provider_delegate_key = '0xadd53f9a7e588d003326d1cbf9e4a43c061aadd9bc938c843a79e7b4fd2ad743';

        const msg = {
            'channel': result2.args.channel,
            'channel_seq': 1,
            'balance': 2000,
        }
        const delegate_sig = create_sig(provider_delegate_key, msg);
        console.log('DELEGATE_SIG', delegate_sig);

        const marketmaker_sig = create_sig(maker_key, msg);
        console.log('MARKETMAKER_SIG', marketmaker_sig);

        const channel = await XBRChannel.at(result2.args.channel);
        await channel.close(msg['channel_seq'], msg['balance'], delegate_sig, marketmaker_sig,
            {from: maker, gasLimit: gasLimit});

        const network_balance_after = '' + (await token.balanceOf(await network.organization()));
        const channel_balance_after = '' + (await token.balanceOf(result2.args.channel));
        const market_balance_after = '' + (await token.balanceOf(market_operator));
        const maker_balance_after = '' + (await token.balanceOf(maker));
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
});
