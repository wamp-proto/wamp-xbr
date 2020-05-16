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

const w3_utils = require("web3-utils");
const eth_sig_utils = require("eth-sig-util");
const eth_util = require("ethereumjs-util");

const BN = web3.utils.BN;
const XBRToken = artifacts.require("./XBRToken.sol");


const eip712ApprovalTypedData = {
    types: {
        EIP712Domain: [
            { name: 'name', type: 'string' },
            { name: 'version', type: 'string' },
            { name: 'chainId', type: 'uint256' },
            { name: 'verifyingContract', type: 'address' },
        ],
        EIP712Approve: [
            {name: 'sender', type: 'address'},
            {name: 'relayer', type: 'address'},
            {name: 'spender', type: 'address'},
            {name: 'amount', type: 'uint256'},
            {name: 'expires', type: 'uint256'},
            {name: 'nonce', type: 'uint256'},
        ]
    },
    primaryType: 'EIP712Approve',
    domain: {
        name: 'XBRToken',
        version: '1',
        chainId: 1,
        verifyingContract: null,
    },
    message: null
};


function eip712_sign_approval(key_, data_, verifyingContract) {
    eip712ApprovalTypedData['message'] = data_;
    eip712ApprovalTypedData['domain']['verifyingContract'] = verifyingContract;
    var key = eth_util.toBuffer(key_);
    var sig = eth_sig_utils.signTypedData(key, {data: eip712ApprovalTypedData})
    return sig;
}


contract('XBRToken', function (accounts) {

    //const gasLimit = 6721975;
    const gasLimit = 0xfffffffffff;
    //const gasLimit = 100000000;

    XBR_TOTAL_SUPPLY = 10**9 * 10**18;

    // deployed instance of XBRNetwork
    var token;

    beforeEach('setup contract for each test', async function () {
        token = await XBRToken.deployed();
    });

    it("XBRToken() : should have produced the right initial supply of XBRToken", async () => {
        const supply = await token.totalSupply();
        assert.equal(supply.valueOf(), XBR_TOTAL_SUPPLY, "Wrong initial/total supply for token");
    });

    it("XBRToken() : should initially put all XBRToken in the first account", async () => {
        const balance = await token.balanceOf(accounts[0]);
        assert.equal(balance.valueOf(), XBR_TOTAL_SUPPLY, "Initial supply wasn't allocated to the first account");
    });

    it("XBRToken.transfer() should correctly update token balances", async () => {
        // 1 million XBR
        const amount = new BN('100000000000000');

        const acct0_before = await token.balanceOf(accounts[0]);
        const acct1_before = await token.balanceOf(accounts[1]);

        // transfer the tokens (send tx from account[0]) in one go
        await token.transfer(accounts[1], amount, {from: accounts[0], gasLimit: gasLimit});

        const acct0_after = await token.balanceOf(accounts[0]);
        const acct1_after = await token.balanceOf(accounts[1]);

        assert(amount.eq(acct0_before.sub(acct0_after)), "invalid balance for account[0] after transaction");
        assert(amount.eq(acct1_after.sub(acct1_before)), "invalid balance for account[1] after transaction");
    });

    it("XBRToken.approve()+transferFrom() should correctly update token balances", async () => {
        // 1 million XBR
        const amount = new BN('100000000000000');

        const acct0_before = await token.balanceOf(accounts[0]);
        const acct1_before = await token.balanceOf(accounts[1]);

        // tx 1: approve transfer of tokens (send tx from account[0])
        await token.approve(accounts[1], amount, {from: accounts[0], gasLimit: gasLimit});

        // tx 2: actually transfer the tokens (send tx from account[1])
        await token.transferFrom(accounts[0], accounts[1], amount, {from: accounts[1], gasLimit: gasLimit});

        const acct0_after = await token.balanceOf(accounts[0]);
        const acct1_after = await token.balanceOf(accounts[1]);

        assert(amount.eq(acct0_before.sub(acct0_after)), "invalid balance for account[0] after transaction");
        assert(amount.eq(acct1_after.sub(acct1_before)), "invalid balance for account[1] after transaction");
    });

    it("XBRToken.approveFor()+transferFrom() should correctly update token balances", async () => {

        const chainId = 1;
        const verifyingContract = token.address;

        // const sender = accounts[0];
        const sender = w3_utils.toChecksumAddress('0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1');
        const sender_key = '0x4f3edf983ac636a65a842ce7c78d9aa706d3b113bce9c46f30d7d21715b23b1d';

        // const spender = accounts[1];
        const spender = w3_utils.toChecksumAddress('0xFFcf8FDEE72ac11b5c542428B35EEF5769C409f0');

        // const relayer = accounts[2];
        const relayer = w3_utils.toChecksumAddress('0x22d491Bde2303f2f43325b2108D26f1eAbA1e32b');

        // 1 million XBR
        const amount = new BN('100000000000000');
        const expires = 0;
        const nonce = 1;

        const sender_before = await token.balanceOf(sender);
        const spender_before = await token.balanceOf(spender);

        const approval = {
            'sender': sender,
            'relayer': relayer,
            'spender': spender,
            'amount': amount,
            'expires': expires,
            'nonce': nonce,
        }
        console.log('MESSAGE', approval);

        // prepare: pre-sign metatransaction
        // const signature = '0x0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000';
        const signature = eip712_sign_approval(sender_key, approval, verifyingContract);
        console.log('SIGNATURE', signature);

        // tx 1: submit pre-signed transaction approving transfer of tokens (send tx from relayer)
        await token.approveFor(sender, relayer, spender, amount, expires, nonce, signature, {from: relayer, gasLimit: gasLimit});

        // tx 2: actually transfer the tokens (send tx from spender)
        await token.transferFrom(sender, spender, amount, {from: spender, gasLimit: gasLimit});

        const sender_after = await token.balanceOf(sender);
        const spender_after = await token.balanceOf(spender);

        assert(amount.eq(sender_before.sub(sender_after)), "invalid balance for sender after transaction");
        assert(amount.eq(spender_after.sub(spender_before)), "invalid balance for spender after transaction");
    });
});
