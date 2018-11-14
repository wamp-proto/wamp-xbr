XBR Application Development
===========================

To interact with the XBR Network, you need to talk the XBR Network smart contracts
that live on the blockchain.

The contracts and their complete public API are documented in :ref:`XBRAPI`.

Here, we show how to XBR Lib, a client library for JavaScript that bundles everything
you need for a browser or NodeJS application.

.. contents:: :local:

--------

Background
----------

Blockchain Networks
...................

An Ethereum network consists of one or more nodes speaking the Ethereum protocol, and interconnected.

To connect to a specific Ethereum network, one can connect to any node already in the network using
the URL of the node.

In development, these URLs are most common:

* Ganache ("GUI"): ``http://127.0.0.1:7545``
* Ganache CLI: ``http://127.0.0.1:8545``

In test and production, these are the URLs for `Infura <https://infura.io/>`_ as a public blockchain gateway:

* Mainnet: ``https://mainnet.infura.io/v3/<YOUR-PROJECT-ID>``
* Ropsten: ``https://ropsten.infura.io/v3/<YOUR-PROJECT-ID>``
* Rinkeby: ``https://rinkeby.infura.io/v3/<YOUR-PROJECT-ID>``

and for `WebSocket endpoints <https://infura.io/docs/ethereum/wss/introduction>`_:

* Mainnet: ``wss://mainnet.infura.io/ws/v3/YOUR-PROJECT-ID``
* Ropsten: ``wss://ropsten.infura.io/ws/v3/YOUR-PROJECT-ID``
* Rinkeby: ``wss://rinkeby.infura.io/ws/v3/YOUR-PROJECT-ID``


Once connected to a network, the node can be asked for the Ethereum network ID (the node is being part of):

**Python**

.. code-block:: python

    from web3.auto import w3
    if w3.isConnected():
        print('connected to network={}'.format(w3.version.network))

**JavaScript**

.. code-block:: javascript

    web3.version.network

Here is a list of Ethereum networks known (see `here <https://ethereum.stackexchange.com/a/17101>`__):

* ``0``: Olympic, Ethereum public pre-release testnet
* ``1``: Frontier, Homestead, Metropolis, **the Ethereum public main network**
* ``1``: Classic, the (un)forked public Ethereum Classic main network, chain ID 61
* ``1``: Expanse, an alternative Ethereum implementation, chain ID 2
* ``2``: Morden, the public Ethereum testnet, now Ethereum Classic testnet
* ``3``: **Ropsten, the public cross-client Ethereum testnet**
* ``4``: **Rinkeby, the public Geth PoA testnet**
* ``8``: Ubiq, the public Gubiq main network with flux difficulty chain ID 8
* ``42``: Kovan, the public Parity PoA testnet
* ``77``: Sokol, the public POA Network testnet
* ``99``: Core, the public POA Network main network
* ``100``: xDai, the public MakerDAO/POA Network main network
* ``401697``: Tobalaba, the public Energy Web Foundation testnet
* ``7762959``: Musicoin, the music blockchain
* ``61717561``: Aquachain, ASIC resistant chain
* ``[Other]``: Could indicate that your connected to a local development test network.


Web3 Client Library
...................

**JavaScript**

The original "Web3" library is for JavaScript, currently at a version <1.0 and working synchronously (callbacks).

Then there is the upcoming v1.0 milestone of Web3 that also has an asynchronous, promise/await/async style API.

Further, for JavaScript within the browser specifically, this often means integration with
`MetaMask <https://metamask.io/>`_. And MetaMask bundles its own Web3 version (and only seem to work with that),
which is at version <1.0.

The documentation for Web3 (JavaScript) <v1.0 and v1.0+ can be found here:

* `web3 0.x.x <https://github.com/ethereum/wiki/wiki/JavaScript-API>`_: this is what the MetaMask injected Web3 provides
* `web3.js 1.0 <https://web3js.readthedocs.io/en/1.0/index.html>`_: this is the latest standalone Web3 (eg usable for NodeJS)

**Python**

For Python, there ia `Web3.py <https://web3py.readthedocs.io/en/stable/>`_ which closely follows the JavaScript Web3 <v1.0 API.

