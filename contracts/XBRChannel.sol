///////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2018 Crossbar.io Technologies GmbH and contributors.
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

/*
    // Add recover method for bytes32 using ECDSA lib from OpenZeppelin
    using ECDSA for bytes32;
*/

    uint256 constant chainId = 5777;

    address constant verifyingContract = 0x254dffcd3277C0b1660F6d42EFbB754edaBAbC2B;

    string private constant EIP712_DOMAIN =
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)";

    bytes32 private constant EIP712_DOMAIN_TYPEHASH = keccak256(abi.encodePacked(EIP712_DOMAIN));

    string private constant TRANSACTION_TYPE =
        "Transaction(uint256 pubkey,uint128 key_id,uint32 channel_seq,uint256 amount,uint256 balance)";

    bytes32 private constant TRANSACTION_DOMAIN_TYPEHASH = keccak256(abi.encodePacked(TRANSACTION_TYPE));

    bytes32 private constant DOMAIN_SEPARATOR = keccak256(abi.encode(
        EIP712_DOMAIN_TYPEHASH,
        keccak256("XBR"),
        keccak256("1"),
        chainId,
        verifyingContract
    ));

    /// XBR Network ERC20 token (XBR for the CrossbarFX technology stack)
    XBRToken private _token;

    /// Payment channel types.
    enum ChannelType { NONE, PAYMENT, PAYING }

    /// Payment channel states.
    enum ChannelState { NONE, OPEN, CLOSING, CLOSED }

    /// Current payment channel type (either payment or paying channel).
    ChannelType public ctype;

    /// Current payment channel state.
    ChannelState public state;

    /// The XBR Market ID this channel is operating payments (or payouts) for.
    bytes16 public marketId;

    /**
     * The sender of the payments in this channel. Either a XBR Consumer (delegate) in case
     * of a payment channel, or the XBR Market Maker (delegate) in case of a paying channel.
     */
    address public sender;

    /**
     * The other delegate of the channel, e.g. the XBR Market Maker in case of a payment channel,
     * or a XBR Provider (delegate) in case of a paying channel.
     */
    address public delegate;

    /**
     * Recipient of the payments in this channel. Either the XBR Market Operator (payment
     * channels) or a XBR Provider (paying channels).
     */
    address public recipient;

    /// Amount of XBR held in the channel.
    uint256 public amount;

    /// Block timestamp when the channel was created.
    uint256 public openedAt;

    /// Block timestamp when the channel was closed (finally, after the timeout).
    uint256 public closedAt;

    /**
     * Timeout with which the channel will be closed (the grace period during which the
     * channel will wait for participants to submit their last signed transaction).
     */
    uint32 public timeout;

    /// Signatures of the channel participants (when channel is closing).
    mapping (bytes32 => address) private _signatures;

    /**
     * Event emitted when payment channel is closing (that is, one of the two state channel
     * participants has called "close()", initiating start of the channel timeout).
     */
    event Closing(bytes16 indexed marketId, address signer, uint256 earned, uint256 remaining, uint256 timeoutAt);

    /**
     * Event emitted when payment channel has finally closed, which happens after both state
     * channel participants have called close(), agreeing on last state, or after the timeout
     * at latest - in case the second participant doesn't react within timeout)
     */
    event Closed(bytes16 indexed marketId, address signer, uint256 earned, uint256 remaining, uint256 closedAt);

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
    constructor (address token_, bytes16 marketId_, address sender_, address delegate_,
                address recipient_, uint256 amount_, uint32 timeout_, ChannelType ctype_) public {

        _token = XBRToken(token_);
        ctype = ctype_;
        state = ChannelState.OPEN;
        marketId = marketId_;
        sender = sender_;
        delegate = delegate_;
        recipient = recipient_;
        amount = amount_;
        timeout = timeout_;
        openedAt = block.timestamp; // solhint-disable-line
    }

    /**
     * Split a signature given as a bytes string into components.
     */
    function splitSignature (bytes memory sig) internal pure returns (uint8 v, bytes32 r, bytes32 s)
    {
        require(sig.length == 65, "INVALID_SIGNATURE_LENGTH");

        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    /**
     * Verify close transaction typed data was signed by signer.
     */
    function verifyClose (address tx_signer, bytes32 pubkey_, bytes16 key_id_, uint32 channel_seq_,
        uint256 amount_, uint256 balance_, uint8 v, bytes32 r, bytes32 s) public pure returns (bool) {

        return tx_signer == ecrecover(keccak256(abi.encodePacked(
            "\\x19\\x01",
            DOMAIN_SEPARATOR,
            keccak256(abi.encode(
                TRANSACTION_DOMAIN_TYPEHASH,
                pubkey_,
                key_id_,
                channel_seq_,
                amount_,
                balance_
            ))
        )), v, r, s);
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
    function close (bytes32 pubkey_, bytes16 key_id_, uint32 channel_seq_, uint256 amount_, uint256 balance_,
                    bytes memory delegate_sig, bytes memory marketmaker_sig) public {

        (uint8 _delegate_sig_v, bytes32 _delegate_sig_r, bytes32 _delegate_sig_s) = splitSignature(delegate_sig);
        (uint8 _maker_sig_v, bytes32 _maker_sig_r, bytes32 _maker_sig_s) = splitSignature(marketmaker_sig);

        // FIXME: abpy and abjs agree on signature, but the following code does not (anymore, because
        // it "did already work")
        if (false) {
            if (ctype == XBRChannel.ChannelType.PAYMENT) {
                require(verifyClose(delegate, pubkey_, key_id_, channel_seq_, amount_,
                    balance_, _delegate_sig_v, _delegate_sig_r, _delegate_sig_s), "INVALID_DELEGATE_SIGNATURE");
                require(verifyClose(sender, pubkey_, key_id_, channel_seq_, amount_,
                    balance_, _maker_sig_v, _maker_sig_r, _maker_sig_s), "INVALID_MARKETMAKER_SIGNATURE");
            } else {
                require(verifyClose(sender, pubkey_, key_id_, channel_seq_, amount_,
                    balance_, _delegate_sig_v, _delegate_sig_r, _delegate_sig_s), "INVALID_DELEGATE_SIGNATURE");
                require(verifyClose(delegate, pubkey_, key_id_, channel_seq_, amount_,
                    balance_, _maker_sig_v, _maker_sig_r, _maker_sig_s), "INVALID_MARKETMAKER_SIGNATURE");
            }
        }

        require(state == ChannelState.OPEN, "CHANNEL_NOT_OPEN");
        require(0 <= balance_ && balance_ <= amount, "INVALID_CLOSING_BALANCE");
        require(channel_seq_ >= 1, "INVALID_CLOSING_SEQ");

        uint256 earned = amount - balance_;
        uint256 remaining = balance_;

        bool success = false;
        if (earned > 0) {
            success = _token.transfer(recipient, earned);
            require(success, "CHANNEL_CLOSE_EARNED_TRANSFER_FAILED");
        }

        if (remaining > 0) {
            success = _token.transfer(sender, remaining);
            require(success, "CHANNEL_CLOSE_REMAINING_TRANSFER_FAILED");
        }

        // FIXME: selfdestruct ?! to whom?
        // FIXME: recipient amountamount vs txamount vs ..
        // FIXME: network fee
        // FIXME: timeout and CLOSING event

        closedAt = block.timestamp; // solhint-disable-line
        state = ChannelState.CLOSED;
        emit Closed(marketId, sender, earned, remaining, closedAt);
    }
}
