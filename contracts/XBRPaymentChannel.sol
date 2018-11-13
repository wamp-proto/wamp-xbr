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

pragma solidity ^0.4.24;


/**
 * XBR Payment Channel between a XBR data consumer and the XBR market maker,
 * or the XBR Market Maker and a XBR data provider.
 */
contract XBRPaymentChannel {

    bytes32 private _marketId;
    address private _sender;
    address private _delegate;
    address private _recipient;
    uint256 private _amount;
    uint256 private _started;
    uint32 private _timeout;
    mapping (bytes32 => address) private _signatures;

    /**
     * Event emitted when payment channel is closing (that is, one of the two state channel
     * participants has called "close()", initiating start of the channel timeout).
     */
    event Closing();

    /**
     * Event emitted when payment channel has finally closed, which happens after both state
     * channel participants have called close(), agreeing on last state, or after the timeout
     * at latest - in case the 2nd participant doesn't react within timeout)
     */
    event Closed();

    /**
     * Create a new XBR payment channel for handling microtransactions of XBR tokens.
     *
     * @param marketId The ID of the XBR market this payment channel is associated with.
     * @param sender The sender (onchain) of the payments.
     * @param delegate The offchain delegate allowed to spend XBR offchain, from the channel,
     *     in the name of the original sender.
     * @param recipient The receiver (onchain) of the payments.
     * @param amount The amount of XBR held in the channel.
     * @param timeout The payment channel timeout period that begins with the first call to `close()`
     */
    constructor (bytes32 marketId, address sender, address delegate, address recipient, uint256 amount,
        uint32 timeout) public {

        _marketId = marketId;
        _sender = sender;
        _delegate = delegate;
        _recipient = recipient;
        _amount = amount;
        _timeout = timeout;

        _started = now; // solhint-disable-line
    }

    /**
     * Trigger closing this payment channel. When the first participant has called `close()`
     * submitting its latest transaction/state, a timeout period begins during which the
     * other party of the payment channel has to submit its latest transaction/state too.
     * When both transaction have been submitted, and the submitted transactions/states agree,
     * the channel immediately closes, and the consumed amount of token in the channel is
     * transferred to the chanel receipient, and the remaining amount of token is transferred
     * back to the original sender.
     */
    function close (bytes32 h, uint8 v, bytes32 r, bytes32 s, uint value) public {

        address signer;
        bytes32 proof;

        // get signer from signature
        signer = ecrecover(h, v, r, s);

        if (signer != _sender && signer != _recipient) {
            revert("invalid signature");
        }

        proof = keccak256(abi.encodePacked(this, value));

        if (proof != h) {
            revert("invalid signature (signature is valid but doesn't match the data provided)");
        }

        if (_signatures[proof] == 0) {
            _signatures[proof] = signer;
            emit Closing();
        } else if (_signatures[proof] != signer) {
            // channel completed, both _signatures provided
            if (!_recipient.send(value)) { // solhint-disable-line
                revert("transaction failed on the very last meter");
            }
            selfdestruct(_sender);
            emit Closed();
        }
    }

    /**
     * Timeout this state channel.
     */
    function timeout () public {
        if (_started + _timeout > now) { // solhint-disable-line
            revert("channel timeout");
        }
        selfdestruct(_sender);
    }

    function _verify (bytes32 hash, uint8 v, bytes32 r, bytes32 s, address expected_signer) internal pure returns (bool)
    {

        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, hash));
        return ecrecover(prefixedHash, v, r, s) == expected_signer;
    }
}