Unfortunately, Web3.py is a synchronous, blocking library. It uses `requests <http://docs.python-requests.org/en/master/>`_
under the hood for talking to HTTP endpoints of blockchain nodes, so all blockchain interactions via Web3.py need
to be run on a background worker threadpool.

.. note::

    Web3.py plans to introduce an async/await friendly API into web3 with version 5.
    See `here <https://github.com/ethereum/web3.py/issues/1055>`__


Interacting with XBR
--------------------

To use XBR Lib, add a reference to the latest development version we host:

.. code-block:: html

    <script src="https://xbr.network/lib/xbr.min.js"></script>

When using MetaMask, the first thing is to trigger asking the user for access:

.. code-block:: javascript

    // entry point: asks user to grant access to MetaMask ..
    async function unlock () {

        if (window.ethereum) {
            // if we have MetaMask, ask user for access
            await ethereum.enable();

            // instantiate Web3 from MetaMask as provider
            window.web3 = new Web3(ethereum);
            console.log('ok, user granted access to MetaMask accounts');

            // set new provider on XBR library
            xbr.setProvider(window.web3.currentProvider);
            console.log('library versions: web3="' + web3.version.api + '", xbr="' + xbr.version + '"');

            // now start main from the first account ..
            await main(web3.eth.accounts[0]);

        } else {
            // no MetaMask (or other modern Ethereum integrated browser) .. redirect
            var win = window.open('https://metamask.io/', '_blank');
            if (win) {
                win.focus();
            }
        }
    }

Above will jump into `main()` when the user has granted access. Below is an example where
we ask for the current XBR balance of the user account, and the XBR Network membership level:

.. code-block:: javascript

    // main app: this runs with the 1st MetaMask account (given the user has granted access)
    async function main (account) {
        console.log('starting main from account ' + account);

        // ask for current balance in XBR
        var balance = await xbr.xbrToken.balanceOf(account);
        if (balance > 0) {
            balance = balance / 10**18;
            console.log('account holds ' + balance + ' XBR');
        } else {
            console.log('account does not hold XBR currently');
        }

        // ask for XBR network membership level
        const level = await xbr.xbrNetwork.getMemberLevel(account);
        if (level > 0) {
            console.log('account is already member in the XBR network (level=' + level + ')');
        } else {
            console.log('account is not yet member in the XBR network');
        }
    }

.. figure:: /_static/screenshots/xbr_client_connect.png
    :align: center
    :alt: Connecting to XBR
    :figclass: align-center

    Connecting to XBR


Register in the Network
.......................

All stakeholders or participants in XBR, that is XBR Market Owners, XBR Data Providers and
XBR Data Consumers must be registered in the XBR Network first.

**Python**

    account = w3.eth.accounts[0]

    xbr.xbrNetwork.functions.register(eula, profile).transact({'from': account, 'gas': 1000000})

**JavaScript**

.. code-block:: javascript

    const account = web3.eth.accounts[0];

    await xbr.xbrNetwork.register(eula, profile, {from: account});

The `eula` is the SHA3 of the (latest published) ZIP archive with the XBR Network end user
license and legal documents


Open a Market
.............

Join a Market
.............

Open Payment Channels
.....................

Request Paying Channels
.......................

Close Payment Channels
......................


Other
-----

Cryptographic Hashing
.....................

Ethereum widely uses Keccak 256 bit hashes - which are almost, but not completely
the same as SHA3-256 hashes.

You can use Web3.js to compute hashes in `JavaScript <https://web3js.readthedocs.io/en/1.0/web3-utils.html#sha3>`_:

.. code-block:: console

    web3.sha3('hello');
    "0x1c8aff950685c2ed4bc3174f3472287b56d9517b9c948127319a09a7a36deac8"

For Python, Web3.py provides similar `functionality <https://web3py.readthedocs.io/en/stable/overview.html?highlight=Web3.sha3#cryptographic-hashing>`_:

.. code-block:: python

    >>> import web3
    >>> web3.Web3.sha3('hello'.encode('utf8'))
    HexBytes('0x1c8aff950685c2ed4bc3174f3472287b56d9517b9c948127319a09a7a36deac8')
