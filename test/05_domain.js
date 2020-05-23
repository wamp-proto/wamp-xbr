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
const w3_utils = require("web3-utils");
const eth_sig_utils = require("eth-sig-util");
const eth_util = require("ethereumjs-util");
const BN = require('bn.js');

const XBRNetwork = artifacts.require("./XBRNetwork.sol");
const XBRToken = artifacts.require("./XBRToken.sol");
const XBRDomain = artifacts.require("./XBRDomain.sol");


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

    // deployed instance of XBRToken
    var token;

    // deployed instance of XBRDomain
    var domain;

    var chainId;
    var verifyingContract;

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

    const domainId = utils.sha3("MyDomain1").substring(0, 34);
    const alice = accounts[1];

    beforeEach('setup contract for each test', async function () {
        token = await XBRToken.deployed();
        network = await XBRNetwork.deployed();
        domain = await XBRDomain.deployed();

        chainId = await network.verifyingChain();
        verifyingContract = await network.verifyingContract();

        const eula = await network.eula();
        const profile = "QmQMtxYtLQkirCsVmc3YSTFQWXHkwcASMnu5msezGEwHLT";

        const _alice = await network.members(alice);
        const _alice_level = _alice.level.toNumber();
        if (_alice_level == MemberLevel_NULL) {
            await network.registerMember(eula, profile, {from: alice, gasLimit: gasLimit});
        }
    });

    it('XBRMarket.createDomain() : should create new domain', async () => {

        const domainKey = '0x810e817f420772877eaacb38b77e2054f41378f629067acfebdbd696d7b3bc46';
        const license = await domain.license();
        const terms = "QmcAuALHaH9pxJP9bzo7go8QU9xUraSozBNVynRs81hpqr";
        const meta = "Qmaa4Rw81a3a1VEx4LxB7HADUAXvZFhCoRdBzsMZyZmqHD";

        const domainSeq_before = await domain.domainSeq();

        await domain.createDomain(domainId, domainKey, license, terms, meta, {from: alice, gasLimit: gasLimit});

        const domainSeq_after = await domain.domainSeq();
        assert(domainSeq_after.eq(domainSeq_before.add(new BN(1))), "domain sequence not incremented");

        const domain_ = await domain.domains(domainId);
        assert(domain_.created.gt(1), "wrong created attribute in domain");
        assert(domain_.seq.eq(domainSeq_before), "wrong seq attribute in domain");
        assert.equal(domain_.status, DomainStatus_ACTIVE, "wrong status attribute in domain");
        assert.equal(domain_.owner, alice, "wrong owner attribute in domain");
        assert.equal(domain_.key, domainKey, "wrong key attribute in domain");
        assert.equal(domain_.license, license, "wrong license attribute in domain");
        assert.equal(domain_.terms, terms, "wrong terms attribute in domain");
        assert.equal(domain_.meta, meta, "wrong meta attribute in domain");
        assert.equal(domain_.signature, null, "wrong signature attribute in domain");
    });
});
