Payment Channels
================

.. contents:: :local:

----------

Opening Payment Channels
------------------------

After a XBR Consumer has joined a XBR Market, it needs to open a payment channel
to allow a delegate to spend XBR tokens to buy data services.
The buying of data services happens in microtransactions in real-time and off-chain.
The XBR token to be spent offchain by the XBR Consumer delegate will be consumed
from the payment channel opened previously.
The payment channel is always *from* a XBR Consumer *to* a XBR Market, or
*from* a XBR Market *to* a XBR Provider.
Both parties in a payment channel can request to close the channel at any
time (see below, "Closing Payment Channels").

Opening a payment channel involves two blockchain transactions:

1. approve the transfer of XBR token from the user to the ``XBRNetwork`` smart contract
2. call ``XBRNetwork.openPaymentChannel``, which will create a new ``XBRPaymentChannel``
   smart contract instance, transferring the tokens to this SC instance as new owner
   and return the payment channel contract instance

The returned new smart contract instance of ``XBRPaymentChannel`` can be
directly received and further operated on when calling from Solidity,
but not JavaScript.
In JavaScript, blockchain *transactions* always only return the **transaction receipt**,
*not* the result of the called smart contract function.
To receive the address of the dynamically created new smart contract instance
of ``XBRPaymentChannel``, we instead subscribe to receive blockchain events published
by ``XBRNetwork``.

Open a payment channel in JavaScript
....................................

To open a payment channel in JavaScript, approve the token transfer, call into
``XBRNetwork``, and subscribe to the ``PaymentChannelCreated`` event:

.. code-block:: javascript

    async function main (account) {

        // derive (deterministically) an ID for our market
        const marketId = web3.sha3('MyMarket1').substring(0, 34);

        // consumer delegate of the channel
        const consumer = '0x...';

        const success = await xbr.xbrToken.approve(xbr.xbrNetwork.address,
                                                   amount,
                                                   {from: account});

        if (!success) {
            throw 'transfer was not approved';
        }

        var watch = {
            tx: null
        }

        const options = {};
        xbr.xbrNetwork.PaymentChannelCreated(options, function (error, event)
            {
                console.log('PaymentChannelCreated', event);
                if (event) {
                    if (watch.tx && event.transactionHash == watch.tx) {
                        console.log('new payment channel created: marketId=' + event.args.marketId + ', channel=' + event.args.channel + '');
                    }
                }
                else {
                    console.error(error);
                }
            }
        );

        console.log('test_open_payment_channel(marketId=' + marketId + ', consumer=' + consumer + ', amount=' + amount + ')');

        // bytes32 marketId, address consumer, uint256 amount
        const tx = await xbr.xbrNetwork.openPaymentChannel(marketId,
                                                           consumer,
                                                           amount,
                                                           {from: account});

        console.log(tx);

        watch.tx = tx.tx;

        console.log('transaction completed: tx=' + tx.tx + ', gasUsed=' + tx.receipt.gasUsed);

    }


Requesting Paying Channels
--------------------------

XBR Providers are directly paid by XBR Market Makers, which transaction purchases triggered
from XBR Consumers.

To get paid, XBR Provider will need to first request a XBR Paying Channel.
The XBR Market Maker on the market listens on such requests, and will automatically open
a XBR Payment Channel payable to the XBR Provider that requested a paying channel.
The XBR Provider must have deposited sufficient security amount (deposited by the data provider
when joining the marker) to cover the requested amount in the paying channel.

The market maker will open a payment (state) channel to allow the market maker buying data keys in
microtransactions, and offchain. The creation of the payment channel is asynchronously: the market maker
is watching the global blockchain filtering for events relevant to the market managed by the maker.
When a request to open a payment channel is recognized by the market maker, it will check the provider
for sufficient security despite covering the requested amount, and if all is fine, create a new payment
channel and store the contract address for the channel request ID, so the data provider can retrieve it.

Request a paying channel in JavaScript
......................................

To request a paying channel (as a XBR Provider):

.. code-block:: javascript

    async function main (account) {

        // derive (deterministically) an ID for our request
        const payingChannelRequestId = web3.sha3('MyPayingChannelRequest1').substring(0, 34);

        // derive (deterministically) an ID for our market
        const marketId = web3.sha3('MyMarket1').substring(0, 34);

        // provider delegate address of the channel
        const provider = '0x...';

        /// request amount
        const amount = 100 * 10**18;

        await xbr.xbrNetwork.requestPayingChannel(payingChannelRequestId,
                                                  marketId,
                                                  provider,
                                                  amount,
                                                  {from: account});
    }


Closing Payment Channels
------------------------
