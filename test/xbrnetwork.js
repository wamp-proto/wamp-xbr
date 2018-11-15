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

const XBRNetwork = artifacts.require("./XBRNetwork.sol");

contract('XBRNetwork', accounts => {

    const owner = accounts[0];

    const alice = accounts[1];
    const bob = accounts[2];
    const charlie = accounts[3];
    const donald = accounts[4];
    const edith = accounts[5];
    const frank = accounts[6];

    const alice_maker1 = accounts[7];

    it('owner account should be initially registered', async () => {
        const network = await XBRNetwork.deployed();

        const level = await network.getMemberLevel(owner);

        assert.equal(level.toNumber(), 2, "wrong member level");
    });

    it('non-owner accounts should be initially unregistered', async () => {
        const network = await XBRNetwork.deployed();

        var level = await network.getMemberLevel(alice);
        assert.equal(level.toNumber(), 0, "wrong member level");

        level = await network.getMemberLevel(bob);
        assert.equal(level.toNumber(), 0, "wrong member level");
    });

    it('should create new member, and with the correct member level', async () => {
        const network = await XBRNetwork.deployed();

        const eula = "QmU7Gizbre17x6V2VR1Q2GJEjz6m8S1bXmBtVxS2vmvb81";
        const profile = "QmQMtxYtLQkirCsVmc3YSTFQWXHkwcASMnu5msezGEwHLT";

        await network.register(eula, profile, {from: alice});
        var level = await network.getMemberLevel(alice);
        assert.equal(level.toNumber(), 1, "wrong member level");

        await network.register(eula, profile, {from: bob});
        var level = await network.getMemberLevel(bob);
        assert.equal(level.toNumber(), 1, "wrong member level");

        await network.register(eula, profile, {from: charlie});
        level = await network.getMemberLevel(charlie);
        assert.equal(level.toNumber(), 1, "wrong member level");
    });

    it('should create new market', async () => {
        const network = await XBRNetwork.deployed();

        if (false) {
            const eula = "QmU7Gizbre17x6V2VR1Q2GJEjz6m8S1bXmBtVxS2vmvb81";
            const profile = "QmQMtxYtLQkirCsVmc3YSTFQWXHkwcASMnu5msezGEwHLT";

            await network.register(eula, profile, {from: alice});
        }

        const marketId = web3.sha3("MyMarket1");
        const maker = alice_maker1;
        const terms = "0x00000000000000000000000000000000";
        const providerSecurity = 10;
        const consumerSecurity = 10;

        // 5% market fee
        const marketFee = 0.05 * 10**9 * 10**18

        await network.createMarket(marketId, maker, terms, providerSecurity, consumerSecurity, marketFee, {from: alice});
    });

    it('should join existing market', async () => {
        const network = await XBRNetwork.deployed();

        const marketId = web3.sha3("MyMarket1");

        var actorType = 3; // PROVIDER
        await network.joinMarket(marketId, actorType, {from: bob});

        actorType = 4; // CONSUMER
        await network.joinMarket(marketId, actorType, {from: charlie});
    });
});
