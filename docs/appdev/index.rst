XBR Application Development
===========================

To interact with the XBR Network, you need to talk the XBR Network smart contracts
that live on the blockchain.
The contracts and their complete public API are documented in :ref:`XBRAPI`.

Here, we show how to use XBR Lib, a client library we provide for JavaScript and
Python that bundles everything you need for a browser or NodeJS application.

.. toctree::
    :maxdepth: 2
    :caption: Contents

    requirements
    connecting
    membership
    markets
    channels
    misc

Typically, a Dapp written in JavaScript using XBR and MetaMask will have the
following call structure when submitting a transaction to the blockchain:

1. **User** ``---(click)--->``
2. **Your app (JavaScript in browser)** ``---(call)--->``
3. **xbr.js / web3.js (injected)** ``---(call)--->``
4. **MetaMask** ``---(user dialog)--->``
5. **User** ``---(click)--->``
6. **MetaMask** ``---(http)--->``
7. **Infura** ``---(native etherum protocol)--->``
8. **Ethereum Mainnet** (the set of worldwide public nodes)
