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
    mapping (bytes32 => address) signatures;

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
     * FIXME
     */
    function XBRPaymentChannel (bytes32 _market_id, address to, uint timeout) public payable {
        market_id = _market_id;
        channel_recipient = to;
        channel_sender = msg.sender;
        start_date = now;
        channel_timeout = timeout;
    }

    /**
     * FIXME
     */
    function close (bytes32 h, uint8 v, bytes32 r, bytes32 s, uint value) public {

        address signer;
        bytes32 proof;

        // get signer from signature
        signer = ecrecover(h, v, r, s);

        if (signer != channel_sender && signer != channel_recipient) {
            revert("invalid signature");
        }

        proof = sha3(this, value);

        if (proof != h) {
            revert("invalid signature (signature is valid but doesn't match the data provided)");
        }

        if (signatures[proof] == 0) {
            signatures[proof] = signer;
            emit Closing();
        }
        else if (signatures[proof] != signer) {
            // channel completed, both signatures provided
            if (!channel_recipient.send(value)) {
                revert("transaction failed on the very last meter");
            }
            selfdestruct(channel_sender);
            emit Closed();
        }
    }

    /**
     * FIXME
     */
    function timeout () public {
        if (start_date + channel_timeout > now) {
            revert("channel timeout");
        }
        selfdestruct(channel_sender);
    }
}
