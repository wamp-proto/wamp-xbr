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

    bytes32 public market_id;
    address public channel_sender;
    address public channel_recipient;
    uint public start_date;
    uint public channel_timeout;
    mapping (bytes32 => address) public signatures;

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
     * @param _market_id The ID of the XBR market this payment channel is associated with.
     * @param to The receiver of the payments.
     * @param timeout The payment channel timeout period that begins with the first call to `close()`
     */
    constructor (bytes32 _market_id, address to, uint timeout) public payable {

        market_id = _market_id;
        channel_recipient = to;
        channel_sender = msg.sender;
        start_date = now; // solhint-disable-line
        channel_timeout = timeout;
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

        if (signer != channel_sender && signer != channel_recipient) {
            revert("invalid signature");
        }

        proof = keccak256(abi.encodePacked(this, value));

        if (proof != h) {
            revert("invalid signature (signature is valid but doesn't match the data provided)");
        }

        if (signatures[proof] == 0) {
            signatures[proof] = signer;
            emit Closing();
        } else if (signatures[proof] != signer) {
            // channel completed, both signatures provided
            if (!channel_recipient.send(value)) { // solhint-disable-line
                revert("transaction failed on the very last meter");
            }
            selfdestruct(channel_sender);
            emit Closed();
        }
    }

    /**
     * Timeout this state channel.
     */
    function timeout () public {
        if (start_date + channel_timeout > now) { // solhint-disable-line
            revert("channel timeout");
        }
        selfdestruct(channel_sender);
    }

    function _verify (bytes32 hash, uint8 v, bytes32 r, bytes32 s, address expected_signer)
        internal pure returns (bool) {

        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, hash));
        return ecrecover(prefixedHash, v, r, s) == expected_signer;
    }
}
