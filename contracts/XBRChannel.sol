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

pragma solidity ^0.5.2;
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
        ChannelType ctype_) public {

        organization = organization_;
        network = network_;
        ctype = ctype_;
        state = ChannelState.OPEN;
        marketId = marketId_;
        marketmaker = marketmaker_;
        sender = sender_;
        delegate = delegate_;
        recipient = recipient_;
        amount = amount_;
        timeout = timeout_;
        openedAt = block.timestamp; // solhint-disable-line

        _token = XBRToken(token_);

        DOMAIN_SEPARATOR = hash(EIP712Domain({
            name: "XBR",
            version: "1",
            chainId: 1,
            verifyingContract: 0x254dffcd3277C0b1660F6d42EFbB754edaBAbC2B
            // verifyingContract: network_
        }));
    }

    function hash(EIP712Domain memory domain_) internal pure returns (bytes32) {
        return keccak256(abi.encode(
            EIP712_DOMAIN_TYPEHASH,
            keccak256(bytes(domain_.name)),
            keccak256(bytes(domain_.version)),
            domain_.chainId,
            domain_.verifyingContract
        ));
    }

    function hash(ChannelClose memory close_) internal pure returns (bytes32) {
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
    function splitSignature (bytes memory signature_rsv) private pure returns (uint8 v, bytes32 r, bytes32 s) {
        require(signature_rsv.length == 65, "INVALID_SIGNATURE_LENGTH");

        //  // first 32 bytes, after the length prefix
        //  r := mload(add(sig, 32))
        //  // second 32 bytes
        //  s := mload(add(sig, 64))
        //  // final byte (first byte of the next 32 bytes)
        //  v := byte(0, mload(add(sig, 96)))
        assembly
        {
            r := mload(add(signature_rsv, 32))
            s := mload(add(signature_rsv, 64))
            v := and(mload(add(signature_rsv, 65)), 255)
        }
        if (v < 27) {
            v += 27;
        }

        return (v, r, s);
    }

    /**
     * Verify close transaction typed data was signed by signer.
     */
    function verifyClose (address signer, address channel_adr_, uint32 channel_seq_, uint256 balance_,
        bool is_final_, bytes memory sig_rsv_) public view returns (bool) {

        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig_rsv_);

        ChannelClose memory close = ChannelClose({
            channel_adr: channel_adr_,
            channel_seq: channel_seq_,
            balance: balance_,
            is_final: is_final_
        });

        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPARATOR,
            hash(close)
        ));

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
        bytes memory delegate_sig, bytes memory marketmaker_sig) public {

        require(verifyClose(delegate, address(this), channel_seq_, balance_, is_final_, delegate_sig),
            "INVALID_DELEGATE_SIGNATURE");

        require(verifyClose(marketmaker, address(this), channel_seq_, balance_, is_final_, marketmaker_sig),
            "INVALID_MARKETMAKER_SIGNATURE");

        // closing (off-chain) balance must be valid
        require(0 <= balance_ && balance_ <= amount, "INVALID_CLOSING_BALANCE");

        // closing (off-chain) sequence must be valid
        require(channel_seq_ >= 1, "INVALID_CLOSING_SEQ");

        // channel must be in correct state (OPEN or CLOSING)
        require(state == ChannelState.OPEN || state == ChannelState.CLOSING, "CHANNEL_NOT_OPEN");

        // if the channel is already closing ..
        if (state == ChannelState.CLOSING) {
            // the channel must not yet be timed out
            require(closedAt == 0, "INTERNAL_ERROR_CLOSED_AT_NONZERO");
            require(block.timestamp < closingAt, "CHANNEL_TIMEOUT"); // solhint-disable-line

            // the submitted transaction must be more recent
            require(channel_seq_ < _closing_channel_seq, "OUTDATED_TRANSACTION");
        }

        // the amount earned (by the recipient) is initial channel amount minus last off-chain balance
        uint256 earned = (amount - balance_);

        // the remaining amount (send back to the buyer) ia the last off-chain balance
        uint256 refund = balance_;

        // the fee to the xbr network is 1% of the earned amount
        uint256 fee = earned / 100;

        // the amount paid out to the recipient
        uint256 payout = earned - fee;

        // if we got a newer closing transaction, process it ..
        if (channel_seq_ > _closing_channel_seq) {

            // the closing balance of a newer transaction must be not greater than anyone we already know
            if (_closing_channel_seq > 0) {
                require(balance_ <= _closing_balance, "TRANSACTION_BALANCE_OUTDATED");
            }

            // note the closing transaction sequence number and closing off-chain balance
            state = ChannelState.CLOSING;
            _closing_channel_seq = channel_seq_;
            _closing_balance = balance_;

            // note the new channel closing date
            closingAt = block.timestamp + timeout; // solhint-disable-line

            // notify channel observers
            emit Closing(marketId, sender, payout, fee, refund, closingAt);
        }

        // finally close the channel ..
        if (is_final_ || balance_ == 0 || (state == ChannelState.CLOSING && block.timestamp >= closingAt)) { // solhint-disable-line

            // now send tokens locked in this channel (which escrows the tokens) to the recipient,
            // the xbr network (for the network fee), and refund remaining tokens to the original sender
            if (payout > 0) {
                require(_token.transfer(recipient, payout), "CHANNEL_CLOSE_PAYOUT_TRANSFER_FAILED");
            }

            if (fee > 0) {
                require(_token.transfer(organization, fee), "CHANNEL_CLOSE_FEE_TRANSFER_FAILED");
            }

            if (refund > 0) {
                require(_token.transfer(sender, refund), "CHANNEL_CLOSE_REFUND_TRANSFER_FAILED");
            }

            // mark channel as closed (but do not selfdestruct)
            closedAt = block.timestamp; // solhint-disable-line
            state = ChannelState.CLOSED;

            // notify channel observers
            emit Closed(marketId, sender, payout, fee, refund, closedAt);
        }
    }
}
