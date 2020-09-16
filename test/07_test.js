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

const w3_utils = require("web3-utils");
const eth_sig_utils = require("eth-sig-util");
const eth_util = require("ethereumjs-util");
const utils = eth_sig_utils.TypedDataUtils;
const BN = web3.utils.BN;

const XBRTest = artifacts.require("./XBRTest.sol");

const DomainData = {
    types: {
        EIP712Domain: [
            { name: 'name', type: 'string' },
            { name: 'version', type: 'string' },
            { name: 'chainId', type: 'uint256' },
            { name: 'verifyingContract', type: 'address' },
        ],
        EIP712ApproveTransfer: [
            {name: 'sender', type: 'address'},
            {name: 'relayer', type: 'address'},
            {name: 'spender', type: 'address'},
            {name: 'amount', type: 'uint256'},
            {name: 'expires', type: 'uint256'},
            {name: 'nonce', type: 'uint256'},
        ],
        Person: [
            { name: 'name', type: 'string' },
            { name: 'wallet', type: 'address' }
        ],
        Mail: [
            { name: 'from', type: 'Person' },
            { name: 'to', type: 'Person' },
            { name: 'contents', type: 'string' }
        ],
    },
    primaryType: 'Mail',
    domain: {
        name: 'Ether Mail',
        version: '1',
        chainId: 1,
        verifyingContract: '0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC',
    },
    message: null,
};


function eip712_sign_approval(key_, data_) {
    DomainData['message'] = data_;
    var key = eth_util.toBuffer(key_);
    var sig = eth_sig_utils.signTypedData(key, {data: DomainData})
    return sig;
}


const alice = w3_utils.toChecksumAddress("0xffcf8fdee72ac11b5c542428b35eef5769c409f0");
const alice_privkey = "0x6cbed15c793ce57650b9877cf6fa156fbef513c4e6134f022a85b1ffdd59b2a1";
const sender = alice;

