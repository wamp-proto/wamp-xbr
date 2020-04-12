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

const utils = require("./utils.js");
const eth_sig_utils = require("eth-sig-util");
const eth_util = require("ethereumjs-util");

const XBRNetwork = artifacts.require("./XBRNetwork.sol");
const XBRToken = artifacts.require("./XBRToken.sol");
const XBRMarket = artifacts.require("./XBRMarket.sol");
const XBRChannel = artifacts.require("./XBRChannel.sol");


const EIP712ChannelOpen = {
    types: {
        EIP712Domain: [
            { name: 'name', type: 'string' },
            { name: 'version', type: 'string' },
        ],
        EIP712ChannelOpen: [
            {name: 'chainId', type: 'uint256'},
            {name: 'verifyingContract', type: 'address'},
            {name: 'ctype', type: 'uint8'},
            {name: 'openedAt', type: 'uint256'},
            {name: 'marketId', type: 'bytes16'},
            {name: 'channelId', type: 'bytes16'},
            {name: 'actor', type: 'address'},
            {name: 'delegate', type: 'address'},
            {name: 'marketmaker', type: 'address'},
            {name: 'recipient', type: 'address'},
            {name: 'amount', type: 'uint256'}
        ]
    },
    primaryType: 'EIP712ChannelOpen',
    domain: {
        name: 'XBR',
        version: '1',
    },
    message: null
};


function create_sig_open_channel(key_, data_) {
    EIP712ChannelOpen['message'] = data_;
    const key = eth_util.toBuffer(key_);
    const sig = eth_sig_utils.signTypedData(key, {data: EIP712ChannelOpen})
    return sig;
}


const EIP712ChannelClose = {
    types: {
        EIP712Domain: [
            { name: 'name', type: 'string' },
            { name: 'version', type: 'string' },
        ],
        EIP712ChannelClose: [
            {name: 'chainId', type: 'uint256'},
            {name: 'verifyingContract', type: 'address'},
            {name: 'closeAt', type: 'uint256'},            
            {name: 'marketId', type: 'bytes16'},
            {name: 'channelId', type: 'bytes16'},
            {name: 'channelSeq', type: 'uint32'},
            {name: 'balance', type: 'uint256'},
            {name: 'isFinal', type: 'bool'}
        ]
    },
    primaryType: 'EIP712ChannelClose',
    domain: {
        name: 'XBR',
        version: '1',
    },
    message: null,
};


