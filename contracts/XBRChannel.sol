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

    /// Current payment channel type (either payment or paying channel).
    ChannelType private _type;

    /// Current payment channel state.
    ChannelState private _state;

    /// The XBR Market ID this channel is operating payments (or payouts) for.
    bytes16 private _marketId;

    /**
     * The sender of the payments in this channel. Either a XBR Consumer (delegate) in case
     * of a payment channel, or the XBR Market Maker (delegate) in case of a paying channel.
     */
    address private _sender;

    /**
     * The other delegate of the channel, e.g. the XBR Market Maker in case of a payment channel,
     * or a XBR Provider (delegate) in case of a paying channel.
     */
    address private _delegate;

    /**
     * Recipient of the payments in this channel. Either the XBR Market Operator (payment
     * channels) or a XBR Provider (paying channels).
     */
    address private _recipient;

    /// Amount of XBR held in the channel.
    uint256 private _amount;

    /// Block number when the channel was created.
    uint256 private _openedAt;

    /// Block number when the channel was closed (finally, after the timeout).
    uint256 private _closedAt;

    /**
     * Timeout with which the channel will be closed (the grace period during which the
     * channel will wait for participants to submit their last signed transaction).
     */
    uint32 private _channelTimeout;

    /// Signatures of the channel participants (when channel is closing).
    mapping (bytes32 => address) private _signatures;

    /**
     * Event emitted when payment channel is closing (that is, one of the two state channel
     * participants has called "close()", initiating start of the channel timeout).
     */
    event Closing(bytes16 indexed marketId, address signer, uint256 amount, uint256 timeoutAt);

    /**
     * Event emitted when payment channel has finally closed, which happens after both state
     * channel participants have called close(), agreeing on last state, or after the timeout
     * at latest - in case the second participant doesn't react within timeout)
     */
    event Closed(bytes16 indexed marketId, address signer, uint256 amount, uint256 closedAt);

    /**
     * Create a new XBR payment channel for handling microtransactions of XBR tokens.
     *
     * @param marketId The ID of the XBR market this payment channel is associated with.
     * @param sender The sender (onchain) of the payments.
     * @param delegate The offchain delegate allowed to spend XBR offchain, from the channel,
     *     in the name of the original sender.
     * @param recipient The receiver (onchain) of the payments.
     * @param amount The amount of XBR held in the channel.
     * @param channelTimeout The payment channel timeout period that begins with the first call to `close()`
     */
    constructor (bytes16 marketId, address sender, address delegate, address recipient, uint256 amount,
        uint32 channelTimeout, ChannelType channelType) public {

        _type = channelType;
        _state = ChannelState.OPEN;
        _marketId = marketId;
        _sender = sender;
        _delegate = delegate;
        _recipient = recipient;
        _amount = amount;
        _channelTimeout = channelTimeout;
        _openedAt = block.number; // solhint-disable-line
    }

    /**
     * The XBR Market ID this channel is operating payments for.
     */
    function channelType () public view returns (ChannelType) {
        return _type;
    }

    /**
     * The XBR Market ID this channel is operating payments for.
     */
    function channelState () public view returns (ChannelState) {
        return _state;
    }

    /**
     * The XBR Market ID this channel is operating payments for.
     */
    function marketId () public view returns (bytes16) {
        return _marketId;
    }

    /**
     * The sender of the payments in this channel. Either a XBR Consumer or XBR Market Maker (delegate).
     */
    function sender () public view returns (address) {
        return _sender;
    }

    /**
     * The delegate working for the sender, and using this channel to pay for data keys. E.g. a
     * XBR Consumer (delegate) or XBR Provider (delegate).
     */
    function delegate () public view returns (address) {
        return _delegate;
    }

    /**
     * Recipient of the payments in this channel. Either a XBR Market Maker (delegate) or a XBR Provider.
     */
    function recipient () public view returns (address) {
        return _recipient;
    }

    /**
     * Amount of XBR held in the channel.
     */
    function amount () public view returns (uint256) {
        return _amount;
    }

    /**
     * Block number when the channel was created.
     */
    function openedAt () public view returns (uint256) {
        return _openedAt;
    }

    /**
     * Block number when the channel was closed (finally, after the timeout).
     */
    function closedAt () public view returns (uint256) {
        return _closedAt;
    }

    /**
     * Timeout with which the channel will be closed (the grace period during which the
     * channel will wait for participants to submit their last signed transaction).
     */
    function channelTimeout () public view returns (uint32) {
        return _channelTimeout;
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
    function close (bytes32 h, uint8 v, bytes32 r, bytes32 s, uint32 sequence, uint256 value) public view {

        address signer;
        bytes32 proof;

        // get signer from signature
        signer = ecrecover(h, v, r, s);

        if (signer != _sender && signer != _recipient) {
            revert("invalid signature");
        }

        proof = keccak256(abi.encodePacked(this, sequence, value));

        if (proof != h) {
            revert("invalid signature (signature is valid but doesn't match the data provided)");
        }
/* FIXME
        if (_signatures[proof] == 0) {
            _signatures[proof] = signer;

            // event Closing(bytes16 indexed marketId, address signer, uint256 amount, uint256 timeoutAt);
            emit Closing(_marketId, signer, value, block.number + _channelTimeout);

        } else if (_signatures[proof] != signer) {
            // channel completed, both _signatures provided
            _closedAt = block.number;
            if (!_recipient.send(value)) { // solhint-disable-line
                revert("transaction failed on the very last meter");
            }

            // refund back anything left to the original opener of the payment channel
            selfdestruct(_sender);

            // event Closed(bytes16 indexed marketId, address signer, uint256 amount, uint256 closedAt);
            emit Closed(_marketId, signer, value, _closedAt);
        }
*/
    }

    /**
     * Timeout this state channel.
     */
    function timeout () public {
        require(_closedAt == 0, "CHANNEL_ALREADY_CLOSED");
        // require(_signatures[proof] != 0, "CHANNEL_NOT_YET_SIGNED");

        if (_openedAt + _channelTimeout > now) { // solhint-disable-line
            revert("channel timeout");
        }
        _closedAt = block.number;

        // FIXME
        // selfdestruct(_sender);
        // emit Closed();
    }

    function _verify (bytes32 hash, uint8 v, bytes16 r, bytes32 s, address expectedSigner) internal pure returns (bool)
    {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, hash));
        return ecrecover(prefixedHash, v, r, s) == expectedSigner;
    }
}
