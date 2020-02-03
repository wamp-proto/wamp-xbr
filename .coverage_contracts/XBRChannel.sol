///////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2018-2019 Crossbar.io Technologies GmbH and contributors.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
///////////////////////////////////////////////////////////////////////////////

pragma solidity ^0.5.0;
//pragma experimental ABIEncoderV2;

// https://openzeppelin.org/api/docs/math_SafeMath.html
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

// https://openzeppelin.org/api/docs/cryptography_ECDSA.html
import "openzeppelin-solidity/contracts/cryptography/ECDSA.sol";

import "./XBRToken.sol";


/**
 * XBR Payment/Paying Channel between a XBR data consumer and the XBR market maker,
 * or the XBR Market Maker and a XBR data provider.
 */
contract XBRChannel {
function coverage_0x2a2df4f5(bytes32 c__0x2a2df4f5) public pure {}


    // Add safe math functions to uint256 using SafeMath lib from OpenZeppelin
    using SafeMath for uint256;

    // Add recover method for bytes32 using ECDSA lib from OpenZeppelin
    using ECDSA for bytes32;

    /// Payment channel types.
    enum ChannelType { NONE, PAYMENT, PAYING }

    /// Payment channel states.
    enum ChannelState { NONE, OPEN, CLOSING, CLOSED }

    /// EIP712 type data.
    bytes32 constant EIP712_DOMAIN_TYPEHASH = keccak256(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
    );

    /// EIP712 type data.
    bytes32 constant CHANNELCLOSE_DOMAIN_TYPEHASH = keccak256(
        "ChannelClose(address channel_adr,uint32 channel_seq,uint256 balance,bool is_final)"
    );

    /// EIP712 type data.
    bytes32 private DOMAIN_SEPARATOR;

    /// XBR Network ERC20 token (XBR for the CrossbarFX technology stack)
    XBRToken private _token;

    /// When this channel is closing, the sequence number of the closing transaction.
    uint32 private _closing_channel_seq;

    /// When this channel is closing, the off-chain closing balance of the closing transaction.
    uint256 private _closing_balance;

    /// Address of the `XBR Network Organization <https://xbr.network/>`_
    address public organization;

    /// Address of XBRNetwork instance that created this channel.
    address public network;

    /// Current payment channel type (either payment or paying channel).
    ChannelType public ctype;

    /// Current payment channel state.
    ChannelState public state;

    /// The XBR Market ID this channel is operating payments (or payouts) for.
    bytes16 public marketId;

    /**
     * The off-chain market maker that operates this payment or paying channel.
     */
    address public marketmaker;

    /**
     * The sender of the payments in this channel. Either a XBR Consumer (payment channels) or
     * the XBR Market Maker (paying channels).
     */
    address public sender;

    /**
     * The delegate of the channel, e.g. the XBR Consumer delegate in case of a payment channel
     * or the XBR Provider (delegate) in case of a paying channel that is allowed to consume or
     * provide data with payment therefor running under this channel.
     */
    address public delegate;

    /**
     * Recipient of the payments in this channel. Either the XBR Market Operator (payment
     * channels) or a XBR Provider (paying channels) in the market.
     */
    address public recipient;

    /// Amount of XBR held in the channel.
    uint256 public amount;

    /// Block timestamp when the channel was created.
    uint256 public openedAt;

    /// Block timestamp when the channel was closed (finally, after the timeout).
    uint256 public closingAt;

    /// Block timestamp when the channel was closed (finally, after the timeout).
    uint256 public closedAt;

    /**
     * Timeout with which the channel will be closed (the grace period during which the
     * channel will wait for participants to submit their last signed transaction).
     */
    uint32 public timeout;

    /**
     * Event emitted when payment channel is closing (that is, one of the two state channel
     * participants has called "close()", initiating start of the channel timeout).
     */
    event Closing(bytes16 indexed marketId, address signer, uint256 payout, uint256 fee,
        uint256 refund, uint256 timeoutAt);

    /**
     * Event emitted when payment channel has finally closed, which happens after both state
     * channel participants have called close(), agreeing on last state, or after the timeout
     * at latest - in case the second participant doesn't react within timeout)
     */
    event Closed(bytes16 indexed marketId, address signer, uint256 payout, uint256 fee,
        uint256 refund, uint256 closedAt);

    /// EIP712 type.
    struct EIP712Domain {
        string  name;
        string  version;
        uint256 chainId;
        address verifyingContract;
    }

    /// EIP712 type.
    struct ChannelClose {
        address channel_adr;
        uint32 channel_seq;
        uint256 balance;
        bool is_final;
    }

    /**
     * Create a new XBR payment channel for handling microtransactions of XBR tokens.
     *
     * @param marketId_ The ID of the XBR market this payment channel is associated with.
     * @param sender_ The sender (onchain) of the payments.
     * @param delegate_ The offchain delegate allowed to spend XBR offchain, from the channel,
     *     in the name of the original sender.
     * @param recipient_ The receiver (onchain) of the payments.
     * @param amount_ The amount of XBR held in the channel.
     * @param timeout_ The payment channel timeout period that begins with the first call to `close()`
     */
    constructor (address organization_, address token_, address network_, bytes16 marketId_, address marketmaker_,
        address sender_, address delegate_, address recipient_, uint256 amount_, uint32 timeout_,
        ChannelType ctype_) public {coverage_0x2a2df4f5(0x3d3086a632328f866405ae805df1211d6d750e94b7e4b24b0d7fecb81c7fe54d); /* function */ 


coverage_0x2a2df4f5(0xa497b58bb4742924a4e9ead4d2374bbf51412f17b19f1a3d0697f47494f6db19); /* line */ 
        coverage_0x2a2df4f5(0xca0e7b6cec826bf47fc768988f20608b68144a74196ae1e67039620e3c086954); /* statement */ 
organization = organization_;
coverage_0x2a2df4f5(0x08920e1c2f91b121c86517a4fc0f751ed9e11b46ff3bdc4ffad3187bd5b8b63e); /* line */ 
        coverage_0x2a2df4f5(0xd2d12b7ecbf12ee82e9a950b000a227dfc254fe1764a989f2ca74151544c9444); /* statement */ 
network = network_;
coverage_0x2a2df4f5(0xcce1c3627f8f5eedea818bfef271d26d76c42f60a7422dece7f8ce4f30f1dc5a); /* line */ 
        coverage_0x2a2df4f5(0xa8b3317ebe9721476ec1c1d6d1f80b5ff5d54b41f5b2ae6fafb2b0fc91baf592); /* statement */ 
ctype = ctype_;
coverage_0x2a2df4f5(0xe5b7984d752c033fe29a6b61a4328325c1950fbd9fcdf18bcd6785401f1d4242); /* line */ 
        coverage_0x2a2df4f5(0xa37dfc23d14ef9cd7b3bb615f24b668ff1f9e802055489b73451f5edd89eb6fb); /* statement */ 
state = ChannelState.OPEN;
coverage_0x2a2df4f5(0x3040e1e8a67d05202211daf463bb34533686a345913a59c7524cf65da841d2c0); /* line */ 
        coverage_0x2a2df4f5(0xdb2058877bdb3a71a82f993ec7abcdf4982793a9d26cbd43cd8c6ca7b3e86cf0); /* statement */ 
marketId = marketId_;
coverage_0x2a2df4f5(0x524355a0ca5a389fbc610653ae9ce72f5d2821ca6a589ad1ca2526be66e70a7a); /* line */ 
        coverage_0x2a2df4f5(0x4e7e079380afa8799af23eaaadbf2e7e6c6e674db59376e18ebd6a93e165fef1); /* statement */ 
marketmaker = marketmaker_;
coverage_0x2a2df4f5(0x2950f1c3fcedd83e8761b7e41ba183ef7e48b00e52c853ea7bd0a4c5e059bf34); /* line */ 
        coverage_0x2a2df4f5(0x32f147de693249779403994af1923cb7692140407ef6726de15d21cc51af52d8); /* statement */ 
sender = sender_;
coverage_0x2a2df4f5(0xff7d94e73fb2ab96cf9ad0c564b195174e9ebc351fb340b50dfadbac83acd8fb); /* line */ 
        coverage_0x2a2df4f5(0x93e781b8546a2ba6eac119926f853f2817f5821047b5937b182a6edffbebc928); /* statement */ 
delegate = delegate_;
coverage_0x2a2df4f5(0xd6d97d21b242b2a9f75e9d739ec6957e1964dec1dab07fecec87c043e67a9faa); /* line */ 
        coverage_0x2a2df4f5(0xc3c552afd43c8f5f719490fba964a6a2a58d1249925019968c4f3fc4b8183668); /* statement */ 
recipient = recipient_;
coverage_0x2a2df4f5(0x826abe6491271e6fbbc5aac7343e8d4ee7ad27a13261a2973332a67cf294a556); /* line */ 
        coverage_0x2a2df4f5(0x9a91cbddedfc5ca6dac79cf981767a4f1f0c847b9857c2483e665b0b32f98128); /* statement */ 
amount = amount_;
coverage_0x2a2df4f5(0x2266171bf77367b364c477acc871ba96a402caaa16823d0379bcd40457ceb2fc); /* line */ 
        coverage_0x2a2df4f5(0xbc012deac9f59ff2a70425f884c18eb901a8298e8dff6d970e4d35a076206b41); /* statement */ 
timeout = timeout_;
coverage_0x2a2df4f5(0x0199250f83b7e61503f1c8dc67c2d1d9c22c40e2c3d9813879a97bfda5d1e840); /* line */ 
        coverage_0x2a2df4f5(0xe513f12a333307317c63b5db1937777274c510abcf0794dff7f4cb6d09022ff3); /* statement */ 
openedAt = block.timestamp; // solhint-disable-line

coverage_0x2a2df4f5(0x8a422f6d42692e5ac6811157029c06047f9ab08b1790404634149d6653d99a1f); /* line */ 
        coverage_0x2a2df4f5(0x826bcb68b7579ab195db1df63864e260a1861b35691e1bad187feca4da4fbc5c); /* statement */ 
_token = XBRToken(token_);

coverage_0x2a2df4f5(0xfd84a044e14c26e2b0111e06b4b1c67996e8b9dd4b065211d8b0ba34112e5335); /* line */ 
        coverage_0x2a2df4f5(0xfc4bb514700c147db35c8d15b1b21bdd6a5ee407ffba142fa4df313a7b0d2aae); /* statement */ 
DOMAIN_SEPARATOR = hash(EIP712Domain({
            name: "XBR",
            version: "1",
            chainId: 1,
            verifyingContract: 0x254dffcd3277C0b1660F6d42EFbB754edaBAbC2B
            // verifyingContract: network_
        }));
    }

    function hash(EIP712Domain memory domain_) internal pure returns (bytes32) {coverage_0x2a2df4f5(0x5e977fbfd0a45f19b512467611081e091768b78de1df5fe02f3fe41b6d63d5cf); /* function */ 

coverage_0x2a2df4f5(0x6228bb594e4464385354a9fd1afe0e9a825370dbcac9a3cc2a746929f3b7178e); /* line */ 
        coverage_0x2a2df4f5(0x7ba0b836841654637c815e6607d043f42642eb64ef6f53a34a57293d82f76ef1); /* statement */ 
return keccak256(abi.encode(
            EIP712_DOMAIN_TYPEHASH,
            keccak256(bytes(domain_.name)),
            keccak256(bytes(domain_.version)),
            domain_.chainId,
            domain_.verifyingContract
        ));
    }

    function hash(ChannelClose memory close_) internal pure returns (bytes32) {coverage_0x2a2df4f5(0x10d58d2145ac371be391a39f6a3e7cfca6f41d357c06da4e5504f1d78ad36e90); /* function */ 

coverage_0x2a2df4f5(0x6e92b16356972582f76e967321c8c414ec1b26b00952f861f7cd74bcc5980fb4); /* line */ 
        coverage_0x2a2df4f5(0x9c4ee3dcfb6b03a1ea02c87bc220ceee911f76cb25ce08e384439a23603f1aba); /* statement */ 
return keccak256(abi.encode(
            CHANNELCLOSE_DOMAIN_TYPEHASH,
            close_.channel_adr,
            close_.channel_seq,
            close_.balance,
            close_.is_final
        ));
    }

    /**
     * Split a signature given as a bytes string into components.
     */
    function splitSignature (bytes memory signature_rsv) private pure returns (uint8 v, bytes32 r, bytes32 s) {coverage_0x2a2df4f5(0x7f77595c51c8d8f7c81b3e8a3628cdf25a199d7af768c7c2ec285090ac856e79); /* function */ 

coverage_0x2a2df4f5(0x6536b298984436d83720c081a1bff3b3788d82e4942fce571878dd264fb8576e); /* line */ 
        coverage_0x2a2df4f5(0x228d3d1cd36565d2edcd3774cc8f003499f33440ab66e854197dd3a2d22b4597); /* assertPre */ 
coverage_0x2a2df4f5(0xf60731be740b036ef1f3a1264f3a8d526842c366d6a58780a1a983ba916da2d0); /* statement */ 
require(signature_rsv.length == 65, "INVALID_SIGNATURE_LENGTH");coverage_0x2a2df4f5(0x1439021328652734c48293e8b26d921e93aa7634ee4c66a74097dd6a54fc1740); /* assertPost */ 


        //  // first 32 bytes, after the length prefix
        //  r := mload(add(sig, 32))
        //  // second 32 bytes
        //  s := mload(add(sig, 64))
        //  // final byte (first byte of the next 32 bytes)
        //  v := byte(0, mload(add(sig, 96)))
coverage_0x2a2df4f5(0x31814ec3ac9e382fdc6658cf1ff26f925b943174df55001d5671858e1c4f429a); /* line */ 
        assembly
        {
            r := mload(add(signature_rsv, 32))
            s := mload(add(signature_rsv, 64))
            v := and(mload(add(signature_rsv, 65)), 255)
        }
coverage_0x2a2df4f5(0x41fb6df81d82193a14aa8b3e702bf8cb1b6abd8d793863f599715add7513cc70); /* line */ 
        coverage_0x2a2df4f5(0x84e1c4938e58b7551782820cb41ab25f6d4c90bc6b9679bad4041c0f51e3ab63); /* statement */ 
if (v < 27) {coverage_0x2a2df4f5(0x2c09c47f0a48f7df36dd27ccf3ae00efb46721e719094648089e7fd014d565bf); /* branch */ 

coverage_0x2a2df4f5(0x372c19e3a7778ea08f8e2c1f649042f1928e3a75e2a251121ff40cc94ad00eec); /* line */ 
            coverage_0x2a2df4f5(0xfefb78de1ad4f3bf618552c3087d901dfafa609aada87a6b76cbee5b1624342d); /* statement */ 
v += 27;
        }else { coverage_0x2a2df4f5(0x85847b6a7852049fea51ef0d1cec3d4ba8048b6650a50ebd258850a0343583c7); /* branch */ 
}

coverage_0x2a2df4f5(0x921a2a618070f6338bb016f2749b1ceb5d1a6c9e90c34ba6365ca08e4002a639); /* line */ 
        coverage_0x2a2df4f5(0x1def6a7d113ad3e8d8e05355bd228cf1e9e04159a907ccef3eddbed0c776ef60); /* statement */ 
return (v, r, s);
    }

    /**
     * Verify close transaction typed data was signed by signer.
     */
    function verifyClose (address signer, address channel_adr_, uint32 channel_seq_, uint256 balance_,
        bool is_final_, bytes memory sig_rsv_) public view returns (bool) {coverage_0x2a2df4f5(0x8869cc5fdc4ce6f2c1f2f457c15d83e07581e5f1f54f3d3535d6aab1e4f12b6b); /* function */ 


coverage_0x2a2df4f5(0x24d0bfd5925058d9fc09992c2d4952989e69ce4b9930b766539db33eab97ac39); /* line */ 
        coverage_0x2a2df4f5(0x59e2e5caf1bfa48846f0c8b63284c429022ff6d8a0ced8c338b119d3fdef85b6); /* statement */ 
(uint8 v, bytes32 r, bytes32 s) = splitSignature(sig_rsv_);

coverage_0x2a2df4f5(0x44e23f2541e95d27b3c218718f79231caa79218b6fbc56a850667532c3b8c593); /* line */ 
        coverage_0x2a2df4f5(0x3687d751d13b14cf0e2775890d6562870c23d2f7ab9e60b87d7e42cbf921e843); /* statement */ 
ChannelClose memory close = ChannelClose({
            channel_adr: channel_adr_,
            channel_seq: channel_seq_,
            balance: balance_,
            is_final: is_final_
        });

coverage_0x2a2df4f5(0x33d27ceb88365f5c508e1d1c095322347fb1bb015d0783da103a8ea58c21b451); /* line */ 
        coverage_0x2a2df4f5(0x9e73b7d3c72f057e86e7f71a96f79e531d4c6d862552df1be86cd055f7097f57); /* statement */ 
bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPARATOR,
            hash(close)
        ));

