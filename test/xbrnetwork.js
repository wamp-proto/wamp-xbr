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

    it('network organization should be the owner', async () => {
        const _organization = await network.organization();

        assert.equal(_organization, owner, "network organization was initialized correctly");
    });

    it('token should be the network token', async () => {
        const _token = await network.token();

        assert.equal(_token, token.address, "network token was initialized correctly");
    });

    it('owner account should be initially registered', async () => {

        const level = await network.getMemberLevel(owner);

        assert.equal(level.toNumber(), MemberLevel_VERIFIED, "wrong member level");
    });

    it('non-owner accounts should be initially unregistered', async () => {
        //const network = await XBRNetwork.deployed();

        var level;

        level = await network.getMemberLevel(alice);
        assert.equal(level.toNumber(), MemberLevel_NULL, "wrong member level " + level);

        level = await network.getMemberLevel(bob);
        assert.equal(level.toNumber(), MemberLevel_NULL, "wrong member level " + level);

        level = await network.getMemberLevel(charlie);
        assert.equal(level.toNumber(), MemberLevel_NULL, "wrong member level " + level);

        level = await network.getMemberLevel(donald);
        assert.equal(level.toNumber(), MemberLevel_NULL, "wrong member level " + level);

        level = await network.getMemberLevel(edith);
        assert.equal(level.toNumber(), MemberLevel_NULL, "wrong member level " + level);

        level = await network.getMemberLevel(frank);
        assert.equal(level.toNumber(), MemberLevel_NULL, "wrong member level " + level);
    });

    it('should create new member, and with the correct member level', async () => {

        const eula = "QmU7Gizbre17x6V2VR1Q2GJEjz6m8S1bXmBtVxS2vmvb81";
        const profile = "QmQMtxYtLQkirCsVmc3YSTFQWXHkwcASMnu5msezGEwHLT";

        await network.register(eula, profile, {from: alice});

        const _level = await network.getMemberLevel(alice);
        assert.equal(_level.toNumber(), MemberLevel_ACTIVE, "wrong member level");

        const _eula = await network.getMemberEula(alice);
        assert.equal(_eula, eula, "wrong member EULA");

        const _profile = await network.getMemberProfile(alice);
        assert.equal(_eula, eula, "wrong member Profile");
    });

    it('creating a new member should fire the correct event', async () => {

        const eula = "QmU7Gizbre17x6V2VR1Q2GJEjz6m8S1bXmBtVxS2vmvb81";
        const profile = "QmQMtxYtLQkirCsVmc3YSTFQWXHkwcASMnu5msezGEwHLT";

        const filter = {};
        const event = network.MemberCreated(filter);

        event.watch((err, result) => {

            assert.equal(result.args.member, bob, "wrong member address in event");
            assert.equal(result.args.eula, eula, "wrong member EULA in event");
            assert.equal(result.args.profile, profile, "wrong member Profile in event");
            assert.equal(result.args.level, MemberLevel_ACTIVE, "wrong member level in event");

            event.stopWatching()
        });

        await network.register(eula, profile, {from: bob});
    });

    it('retiring a member should fire the correct event and store the correct member level', async () => {

        const filter = {};
        const event = network.MemberRetired(filter);

        event.watch((err, result) => {

            assert.equal(result.args.member, bob, "wrong member address in event");

            event.stopWatching()
        });

        await network.unregister({from: bob});

        const _level = await network.getMemberLevel(bob);
        assert.equal(_level.toNumber(), MemberLevel_RETIRED, "wrong member level");
    });

    it('should create new domain, with correct attributes, and firing correct event', async () => {

        const domainId = "0x9d9827822252fbe721d45224c7db7cac";
        const domainKey = "0xfeb083ce587a4ea72681d7db776452b05aaf58dc778534a6938313e4c85912f0";
        const license = "";
        const terms = "";
        const meta = "";

        const filter = {};
        const event = network.DomainCreated(filter);

        event.watch((err, result) => {

            // bytes16 domainId, uint32 domainSeq, address owner, bytes32 domainKey, string license, string terms, string meta

            assert.equal(result.args.domainId, domainId, "wrong domainId in event");
            assert.equal(result.args.domainSeq, 1, "wrong domainSeq in event");
            assert.equal(result.args.owner, alice, "wrong domainId in event");
            assert.equal(result.args.domainKey, domainKey, "wrong domainId in event");
            assert.equal(result.args.license, license, "wrong domainId in event");
            assert.equal(result.args.terms, terms, "wrong domainId in event");
            assert.equal(result.args.meta, meta, "wrong domainId in event");

            event.stopWatching()
        });

        await network.createDomain(domainId, domainKey, license, terms, meta, {from: alice});

        const _status = await network.getDomainStatus(domainId);
        assert.equal(_status, DomainStatus_ACTIVE, "wrong domain status");

        const _owner = await network.getDomainOwner(domainId);
        assert.equal(_owner, alice, "wrong domain owner");

        const _domainKey = await network.getDomainKey(domainId);
        assert.equal(_domainKey, domainKey, "wrong domain domainKey");

        const _license = await network.getDomainLicense(domainId);
        assert.equal(_license, license, "wrong domain license");

        const _terms = await network.getDomainTerms(domainId);
        assert.equal(_terms, terms, "wrong domain termas");

        const _meta = await network.getDomainMeta(domainId);
        assert.equal(_meta, meta, "wrong domain meta");
    });

    it('creating a duplicate domain should throw', async () => {

        const domainId = "0x9d9827822252fbe721d45224c7db7cac";

        try {
            await network.createDomain(domainId, "", "", "", "", {from: alice});
            assert(false, "contract should throw here");
        } catch (error) {
            assert(/DOMAIN_ALREADY_EXISTS/.test(error), "wrong error message");
        }
    });

    it('should create new market', async () => {

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

    it('should join existing market', async () => {

        const marketId = web3.sha3("MyMarket1").substring(0, 34);

        var actorType = 3; // PROVIDER
        await network.joinMarket(marketId, actorType, {from: bob});

        actorType = 4; // CONSUMER
        await network.joinMarket(marketId, actorType, {from: charlie});
    });
});