contract('XBRTest', accounts => {


    const gasLimit = 0xfffffffffff;
    var testcontract;

    beforeEach('setup contract for each test', async function () {
        testcontract = await XBRTest.deployed();
    });

    it('XBRTest.test() : internal contract test function should succeed', async () => {

        await testcontract.test({from: sender, gasLimit: gasLimit});
    });

    it('XBRTest.test_verify1() : valid signature verification function should succeed', async () => {

        // r_bytes32 || s_bytes32 || v_uint8
        const sig = "0x4355c47d63924e8a72e509b65029052eb6c299d53a04e167c5775fd466751c9d07299936d304c153f6443dfa05f40ff007d72911b6f72307f996231605b915621c"

        res = await testcontract.test_verify1(
            "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826",
            "Cow", "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826",
            "Bob", "0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB",
            "Hello, Bob!",
            sig,
            {from: sender, gasLimit: gasLimit}
        );
        assert.equal(res, true, "XBRTest.test_verify1(): failed to verify signature")
    });

    it('XBRTest.test_verify1() : invalid signature verification function should fail', async () => {

        // r_bytes32 || s_bytes32 || v_uint8
        const sig = "0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"

        res = await testcontract.test_verify1(
            "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826",
            "Cow", "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826",
            "Bob", "0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB",
            "Hello, Bob!",
            sig,
            {from: sender, gasLimit: gasLimit}
        );
        assert.equal(res, false, "XBRTest.test_verify1(): failed to verify signature")
    });

    it('XBRTest.test_verify2() : valid signature verification function should succeed', async () => {

        res = await testcontract.test_verify2(
            "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826",
            "Cow", "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826",
            "Bob", "0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB",
            "Hello, Bob!",
            "0x1c",
            "0x4355c47d63924e8a72e509b65029052eb6c299d53a04e167c5775fd466751c9d",
            "0x07299936d304c153f6443dfa05f40ff007d72911b6f72307f996231605b91562",
            {from: sender, gasLimit: gasLimit}
        );
        assert.equal(res, true, "XBRTest.test_verify2(): failed to verify signature")
    });

    it('XBRTest.test_verify2() : invalid signature verification function should fail', async () => {

        res = await testcontract.test_verify2(
            "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826",
            "Cow", "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826",
            "Bob", "0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB",
            "Hello, Bob!",
            "0x1c",
            "0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
            "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
            {from: sender, gasLimit: gasLimit}
        );
        assert.equal(res, false, "XBRTest.test_verify2(): failed to verify signature")
    });

    it('JS : should compute and recover a correct signature', async () => {

        var key = eth_util.toBuffer(alice_privkey);

        var msg = {
            from: {
                name: 'Cow',
                wallet: '0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826',
            },
            to: {
                name: 'Bob',
                wallet: '0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB',
            },
            contents: 'Hello, Bob!',
        }
        DomainData['message'] = msg;

        var msg_hash = utils.hashStruct(DomainData.primaryType, DomainData.message, DomainData.types);
        // console.log('MSG_HASH = ', eth_util.bufferToHex(msg_hash));

        var msg_sig = eth_sig_utils.signTypedData(key, {data: DomainData})
        // console.log("SIGNATURE = " + msg_sig);

        var signer = eth_sig_utils.recoverTypedSignature({data: DomainData, sig: msg_sig});
        signer = w3_utils.toChecksumAddress(signer);

        assert.equal(signer, alice, "XBRTest.test_verify1(): verification should succeed");
    });

    it('XBRTest.test_verify1 + JS : should compute and verify a correct signature', async () => {

        var key = eth_util.toBuffer(alice_privkey);

        var msg = {
            from: {
                name: 'Cow',
                wallet: '0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826',
            },
            to: {
                name: 'Bob',
                wallet: '0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB',
            },
            contents: 'Hello, Bob!',
        }
        DomainData['message'] = msg;

        const msg_sig = eth_sig_utils.signTypedData(key, {data: DomainData})

        res = await testcontract.test_verify1(
            alice,
            "Cow", "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826",
            "Bob", "0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB",
            "Hello, Bob!",
            msg_sig,
            {from: sender, gasLimit: gasLimit}
        );

        assert.equal(res, true, "XBRTest.test_verify1(): failed to verify valid signature");
    });

    it('XBRTest.test_verify1: should fail an invalid signature', async () => {

        var key = eth_util.toBuffer(alice_privkey);

        var msg = {
            from: {
                name: 'Cow',
                wallet: '0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826',
            },
            to: {
                name: 'Bob',
                wallet: '0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB',
            },
            contents: 'Hello, Bob!',
        }
        DomainData['message'] = msg;

        const msg_sig = "0x0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";

        res = await testcontract.test_verify1(
            alice,
            "Cow", "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826",
            "Bob", "0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB",
            "Hello, Bob!",
            msg_sig,
            {from: sender, gasLimit: gasLimit}
        );

        assert.equal(res, false, "XBRTest.test_verify1(): succeeded with an invalid signature");
    });

    it("XBRTest().approveForVerify() : should verify correct signature", async () => {

        // const sender = accounts[0];
        const sender = w3_utils.toChecksumAddress('0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1');
        const sender_key = '0x4f3edf983ac636a65a842ce7c78d9aa706d3b113bce9c46f30d7d21715b23b1d';

        // const spender = accounts[1];
        const spender = w3_utils.toChecksumAddress('0xFFcf8FDEE72ac11b5c542428B35EEF5769C409f0');

        // const relayer = accounts[2];
        const relayer = w3_utils.toChecksumAddress('0x22d491Bde2303f2f43325b2108D26f1eAbA1e32b');
        // const relayer = w3_utils.toChecksumAddress('0x0000000000000000000000000000000000000000');

        // 1 million XBR
        const amount = new BN('100000000000000');
        const expires = 0;
        const nonce = 1;

        const approval = {
            'sender': sender,
            'relayer': relayer,
            'spender': spender,
            'amount': amount,
            'expires': expires,
            'nonce': nonce,
        }
        console.log('MESSAGE', sender_key, approval);

        // prepare: pre-sign metatransaction
        // const signature = '0x0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000';
        const signature = eip712_sign_approval(sender_key, approval);
        console.log('SIGNATURE', signature);

        result = null;
        console.log('testcontract.approveForVerify', sender, relayer, spender, amount, expires, nonce, signature);
        try {
            result = await testcontract.approveForVerify(sender, relayer, spender, amount, expires, nonce, signature, {from: relayer, gasLimit: gasLimit});
        } catch (error) {
            assert(false, "call to verify should always succeed [" + error + "]");
        }
        if (result !== null) {
            assert(result, "correct signature should verify");
        }
    });
});
