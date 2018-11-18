Markets
=======

.. contents:: :local:

----------

Creating Markets
----------------

After registering in the XBR Network, stakeholders that want to run their own
data markets will first need to create a XBR Market.

JavaScript
..........

.. code-block:: javascript

    async function main (account) {

        // marketId (like all IDs in XBR) is a 128 bit (16 bytes) unique value
        // here, we derive a deterministic ID from a name. other approaches to
        // get an ID are fine too - as long as the ID is unique
        const marketId = web3.sha3('MyMarket1').substring(0, 34);

        // every market has exactly one delegate working as a market maker delegate
        // the market maker maintains the real-time offchain balances, mediates
        // the actual data market transactions and talks to the blockchain
        const maker = '0x...';

        // optionally, provide an IPFS link to a ZIP file with market terms/documents
        const terms = '';

        // optionally, provide an IPFS link to a RDF/Turtle file with market metadata
        const meta = '';

        // both XBR Consumers and Providers must deposit 100 XBR into the
        // market as a security guarantee when joining
        const providerSecurity = 100 * 10**18;
        const consumerSecurity = 100 * 10**18;

        // the market owner takes 5% market fee
        const marketFee = 0.05 * 10**9 * 10**18

        // now actually create the market. the sender will become market owner.
        await xbr.xbrNetwork.createMarket(marketId, terms, meta, maker,
            providerSecurity, consumerSecurity, marketFee, {from: account});
    }


Joining Markets
---------------

XBR Provider that want to offer or XBR Consumer that wants to use data services
in a XBR Market first need to join the respective XBR Market.

A given actor (address) can only be joined on a given XBR Market only once,
under one role of these roles:

* ``XBRNetwork.ActorType.CONSUMER``
* ``XBRNetwork.ActorType.PROVIDER``

The actor may join more than one XBR Market (under the same or different roles),
but on one given XBR Market, it can only act as either a XBR Consumer or Provider.

.. note::

    The XBR Market owner is automatically joined under role ``XBRNetwork.ActorType.MARKET``
    when the market is created.

JavaScript
..........

To join a XBR Market in JavaScript:

.. code-block:: javascript

    async function main (account) {

        // derive (deterministically) an ID for our market
        const marketId = web3.sha3('MyMarket1').substring(0, 34);

        // join under role XBR Consumer
        const actorType = xbr.ActorType.CONSUMER;
        // const actorType = xbr.ActorType.PROVIDER;

        // join the market
        await xbr.xbrNetwork.joinMarket(marketId, xbr.ActorType.CONSUMER, {from: account});
    }
