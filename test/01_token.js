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

const BN = web3.utils.BN;
const XBRToken = artifacts.require("./XBRToken.sol");


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

        await token.transfer(accounts[1], amount, {from: accounts[0], gasLimit: gasLimit});

        const acct0_after = await token.balanceOf(accounts[0]);
        const acct1_after = await token.balanceOf(accounts[1]);

        assert(amount.eq(acct0_before.sub(acct0_after)), "invalid balance for account[0] after transaction");
        assert(amount.eq(acct1_after.sub(acct1_before)), "invalid balance for account[1] after transaction");
    });
});