function create_sig_close_channel(key_, data_) {
    EIP712ChannelClose['message'] = data_;
    const key = eth_util.toBuffer(key_);
    const sig = eth_sig_utils.signTypedData(key, {data: EIP712ChannelClose})
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

    // deployed instance of XBRChannel
    var channel;

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

    // enum ActorType { NULL, NETWORK, MARKET, PROVIDER, CONSUMER }
    const ActorType_NULL = 0;
    const ActorType_PROVIDER = 1;
    const ActorType_CONSUMER = 2;

    // enum NodeType { NULL, MASTER, CORE, EDGE }
    const NodeType_NULL = 0;
    const NodeType_MASTER = 1;
    const NodeType_CORE = 2;
    const NodeType_EDGE = 3;

    const marketId = utils.sha3("MyMarket1").substring(0, 34);

    // 100 XBR security
    // const providerSecurity = '' + 100 * 10**18;
    // const consumerSecurity = '' + 100 * 10**18;

    // FIXME: non-zero security breaks "joinMarketFor" test
    const providerSecurity = 0;
    const consumerSecurity = 0;

    //
    // test accounts setup
    //
    const owner = accounts[0];

    const alice = accounts[1];
    const alice_key = '0x6cbed15c793ce57650b9877cf6fa156fbef513c4e6134f022a85b1ffdd59b2a1';
    const alice_market_maker1 = accounts[2];
    const alice_market_maker1_key = '0x6370fd033278c143179d81c5526140625662b8daa446c22ee2d73db3707e620c';

    const bob = accounts[3];
    const bob_key = '0x646f1ce2fdad0e6deeeb5c7e8e5543bdde65e86029e2fd9fc169899c440a7913';
    const bob_delegate1 = accounts[4];
    const bob_delegate1_key = '0xadd53f9a7e588d003326d1cbf9e4a43c061aadd9bc938c843a79e7b4fd2ad743';

    const charlie = accounts[5];
    const charlie_key = '0x395df67f0c2d2d9fe1ad08d1bc8b6627011959b79c53d7dd6a3536a33ab8a4fd';
    const charlie_delegate1 = accounts[6];
    const charlie_delegate1_key = '0xe485d098507f54e7733a205420dfddbe58db035fa577fc294ebd14db90767a52';

    const donald = accounts[7];
    const donald_delegate1 = accounts[8];
    const edith = accounts[9];
    const edith_delegate1 = accounts[10];
    const frank = accounts[11];
    const frank_delegate1 = accounts[12];

    beforeEach('setup contract for each test', async function () {
        network = await XBRNetwork.deployed();
        token = await XBRToken.deployed();
        market = await XBRMarket.deployed();
        channel = await XBRChannel.deployed();

        console.log('Using XBRToken           : ' + token.address);
        console.log('Using XBRNetwork         : ' + network.address);
        console.log('Using XBRMarket          : ' + market.address);
        console.log('Using XBRChannel         : ' + channel.address);

        // FIXME: none of the following works on Ganache v6.9.1 ..

        // TypeError: Cannot read property 'getChainId' of undefined
        // https://web3js.readthedocs.io/en/v1.2.6/web3-eth.html#getchainid
        // const _chainId1 = await web3.eth.getChainId();

        // DEBUG: _chainId2 undefined
        // const _chainId2 = web3.version.network;
        // console.log('DEBUG: _chainId2', _chainId2);

        chainId = await network.verifyingChain();
        verifyingContract = await network.verifyingContract();

        console.log('Using chainId            : ' + chainId);
        console.log('Using verifyingContract  : ' + verifyingContract);

        const eula = "QmV1eeDextSdUrRUQp9tUXF8SdvVeykaiwYLgrXHHVyULY";
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

        const marketId = utils.sha3("MyMarket1").substring(0, 34);
        const market_ = await market.markets(marketId);

        if (market_.created.toNumber() == 0) {
            /////////// market operator and market maker
            const operator = alice;
            const maker = alice_market_maker1;

            const terms = "";
            const meta = "";

            // 5% market fee
            // FIXME: how to write a large uint256 literal?
            // const marketFee = '' + Math.trunc(0.05 * 10**9 * 10**18);
            const marketFee = 0;

            await market.createMarket(marketId, token.address, terms, meta, maker, providerSecurity, consumerSecurity, marketFee, {from: operator, gasLimit: gasLimit});

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
            await market.joinMarket(marketId, ActorType_PROVIDER, meta, {from: provider, gasLimit: gasLimit});

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
            await market.joinMarket(marketId, ActorType_CONSUMER, meta, {from: consumer, gasLimit: gasLimit});
        }
    });

    it('XBRChannel.openChannel(ctype==PAYMENT) : consumer should open payment channel', async () => {

        // remember token amount the XBRChannel contract has BEFORE opening the channel
        const token_before = await token.balanceOf(channel.address);
        console.log('XBRChannel token balance before: ' + token_before);

        // the XBR consumer we use here
        const actor = charlie;
        const actor_key = charlie_key;

        // consumer (buyer) delegate address
        const delegate = charlie_delegate1;

        // market and channel OID
        const marketId = utils.sha3("MyMarket1").substring(0, 34);
        const channelId = utils.sha3("MyChannel1").substring(0, 34);

        // get the market object, so we can access market maker address etc
        const market_ = await market.markets(marketId);
        const marketmaker = market_.maker;

        // XBR market operator of the market we open a channel within
        const recipient = market_.owner;
        // const recipient = alice;

        // 50 XBR channel deposit
        const amount = '' + 50 * 10**18;

        // channel is a payment channel
        const ctype = 1;

        // current block number
        const openedAt = await web3.eth.getBlockNumber();

        // create signature over channel open data
        const msg = {
            'chainId': chainId,
            'verifyingContract': verifyingContract,
            'ctype': ctype,
            'openedAt': openedAt,
            'marketId': marketId,
            'channelId': channelId,
            'actor': actor,
            'delegate': delegate,
            'marketmaker': marketmaker,
            'recipient': recipient,
            'amount': amount,
        };

        // **as consumer**: sign the data, this must be signed with the private key of
        // the actor in the channel (that is the consumer in case)
        const signature = create_sig_open_channel(actor_key, msg);

        // **as owner**: transfer tokens to consumer
        await token.transfer(actor, amount, {from: owner, gasLimit: gasLimit});

        // **as consumer**: approve transfer of tokens to open payment channel
        await token.approve(channel.address, amount, {from: actor, gasLimit: gasLimit});

        // **as market maker**: actually open the channel ..
        const txn = await channel.openChannel(ctype, openedAt, marketId, channelId,
            actor, delegate, marketmaker, recipient, amount, signature,
            {from: marketmaker, gasLimit: gasLimit}
        );

        // check that the correct number of events was emitted (namely 1)
        assert.equal(txn.receipt.logs.length, 1, "event(s) we expected not emitted");

        // get the transaction results first event: XBRChannel.Opened
        const result = txn.receipt.logs[0];
        assert.equal(result.event, "Opened", "wrong event was emitted");

        // check all event attributes
        const eargs = result.args;
        assert.equal(eargs.ctype, ctype, "wrong ctype in event");
        assert.equal(eargs.marketId.substring(0, 34), marketId, "wrong marketId in event");
        assert.equal(eargs.channelId.substring(0, 34), channelId, "wrong channelId in event");
        assert.equal(eargs.actor, actor, "wrong actor in event");
        assert.equal(eargs.delegate, delegate, "wrong delegate in event");
        assert.equal(eargs.marketmaker, market_.maker, "wrong marketmaker in event");
        assert.equal(eargs.recipient, recipient, "wrong recipient in event");
        assert.equal(eargs.amount, amount, "wrong amount in event");
        assert.equal(eargs.signature, signature, "wrong signature in event");

        // remember token amount the XBRChannel contract has AFTER opening the channel
        const token_after = await token.balanceOf(channel.address);
        console.log('XBRChannel token balance after : ' + token_after);

        // the difference AFTER - BEFORE must exactly equal the AMOUNT we opened the channel with
        assert.equal(token_after - token_before, amount, "wrong token amount transfered");
    });

    it('XBRChannel.openChannel(ctype==PAYING) : provider should open paying channel', async () => {

        // remember token amount the XBRChannel contract has BEFORE opening the channel
        const token_before = await token.balanceOf(channel.address);
        console.log('XBRChannel token balance before: ' + token_before);

        // the XBR provider we use here
        const actor = bob;
        const actor_key = bob_key;

        const recipient = actor;

        // provider (seller) delegate address
        const delegate = bob_delegate1;

        // market and channel OID
        const marketId = utils.sha3("MyMarket1").substring(0, 34);
        const channelId = utils.sha3("MyChannel2").substring(0, 34);

        // get the market object, so we can access market maker address etc
        const market_ = await market.markets(marketId);
        const marketmaker = market_.maker;
        // 50 XBR channel deposit
        const amount = '' + 50 * 10**18;

        // channel is a paying channel
        const ctype = 2;

        // current block number
        const openedAt = await web3.eth.getBlockNumber();

        // create signature over channel open data
        const msg = {
            'chainId': chainId,
            'verifyingContract': verifyingContract,
            'ctype': ctype,
            'openedAt': openedAt,
            'marketId': marketId,
            'channelId': channelId,
            'actor': actor,
            'delegate': delegate,
            'marketmaker': marketmaker,
            'recipient': recipient,
            'amount': amount,
        };

        // **as provider**: sign the data, this must be signed with the private key of
        // the actor in the channel (that is the provider in case)
        const signature = create_sig_open_channel(actor_key, msg);

        // **as owner**: transfer tokens to provider
        await token.transfer(marketmaker, amount, {from: owner, gasLimit: gasLimit});

        // **as market maker**: approve transfer of tokens to open payment channel
        await token.approve(channel.address, amount, {from: marketmaker, gasLimit: gasLimit});

        // **as market maker**: actually open the channel ..
        const txn = await channel.openChannel(ctype, openedAt, marketId, channelId,
            actor, delegate, marketmaker, recipient, amount, signature,
            {from: marketmaker, gasLimit: gasLimit}
        );

        // check that the correct number of events was emitted (namely 1)
        assert.equal(txn.receipt.logs.length, 1, "event(s) we expected not emitted");

        // get the transaction results first event: XBRChannel.Opened
        const result = txn.receipt.logs[0];
        assert.equal(result.event, "Opened", "wrong event was emitted");

        // check all event attributes
        const eargs = result.args;
        assert.equal(eargs.ctype, ctype, "wrong ctype in event");
        assert.equal(eargs.marketId.substring(0, 34), marketId, "wrong marketId in event");
        assert.equal(eargs.channelId.substring(0, 34), channelId, "wrong channelId in event");
        assert.equal(eargs.actor, actor, "wrong actor in event");
        assert.equal(eargs.delegate, delegate, "wrong delegate in event");
        assert.equal(eargs.marketmaker, market_.maker, "wrong marketmaker in event");
        assert.equal(eargs.recipient, recipient, "wrong recipient in event");
        assert.equal(eargs.amount, amount, "wrong amount in event");
        assert.equal(eargs.signature, signature, "wrong signature in event");

        // remember token amount the XBRChannel contract has AFTER opening the channel
        const token_after = await token.balanceOf(channel.address);
        console.log('XBRChannel token balance after : ' + token_after);

        // the difference AFTER - BEFORE must exactly equal the AMOUNT we opened the channel with
        assert.equal(token_after - token_before, amount, "wrong token amount transfered");
    });

    it('XBRChannel.closeChannel(ctype==PAYMENT) : consumer should close payment channel', async () => {
        // remember token amount the XBRChannel contract has BEFORE closing the channel
        const token_before = await token.balanceOf(channel.address);

        // the XBR consumer we use here
        const actor = charlie;
        const actor_key = charlie_key;
        const actor_token_before = await token.balanceOf(actor);

        // consumer (buyer) delegate address
        const delegate = charlie_delegate1;
        const delegate_key = charlie_delegate1_key;

        // market and channel OID
        const marketId = utils.sha3("MyMarket1").substring(0, 34);
        const channelId = utils.sha3("MyChannel1").substring(0, 34);

        // get the market object, so we can access market maker address etc
        const market_ = await market.markets(marketId);
        const marketmaker = market_.maker;
        const mm_token_before = await token.balanceOf(marketmaker);

        assert.equal(alice_market_maker1, marketmaker, "unexpected market maker");
        const marketmaker_key = alice_market_maker1_key;

        // current block number
        const closeAt = await web3.eth.getBlockNumber();

        // 50 XBR channel deposit
        const channelSeq = 1;
        const balance = '' + 50 * 10**18;
        const isFinal = true;

        // create signature over channel open data
        const msg = {
            'chainId': chainId,
            'verifyingContract': verifyingContract,
            'closeAt': closeAt,
            'marketId': marketId,
            'channelId': channelId,
            'channelSeq': channelSeq,
            'balance': balance,
            'isFinal': isFinal
        };

        // **as delegate & market maker**: sign the data, this must be signed with
        // the private key of the actor in the channel (that is the consumer in case)
        const delegateSignature = create_sig_close_channel(delegate_key, msg);
        const marketmakerSignature = create_sig_close_channel(marketmaker_key, msg);

        // **as market maker**: actually close the channel ..
        const txn = await channel.closeChannel(channelId, closeAt, channelSeq, balance, isFinal,
            delegateSignature, marketmakerSignature, {from: marketmaker, gasLimit: gasLimit}
        );
        // console.log(txn.receipt.logs);

        // check that the correct number of events was emitted (namely 1)
        assert.equal(txn.receipt.logs.length, 2, "event(s) we expected not emitted");

        // get the transaction results first event: XBRChannel.Closing
        const result1 = txn.receipt.logs[0];
        assert.equal(result1.event, "Closing", "wrong event was emitted");

        // check all event attributes
        const eargs1 = result1.args;

        // get the transaction results first event: XBRChannel.Closed
        const result2 = txn.receipt.logs[1];
        assert.equal(result2.event, "Closed", "wrong event was emitted");

        // check all event attributes
        const eargs2 = result2.args;

        // remember token amount the XBRChannel contract has AFTER opening the channel
        const token_after = await token.balanceOf(channel.address);
        const actor_token_after = await token.balanceOf(actor);
        const mm_token_after = await token.balanceOf(marketmaker);

        console.log('XBRChannel token balance of channel before : ' + token_before / 10**18);
        console.log('XBRChannel token balance of channel after  : ' + token_after / 10**18);
        console.log('XBRChannel token balance of actor before   : ' + actor_token_before / 10**18);
        console.log('XBRChannel token balance of actor after    : ' + actor_token_after / 10**18);
        console.log('XBRChannel token balance of market maker before : ' + mm_token_before / 10**18);
        console.log('XBRChannel token balance of market maker after  : ' + mm_token_after / 10**18);

        // the difference BEFORE - AFTER must exactly equal the AMOUNT the channel was opened with
        assert.equal(token_before - token_after, balance, "wrong token amount transfered");
        assert.equal(actor_token_after - actor_token_before, balance, "tokens not refunded to actor");        
        assert.equal(mm_token_after - mm_token_before, 0, "tokens refunded to market maker");
    });

    it('XBRChannel.closeChannel(ctype==PAYING) : market maker should close paying channel', async () => {
        // remember token amount the XBRChannel contract has BEFORE closing the channel
        const token_before = await token.balanceOf(channel.address);

        const actor = bob;
        const actor_key = bob_key;
        const actor_token_before = await token.balanceOf(actor);

        // the XBR provider we use here
        const marketmaker = alice_market_maker1;
        const marketmaker_key = alice_market_maker1_key;

        const mm_token_before = await token.balanceOf(marketmaker);

        // provider (seller) delegate address
        const delegate = bob_delegate1;
        const delegate_key = bob_delegate1_key;

        // market and channel OID
        const marketId = utils.sha3("MyMarket1").substring(0, 34);
        const channelId = utils.sha3("MyChannel2").substring(0, 34);

        // get the market object, so we can access market maker address etc
        const market_ = await market.markets(marketId);
        assert.equal(market_.maker, marketmaker, "unexpected market maker");

        // current block number
        const closeAt = await web3.eth.getBlockNumber();

        // 50 XBR channel deposit
        const channelSeq = 1;
        const balance = '' + 50 * 10**18;
        const isFinal = true;

        // create signature over channel open data
        const msg = {
            'chainId': chainId,
            'verifyingContract': verifyingContract,
            'closeAt': closeAt,
            'marketId': marketId,
            'channelId': channelId,
            'channelSeq': channelSeq,
            'balance': balance,
            'isFinal': isFinal
        };

        // **as delegate & market maker**: sign the data, this must be signed with
        // the private key of the actor in the channel (that is the consumer in case)
        const delegateSignature = create_sig_close_channel(delegate_key, msg);
        const marketmakerSignature = create_sig_close_channel(marketmaker_key, msg);

        // **as market maker**: actually close the channel ..
        const txn = await channel.closeChannel(channelId, closeAt, channelSeq, balance, isFinal,
            delegateSignature, marketmakerSignature, {from: marketmaker, gasLimit: gasLimit}
        );
        // console.log(txn.receipt.logs);

        // check that the correct number of events was emitted (namely 1)
        assert.equal(txn.receipt.logs.length, 2, "event(s) we expected not emitted");

        // get the transaction results first event: XBRChannel.Closing
        const result1 = txn.receipt.logs[0];
        assert.equal(result1.event, "Closing", "wrong event was emitted");

        // check all event attributes
        const eargs1 = result1.args;

        // get the transaction results first event: XBRChannel.Closed
        const result2 = txn.receipt.logs[1];
        assert.equal(result2.event, "Closed", "wrong event was emitted");

        // check all event attributes
        const eargs2 = result2.args;

        // remember token amount the XBRChannel contract has AFTER opening the channel
        const token_after = await token.balanceOf(channel.address);
        const actor_token_after = await token.balanceOf(actor);
        const mm_token_after = await token.balanceOf(marketmaker);

        console.log('XBRChannel token balance of channel before : ' + token_before / 10**18);
        console.log('XBRChannel token balance of channel after  : ' + token_after / 10**18);
        console.log('XBRChannel token balance of actor before   : ' + actor_token_before / 10**18);
        console.log('XBRChannel token balance of actor after    : ' + actor_token_after / 10**18);
        console.log('XBRChannel token balance of market maker before : ' + mm_token_before / 10**18);
        console.log('XBRChannel token balance of market maker after  : ' + mm_token_after / 10**18);

        // the difference BEFORE - AFTER must exactly equal the AMOUNT the channel was opened with
        assert.equal(token_before - token_after, balance, "wrong token amount transfered");
        assert.equal(actor_token_after - actor_token_before, 0, "tokens paid out to actor");
        assert.equal(mm_token_after - mm_token_before, balance, "tokens not refunded to market maker");
    });
});