coverage_0x2a2df4f5(0xa5e7ab3b6c2d5de7d426226dc7aaf72b39d67e286268564abe3a4beb5a4f50e1); /* line */ 
        coverage_0x2a2df4f5(0x7c6892be7347162f0ae18afbf5cc702e11bcfa32ec83a06b6ba2bec834e65def); /* statement */ 
return ecrecover(digest, v, r, s) == signer;
    }

    /**
     * Trigger closing this payment channel. When the first participant has called `close()`
     * submitting its latest transaction/state, a timeout period begins during which the
     * other party of the payment channel has to submit its latest transaction/state too.
     * When both transaction have been submitted, and the submitted transactions/states agree,
     * the channel immediately closes, and the consumed amount of token in the channel is
     * transferred to the channel recipient, and the remaining amount of token is transferred
     * back to the original sender.
     */
    function close (uint32 channel_seq_, uint256 balance_, bool is_final_,
        bytes memory delegate_sig, bytes memory marketmaker_sig) public {coverage_0x2a2df4f5(0xc9ecaab06d05adcaa93365369218128bb993998b297dc58b8bd5e61d243aaee8); /* function */ 


coverage_0x2a2df4f5(0xef5b164ae76013687c15e16d25cf43f33a3567d6bf47e1d65c31aee075892a5d); /* line */ 
        coverage_0x2a2df4f5(0x0642b07fe39796206ace10eb5cf27b9f1ec25cab0eace446c2a40911d5f1ef44); /* assertPre */ 
coverage_0x2a2df4f5(0x86ad35e7f2c2bde78e0b5bc16a46d0a246c6f39aa6726658763f8599f7143705); /* statement */ 
require(verifyClose(delegate, address(this), channel_seq_, balance_, is_final_, delegate_sig),
            "INVALID_DELEGATE_SIGNATURE");coverage_0x2a2df4f5(0x85440b3516bcea74e6c610e58856e29440b52b67d75cf34b921983eae1883b36); /* assertPost */ 


coverage_0x2a2df4f5(0xeaa5715dd14ea6f55e0ec9fe77fca2e9b91be9f0c98386238050e69d44475939); /* line */ 
        coverage_0x2a2df4f5(0xc6d679715890e88289d5e8d82bd6a1a2c76214b3f77b494323fbf7929e746ff6); /* assertPre */ 
coverage_0x2a2df4f5(0x69d7728c83f0a79680eab786389b6140103ecccbae94873e0c4fdf66ed6c3d88); /* statement */ 
require(verifyClose(marketmaker, address(this), channel_seq_, balance_, is_final_, marketmaker_sig),
            "INVALID_MARKETMAKER_SIGNATURE");coverage_0x2a2df4f5(0xde60d83f67d3ea01fd3f393d6f5ed0bf5ac931914b1982514b712230e70d5b73); /* assertPost */ 


        // closing (off-chain) balance must be valid
coverage_0x2a2df4f5(0x4f62a1007320632e47a67e6d4839a511bf0add88f73baaa0dfca3f934cbef4e3); /* line */ 
        coverage_0x2a2df4f5(0x362bdc13025fbf762f65a6faf0977bb574439ff07c46b0a50956d8df0607aed1); /* assertPre */ 
coverage_0x2a2df4f5(0xd1b9e43caf8b464eda0f618b2f8c72db0d8304aec78ecd770ea2c319f72726da); /* statement */ 
require(0 <= balance_ && balance_ <= amount, "INVALID_CLOSING_BALANCE");coverage_0x2a2df4f5(0x5cb96f72271a07780040865b0831db5bcbc8b84202677801b591a25ccd0c1f1a); /* assertPost */ 


        // closing (off-chain) sequence must be valid
coverage_0x2a2df4f5(0x62b115ba73ec3961dca3010d6d40f6cff339ea549707a9719681714180ba467a); /* line */ 
        coverage_0x2a2df4f5(0x497591e07f1fd753535bc10ad35680cde868e8183d708fad3d87736c873fd0ba); /* assertPre */ 
coverage_0x2a2df4f5(0x2ffe4c78096e9d4e8aa51edddc29c696dffd676b90da072912b8c85aea23e550); /* statement */ 
require(channel_seq_ >= 1, "INVALID_CLOSING_SEQ");coverage_0x2a2df4f5(0x8269d1c92b89668101ed3e0d7b1eea2644c06558b4fddd2cab1abab13636c7c2); /* assertPost */ 


        // channel must be in correct state (OPEN or CLOSING)
coverage_0x2a2df4f5(0x8cfc6f969b248c5ee5f54c9d54d9b1f662174582a3a137586107788f5c39d4ba); /* line */ 
        coverage_0x2a2df4f5(0xe51a2f09e07f54041cafdd4c4beb8299662b014f258ed7cdb632957456d083ac); /* assertPre */ 
coverage_0x2a2df4f5(0xf913c8ece3d97fb6eca49f9e9214a9fb8d4bb43dcc771359c11baddda5a4ff61); /* statement */ 
require(state == ChannelState.OPEN || state == ChannelState.CLOSING, "CHANNEL_NOT_OPEN");coverage_0x2a2df4f5(0x1e423f9696f72ada279c4bc9d10978f9b5699a581649bb0418e3bc7690609650); /* assertPost */ 


        // if the channel is already closing ..
coverage_0x2a2df4f5(0xdead9316507d68da50b00b55ff949707bd594a3aae9d2ae71f789e6f064a7a18); /* line */ 
        coverage_0x2a2df4f5(0x85352d6e9537e21ca218a3e7cd930f04c358510e892905284f2102b947c128e6); /* statement */ 
if (state == ChannelState.CLOSING) {coverage_0x2a2df4f5(0x75a195af53dc1da94242e8e11f0fdce24813837414575241aec55158def6c777); /* branch */ 

            // the channel must not yet be timed out
coverage_0x2a2df4f5(0x4a758e8e62f3b05461f2cefa98d4c70c00e4fa4b2ba2f7ee88a420d2f964854d); /* line */ 
            coverage_0x2a2df4f5(0x7861cbd4962157c612c6d61847d3b4c950e5038bc8616f128f33b71f7f85a23c); /* assertPre */ 
coverage_0x2a2df4f5(0xac5079cc800544229d559e4e09c56dbdb844198a2e3187933608a0c6fea8acbe); /* statement */ 
require(closedAt == 0, "INTERNAL_ERROR_CLOSED_AT_NONZERO");coverage_0x2a2df4f5(0x96cc126eca3c43f36a48674b25b08e0cb289bd0ad7dcc45e5cd369cb57814770); /* assertPost */ 

coverage_0x2a2df4f5(0xec97a58f81fef7ca417874c462eba4b1ab77de09c859892e3340710b63ca4fa7); /* line */ 
            coverage_0x2a2df4f5(0x97d7e8289ae1a7e5fb5e2a1c0dba39cdc53365613a8743fa699289424051dd44); /* assertPre */ 
coverage_0x2a2df4f5(0x1884a41d2b86567a62fd21e9df3769e942112eeeecaedec56792c665c2849f3a); /* statement */ 
require(block.timestamp < closingAt, "CHANNEL_TIMEOUT");coverage_0x2a2df4f5(0xfd56e5f2d7b93522337f9e38ade74f11dbddecf0fd14d1a204969f13149c058a); /* assertPost */ 
 // solhint-disable-line

            // the submitted transaction must be more recent
coverage_0x2a2df4f5(0x55cf4ba00b53ef7b5a34ec46b0deb1c2e632140ed452c933063bd029660e9100); /* line */ 
            coverage_0x2a2df4f5(0x784cd761b742b49955fd1877060e660ab78bac2b46fe9fb1a4ce344582a97643); /* assertPre */ 
coverage_0x2a2df4f5(0xdbcd9ae2851548e5c61291bc2f17c73b651509ad1474fe595c1a4625981da9c6); /* statement */ 
require(channel_seq_ < _closing_channel_seq, "OUTDATED_TRANSACTION");coverage_0x2a2df4f5(0x118f6bd806d8424ef49a0817f01d146bae59adfda8f542ab5efba53bb88da154); /* assertPost */ 

        }else { coverage_0x2a2df4f5(0x9071a658c478f7bbee22874df1a34ea93ffd76b1269cd66cf2a3a51005748bd2); /* branch */ 
}

        // the amount earned (by the recipient) is initial channel amount minus last off-chain balance
coverage_0x2a2df4f5(0x7309ddb6aa2c3410144c965e7fc831bd1edfe712ffa852d10cd4d13eb3c4bb9e); /* line */ 
        coverage_0x2a2df4f5(0xd6c5907d6d846ba1478af88af95947f8361d3c9812883ab6f807f443b0039ea8); /* statement */ 
uint256 earned = (amount - balance_);

        // the remaining amount (send back to the buyer) ia the last off-chain balance
coverage_0x2a2df4f5(0xb29514aa2a9a38fcc7e70511441af3170bc973b550b67dca77f3d4491d397b8f); /* line */ 
        coverage_0x2a2df4f5(0x63f3dbad8a4a0e835a419143bb84f8cdea17bc7a5005272eaeeb402432788946); /* statement */ 
uint256 refund = balance_;

        // the fee to the xbr network is 1% of the earned amount
coverage_0x2a2df4f5(0x97a02b27f62ffb3e09d05a7b25070dceb23434276016035ee1bbb3e025ae1517); /* line */ 
        coverage_0x2a2df4f5(0x7d9d1d0fdee678af757718d87c6c65970d832237483eb66d75bc2b3efc6276c8); /* statement */ 
uint256 fee = earned / 100;

        // the amount paid out to the recipient
coverage_0x2a2df4f5(0x2d3ea84964b168c24cde110d855eb5c2eb2f5674a395c79f3f171d7a8e4a877d); /* line */ 
        coverage_0x2a2df4f5(0x28542f68b30b57c75bf86a0aacb82b98d04042ae475924893d52b650037f55c5); /* statement */ 
uint256 payout = earned - fee;

        // if we got a newer closing transaction, process it ..
coverage_0x2a2df4f5(0x8e05e6afec076a87b4fa3d2ae17c37caa2c2454abc790c145a725ad8944a9d3b); /* line */ 
        coverage_0x2a2df4f5(0x42b2e3a634e0656765c281767cf1b6ae3d8b6dfc80caf988685b2186b4a46337); /* statement */ 
if (channel_seq_ > _closing_channel_seq) {coverage_0x2a2df4f5(0xaeb0edbdcc2927966d41f3e53b2a2ba505e8f937182c8e1749cdb8ac1f28e5f4); /* branch */ 


            // the closing balance of a newer transaction must be not greater than anyone we already know
coverage_0x2a2df4f5(0x0f970fbcb404f81783d4c998504b0f3a880da5609754a407537d7561195ce687); /* line */ 
            coverage_0x2a2df4f5(0xa83c787fa283baf555a022448806a30dcac4e9be44b26c317bfa31d36b5b36c4); /* statement */ 
if (_closing_channel_seq > 0) {coverage_0x2a2df4f5(0x06083f3b0badd8204937cf1bc0419066706472ee1053ffbcbb63af48571a6599); /* branch */ 

coverage_0x2a2df4f5(0x9ed342adcb36fa0101fc5717afee906a2a35250c91709f877e454481df56e05f); /* line */ 
                coverage_0x2a2df4f5(0x6b329909ce56fd5c1e0101744ab5baecfb0e2cc4f357a35fd6ed4548d640410a); /* assertPre */ 
coverage_0x2a2df4f5(0x90dd1f051c881203d6b736014a40b86259ed29009cb4c73aaac4a2fb8aac3c32); /* statement */ 
require(balance_ <= _closing_balance, "TRANSACTION_BALANCE_OUTDATED");coverage_0x2a2df4f5(0x8fd328eea6d3c2431c65bba91e25080e8ff2d07e4bf3a9375d724266c54c6285); /* assertPost */ 

            }else { coverage_0x2a2df4f5(0xce476ef89d2e662d37b068148c87c5755ef1a6bebc792749ac48ace3cfe3237f); /* branch */ 
}

            // note the closing transaction sequence number and closing off-chain balance
coverage_0x2a2df4f5(0x6f0f08289cf46c02bac9b0cfc149fe6d9c9015a4604b9c489344f8baf7f796ab); /* line */ 
            coverage_0x2a2df4f5(0x7ea96caf7548d40485b3848489d408730bc225a935df841156e63f1355b125f7); /* statement */ 
state = ChannelState.CLOSING;
coverage_0x2a2df4f5(0xc4deb15e5625abfc19961ff7c5c8ab53e8d16cf23483a1fb9241e05b9ae54e73); /* line */ 
            coverage_0x2a2df4f5(0xef59759f50098367414a9723e5494329145b5645a49e2668be8ec7b8e93111e2); /* statement */ 
_closing_channel_seq = channel_seq_;
coverage_0x2a2df4f5(0xefebb92eabd07b6bdf6d48929e253e5a9f9d94d3f272843133cb2b7deba54d1c); /* line */ 
            coverage_0x2a2df4f5(0x0aaa5c9d8e864fb57d653eb010fb1ac17e64335d99b18053e5f488a2fc569000); /* statement */ 
_closing_balance = balance_;

            // note the new channel closing date
coverage_0x2a2df4f5(0x82caec52858f72e3546c8d623b4af3b990a7f60cc28316c7428adce4a58b126f); /* line */ 
            coverage_0x2a2df4f5(0xefae10e44053a53c2be1ae5867773493c4e237f693a1a27de7a14a7a2c7bcd41); /* statement */ 
closingAt = block.timestamp + timeout; // solhint-disable-line

            // notify channel observers
coverage_0x2a2df4f5(0xc974b57be3575fa06628f143752110b41438c353424c809c6f801743a16a92ee); /* line */ 
            coverage_0x2a2df4f5(0xb22efce89ebdce134e6c45fabf2f9cab11fe01d3b024c8d4fc3c815eb0acfb25); /* statement */ 
emit Closing(marketId, sender, payout, fee, refund, closingAt);
        }else { coverage_0x2a2df4f5(0x6ce0394853021e8705efb4a85006b7fb24d317f78216fae9d2906d75063b9937); /* branch */ 
}

        // finally close the channel ..
coverage_0x2a2df4f5(0xb4aebe34ce87f38d8ddd3bc936600db550197540aa5721fe4376fa3fc86a1fb7); /* line */ 
        coverage_0x2a2df4f5(0xea6a6c68f1acb7fa56511e036e9cfa79db43befccf60733164579eda0bc0ff98); /* statement */ 
if (is_final_ || balance_ == 0 || (state == ChannelState.CLOSING && block.timestamp >= closingAt)) {coverage_0x2a2df4f5(0x74c8b7513fae2d2dea34951373ef9fb554c17224fe083792346932782d6a17f2); /* branch */ 
 // solhint-disable-line

            // now send tokens locked in this channel (which escrows the tokens) to the recipient,
            // the xbr network (for the network fee), and refund remaining tokens to the original sender
coverage_0x2a2df4f5(0x8ff93498950ec32c420c78a99f3fee85756b791ac808e995b279cc6f246cc832); /* line */ 
            coverage_0x2a2df4f5(0xb7828af117d03291326acacc15307fdcffb8a21f5806a6fbcc8cdd2bbb6390c2); /* statement */ 
if (payout > 0) {coverage_0x2a2df4f5(0x763a9dff6ae4867fbd432422be9e3a5f93efca12f537dbd92d651a40f27d1360); /* branch */ 

coverage_0x2a2df4f5(0xe92b4341fc0060f0f801fe69c2df2d1c6079f7ff03769fcb4455e71e82c6a2f8); /* line */ 
                coverage_0x2a2df4f5(0x2e23d92d34bccb45d28846f246947510a408d277b6d57d5158ab924178c946b5); /* assertPre */ 
coverage_0x2a2df4f5(0x6d8b8dd1c039f4f2ace5d2f855d762310d8fdf68eb6f794a2c70730b745c5d1f); /* statement */ 
require(_token.transfer(recipient, payout), "CHANNEL_CLOSE_PAYOUT_TRANSFER_FAILED");coverage_0x2a2df4f5(0x5df55bd4674efc06c6838130d3c45bf188bfd35ec382d14dbc786ae31a4f3b85); /* assertPost */ 

            }else { coverage_0x2a2df4f5(0x2b901f6aa5761229acf52c7b43ff4ab9749e2b9252054c60588957cfa11cea8b); /* branch */ 
}

coverage_0x2a2df4f5(0xe8434b55b888003478f669143787345d0a895d1cd4b041d3db89dc3d9bff210f); /* line */ 
            coverage_0x2a2df4f5(0x38fb60862aaf1bc29b64133292dc54a7ab7ce34d4912cffb72e617a9cbe6fe6c); /* statement */ 
if (fee > 0) {coverage_0x2a2df4f5(0x6bc06c4ce3707e7ed5dc04314436f43ab07ca7a17a192a84107a2a7fe82686ab); /* branch */ 

coverage_0x2a2df4f5(0x8f74155e608a3c31090f452ae5032481a79b34380e77f45bcf012efc923b669a); /* line */ 
                coverage_0x2a2df4f5(0xf305d447a552a4c0c738a09e4792fb9252040f53e621e3f665cf333bc0be9b21); /* assertPre */ 
coverage_0x2a2df4f5(0x36529a95957bf9f2588d97188525a9116909bdc9603997ca1a3ac46084a8451f); /* statement */ 
require(_token.transfer(organization, fee), "CHANNEL_CLOSE_FEE_TRANSFER_FAILED");coverage_0x2a2df4f5(0xcc61c0d6663823ecfcdb9c3f03dcf80bf5499deaf0d85cbfc82f3ac65034c035); /* assertPost */ 

            }else { coverage_0x2a2df4f5(0x02bff9045142a623078f0319a196cfad67d7db0b72723c143aa879d67cdfc035); /* branch */ 
}

coverage_0x2a2df4f5(0xcfe624bd40bc9c4c9991c32810871a2711a41032116bcf133d24f161574fa6bf); /* line */ 
            coverage_0x2a2df4f5(0x593c1b76b662e4b7be8d989965b50c231e6a7c466d0973bc08d1d548756b39b1); /* statement */ 
if (refund > 0) {coverage_0x2a2df4f5(0xbdb521a1d7218bb05b59e4522c06a46ff3754142b26b6c47077a7ea800cb30a5); /* branch */ 

coverage_0x2a2df4f5(0x6f7b24d43ced720e1364a6ad64e702b795eb88abcb858c9880fc04ce77ccc892); /* line */ 
                coverage_0x2a2df4f5(0x2ad56cb919f3a89aa04f9f859a6dd3715418fb2bdb39cf20a039256ce80313cf); /* assertPre */ 
coverage_0x2a2df4f5(0x38e8b3bfa8ab062ffeb4288eac9b6cb7339a99375eb472469c756c13b9efa3ec); /* statement */ 
require(_token.transfer(sender, refund), "CHANNEL_CLOSE_REFUND_TRANSFER_FAILED");coverage_0x2a2df4f5(0xca7ec74f30ac304f7ec084cc06bdc93409936ec7a0363d913d6f7f473c079dfc); /* assertPost */ 

            }else { coverage_0x2a2df4f5(0xae42d88343462b3ee3482644b217f9c4f5dd32178cb8e2bd3faf9e3d60ae0609); /* branch */ 
}

            // mark channel as closed (but do not selfdestruct)
coverage_0x2a2df4f5(0x95755e781cf599ce12df7a154fb1c1fafc4f4599749b1f64119fd718bf1fc722); /* line */ 
            coverage_0x2a2df4f5(0x20fbd69d01b15aef598d33648486170dc41b965fb54f72110bcb4a815509005e); /* statement */ 
closedAt = block.timestamp; // solhint-disable-line
coverage_0x2a2df4f5(0x2e27afd97ca96f98fcab2e5519828ad47854bb333e6d34c1fa2f774a4fd8630a); /* line */ 
            coverage_0x2a2df4f5(0xa41d61a8d54d0d7a624296d433f38fc703c29a6e0e2cb7f708486823b6d2cff3); /* statement */ 
state = ChannelState.CLOSED;

            // notify channel observers
coverage_0x2a2df4f5(0xcc03dd6eca1b28d2b523bf8904f8f99b84fb5f1271503eebcfc51a0793292bcc); /* line */ 
            coverage_0x2a2df4f5(0x91aeb6a94245d09810a4c0d46776a8d0af5cdeb361e04655c7a25b1022d1b000); /* statement */ 
emit Closed(marketId, sender, payout, fee, refund, closedAt);
        }else { coverage_0x2a2df4f5(0xe35a5622a1c31a457010cb8aa6c834420ba9b4b4e7500c34c3567421c9743d51); /* branch */ 
}
    }
}
