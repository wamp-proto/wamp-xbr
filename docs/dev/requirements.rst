Requirements
============

.. contents:: :local:

----------

Blockchain Network
------------------

An Ethereum network consists of one or more nodes speaking the Ethereum protocol, and interconnected.
To connect to a specific Ethereum network, one can connect to any node already in the network using
the URL of the node.

In development, these URLs are most common:

* connect to *local Ganache ("GUI"*): ``http://127.0.0.1:7545``
* connect to *local Ganache CLI*: ``http://127.0.0.1:8545``

In test and production, these are the URLs for `Infura <https://infura.io/>`_ as a public blockchain gateway
and using HTTP endpoints:

* connect to *Ethereum Mainnet*: ``https://mainnet.infura.io/v3/<YOUR-PROJECT-ID>``
* connect to *Ropsten Testnet*: ``https://ropsten.infura.io/v3/<YOUR-PROJECT-ID>``
* connect to *Rinkeby Testnet*: ``https://rinkeby.infura.io/v3/<YOUR-PROJECT-ID>``

and for `WebSocket endpoints <https://infura.io/docs/ethereum/wss/introduction>`_:

* connect to *Ethereum Mainnet*: ``wss://mainnet.infura.io/ws/v3/YOUR-PROJECT-ID``
* connect to *Ropsten Testnet*: ``wss://ropsten.infura.io/ws/v3/YOUR-PROJECT-ID``
* connect to *Rinkeby Testnet*: ``wss://rinkeby.infura.io/ws/v3/YOUR-PROJECT-ID``

.. note::

    To use Infura and get a project ID for use in above URLs you will need
    to `register at Infura <https://infura.io/register>`__, which is free,
    non-intrusive and quick. Infura is widely used and trusted in the
    Ethereum world.

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

* ``0``: Olympic, Ethereum public preview release testnet
* ``1``: Frontier, Homestead, Metropolis, **the Ethereum public main network**
* ``1``: Classic, the public Ethereum Classic main network, chain ID 61
* ``1``: Expanse, an alternative Ethereum implementation, chain ID 2
* ``2``: Morden, the public Ethereum testnet, now Ethereum Classic testnet
* ``3``: **Ropsten, the public cross-client Ethereum testnet**
* ``4``: **Rinkeby, the public Geth PoA testnet**
* ``8``: Ubiq, the public Gubiq main network with flux difficulty chain ID 8
* ``42``: Kovan, the public Parity PoA testnet
* ``77``: Sokol, the public POA Network testnet
* ``99``: Core, the public POA Network main network
* ``100``: xDai, the public MakerDAO/POA Network main network
* ``5777``: **network ID used for XBR testing on private networks**


Web3 Client Library
-------------------

Web3 is a collection of libraries which allow you to interact with a local
or remote ethereum node, using a HTTP or IPC connection.

Web3 for JavaScript
...................

The documentation for Web3 (JavaScript) can be found here:

* `web3 v0.x <https://github.com/ethereum/wiki/wiki/JavaScript-API>`_: this is what the MetaMask injected Web3 provides
* `web3.js v1.0+ <https://web3js.readthedocs.io/en/1.0/index.html>`_: this is the latest standalone Web3 (e.g. usable for NodeJS)

.. note::

    The original "Web3" library is for JavaScript, currently at a version <1.0 and working synchronously (callbacks).
    Then there is the upcoming v1.0 milestone of Web3 that also has an asynchronous, promise/await/async style API.
    Further, for JavaScript within the browser specifically, this often means integration with
    `MetaMask <https://metamask.io/>`_. And MetaMask bundles its own Web3 version (and only seem to work with that),
    which is at version <1.0.


Metamask with ``Web3.js 1.0.0`` AND the old ``Web3.js``
https://guillaumeduveau.com/en/blockchain/ethereum/metamask-web3



Web3 for Python
...............

For Python, there is `Web3.py <https://web3py.readthedocs.io/en/stable/>`_,
a Python interface for interacting with the Ethereum blockchain and ecosystem
which closely follows the JavaScript Web3 API.

To install:

.. code-block:: console

    pip install web3

.. tip::

    Unfortunately, ``Web3.py`` is a synchronous, blocking library. It uses `requests <http://docs.python-requests.org/en/master/>`_
    under the hood for talking to HTTP endpoints of blockchain nodes, so all blockchain interactions via ``Web3.py`` need
    to be run on a background worker threadpool.
    ``Web3.py`` plans to introduce an async/await friendly API into web3 with version 5.
    See `here <https://github.com/ethereum/web3.py/issues/1055>`__


XBR Client Library
------------------

The XBR Protocol - at its core - is made of the XBR smart contracts, and the
primary artifacts built are the contract ABI files (in ``./build/contracts/*.json``).

Technically, these files are all you need to interact and talk to the XBR
smart contracts.

However, doing it that way (using the raw ABI files and presumably some generic
Ethereum library) is cumbersome and error prone to maintain.

Therefore, we create wrapper libraries for XBR, currently for Python and JavaScript,
that make interaction with XBR contract super easy.

The libraries are available here:

* `XBR client library for Python <https://pypi.org/project/xbr/>`__
* `XBR client library for JavaScript <https://xbr.network/lib/xbr.min.js>`__

The use of the XBR client library is explained in the following sections.


XBR Lib for JavaScript
......................

To use XBR Lib for JavaScript (in a browser Dapp), add a reference to the
latest development version we host:

.. code-block:: html

    <script>
        XBR_DEBUG_TOKEN_ADDR = '0x67b5656d60a809915323bf2c40a8bef15a152e3e';
        XBR_DEBUG_NETWORK_ADDR = '0x2612af3a521c2df9eaf28422ca335b04adf3ac66';
    </script>
    <script src="https://xbr.network/lib/xbr.min.js"></script>

Then to use

.. code-block:: javascript

    xbr.setProvider(window.web3.currentProvider);

.. note::

    As long as we haven't deployed the XBR smart contracts to
    any public network (testnets or mainnet), a user must set the
    addresses of our deployed token and network smart contracts
    on the (private) network the user is connecting to and where
    the XBR contracts need to be deployed.


XBR Lib for Python
..................

XBR Lib for Python is `published on PyPI <https://pypi.org/project/xbr/>`__ and
can be installed:

.. code-block:: console

    pip install xbr

To use XBR Lib for Python, export the following environment variables

.. code-block:: console

    export XBR_DEBUG_TOKEN_ADDR="0x67b5656d60a809915323bf2c40a8bef15a152e3e"
    export XBR_DEBUG_NETWORK_ADDR="0x2612af3a521c2df9eaf28422ca335b04adf3ac66"

import the library and set the Web3 provider:

.. code-block:: python

    import xbr
    from web3.auto import w3

    xbr.setProvider(w3)
