XBR Application Development
===========================

To interact with the XBR Network, you need to talk the XBR Network smart contracts
that live on the blockchain.
The contracts and their complete public API are documented in :ref:`XBRAPI`.

Here, we show how to use XBR Lib, a client library we provide for JavaScript and
Python that bundles everything you need for a browser or NodeJS application.

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

web3.js is a collection of libraries which allow you to interact with a local
or remote ethereum node, using a HTTP or IPC connection.

Typically, a Dapp using XBR will have the following call structure when
submitting a transaction to the blockchain:

1. **User** ``---(click)--->``
2. **Your app (JavaScript in browser)** ``---(call)--->``
3. **xbr.js / web3.js (injected)** ``---(call)--->``
4. **MetaMask** ``---(user dialog)--->``
5. **User** ``---(click)--->``
6. **MetaMask** ``---(http)--->``
7. **Infura** ``---(native etherum protocol)--->``
8. **Ethereum Mainnet** (the set of worldwide public nodes)

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


Basic Operations
----------------

Connecting to XBR
.................

To use XBR Lib, add a reference to the latest development version we host:

.. code-block:: html

    <script>
        XBR_DEBUG_TOKEN_ADDR = '0x67b5656d60a809915323bf2c40a8bef15a152e3e';
        XBR_DEBUG_NETWORK_ADDR = '0x2612af3a521c2df9eaf28422ca335b04adf3ac66';
    </script>
    <script src="https://xbr.network/lib/xbr.min.js"></script>

.. note::

    As long as we haven't deployed the XBR smart contracts to
    any public network (testnets or mainnet), a user must set the
    addresses of our deployed token and network smart contracts
    on the (private) network the user is connecting to and where
    the XBR contracts need to be deployed.

When using MetaMask, the first thing is to trigger asking the user for access:

.. code-block:: javascript

    // app entry point
    window.addEventListener('load', function () {
        unlock_metamask();
    });

    // check for MetaMask and ask user to grant access to accounts ..
    // https://medium.com/metamask/https-medium-com-metamask-breaking-change-injecting-web3-7722797916a8
    async function unlock_metamask () {
        if (window.ethereum) {
            // if we have MetaMask, ask user for access
            await ethereum.enable();

            // instantiate Web3 from MetaMask as provider
            window.web3 = new Web3(ethereum);
            console.log('ok, user granted access to MetaMask accounts');

            // set new provider on XBR library
            xbr.setProvider(window.web3.currentProvider);
            console.log('library versions: web3="' + web3.version.api + '", xbr="' + xbr.version + '"');

            // now enter main ..
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
    }

You can download the complete exmaple page with above code
:download:`from here </_static/html/xbr_app1.html>`.

When opening this Web page (remember, it needs to served from a Web server,
``file://`` will *not* work), you should see log output like the following
in your browser console:

.. code-block:: console

    ok, user granted access to MetaMask accounts
    xbr_app1.html:30 library versions: web3="0.20.3", xbr="18.11.1"
    xbr_app1.html:46 starting main from account 0x90f8bf6a479f320ead074411a4b0e7944ea8c9c1
    xbr_app1.html:52 account holds 1000000000 XBR
    xbr_app1.html:60 account is already member in the XBR network (level=2)


Congratulations! You are now connected to the XBR Network.

----------


Register in the Network
.......................

All stakeholders or participants in XBR, that is XBR Market Owners, XBR Data Providers and
XBR Data Consumers must be registered in the XBR Network first.

When registering in the XBR Network, users accept the XBR projects terms of use
and legal provisions, and optionally can submit a link to a user profile.

**EULA**

The XBR EULA of the XBR Network with end user license agreement, terms and
legal documents is published by the XBR Project on IPFS, and the current latest
version has the following `Multihash <https://multiformats.io/multihash/>`__ ID:

* XBR EULA on IPFS: ``QmU7Gizbre17x6V2VR1Q2GJEjz6m8S1bXmBtVxS2vmvb81``

Here is how to get the XBR EULA file and unzip the documents:

.. code-block:: console

    oberstet@thinkpad-x1:~$ cd /tmp
    oberstet@thinkpad-x1:/tmp$ ipfs get QmU7Gizbre17x6V2VR1Q2GJEjz6m8S1bXmBtVxS2vmvb81
    Saving file(s) to QmU7Gizbre17x6V2VR1Q2GJEjz6m8S1bXmBtVxS2vmvb81
    1.13 KiB / 1.13 KiB [=======================================================================================================] 100.00% 0s
    oberstet@thinkpad-x1:/tmp$ unzip QmU7Gizbre17x6V2VR1Q2GJEjz6m8S1bXmBtVxS2vmvb81
    Archive:  QmU7Gizbre17x6V2VR1Q2GJEjz6m8S1bXmBtVxS2vmvb81
    creating: xbr-eula/
    inflating: xbr-eula/README.txt
    inflating: xbr-eula/XBR-EULA.txt
    inflating: xbr-eula/COPYRIGHT.txt

**Profile**

When registering on the XBR Network, a user (stakeholder) can have another
IPFS Multihash stored that points to a member profile file.
If provided, the file must be a `RDF/Turtle <https://www.w3.org/TR/turtle/>`__ file
with `FOAF <https://en.wikipedia.org/wiki/FOAF_(ontology)>`__ data.

Here is an example:

.. code-block:: console

    <rdf:RDF
        xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
        xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
        xmlns:foaf="http://xmlns.com/foaf/0.1/"
        xmlns:admin="http://webns.net/mvcb/">
    <foaf:PersonalProfileDocument rdf:about="">
    <foaf:maker rdf:resource="#me"/>
    <foaf:primaryTopic rdf:resource="#me"/>
    <admin:generatorAgent rdf:resource="http://www.ldodds.com/foaf/foaf-a-matic"/>
    <admin:errorReportsTo rdf:resource="mailto:leigh@ldodds.com"/>
    </foaf:PersonalProfileDocument>
    <foaf:Person rdf:ID="me">
    <foaf:name>Tobias Oberstein</foaf:name>
    <foaf:title>Mr</foaf:title>
    <foaf:givenname>Tobias</foaf:givenname>
    <foaf:family_name>Oberstein</foaf:family_name>
    <foaf:nick>oberstet</foaf:nick>
    <foaf:mbox_sha1sum>8c61973dd1948a8ca9f57a153c2502265c7787d8</foaf:mbox_sha1sum>
    <foaf:homepage rdf:resource="https://crossbar.io"/>
    <foaf:workplaceHomepage rdf:resource="https://crossbario.com"/></foaf:Person>
    </rdf:RDF>

.. tip::

    Instead of writing FOAF manually, `FOAF-a-Matic <http://www.ldodds.com/foaf/foaf-a-matic.html>`__
    is a browser-based JavaScript FOAF generator that allow to quickly create FOAF.

Upload your FOAF profile file to IPFS:

.. code-block:: console

    (cpy370_1) oberstet@thinkpad-x1:~$ ipfs add oberstet.rdf
    added QmdeJDNEimpjWPsHCVTDCowQSK9j1tpoW9eW3mjhrTw6wu oberstet.rdf
    3.42 KiB / 3.42 KiB [==========================================================================================================] 100.00%

The multihash ``QmdeJDNEimpjWPsHCVTDCowQSK9j1tpoW9eW3mjhrTw6wu`` returned is what you
provide to ``XBRNetwork.register`` (see below).

.. note::

    If you want to process FOAF (and RDF in general) in Python, we recommend
    `rdflib <https://rdflib.readthedocs.io/en/stable/>`__

Given EULA and Profile, here is how to register in the XBR Network in
Python and JavaScript.

**Python**

.. code-block:: python

    def main(account):
        eula = 'QmU7Gizbre17x6V2VR1Q2GJEjz6m8S1bXmBtVxS2vmvb81'
        profile = 'QmdeJDNEimpjWPsHCVTDCowQSK9j1tpoW9eW3mjhrTw6wu'

        xbr.xbrNetwork.functions.register(eula, profile).transact({'from': account, 'gas': 1000000})

**JavaScript**

.. code-block:: javascript

    async function main (account) {
        const eula = 'QmU7Gizbre17x6V2VR1Q2GJEjz6m8S1bXmBtVxS2vmvb81'
        const profile = 'QmdeJDNEimpjWPsHCVTDCowQSK9j1tpoW9eW3mjhrTw6wu'

        await xbr.xbrNetwork.register(eula, profile, {from: account});
    }

To check for the membership level of an address, you can use :sol:func:`XBRNetwork.getMemberLevel`.

**Python**

.. code-block:: python

    def main(account):

        level = xbr.xbrNetwork.functions.getMemberLevel(account).call()
        if (level):
            print('account is already member in the XBR network (level={})'.format(level))
        else:
            print('account is not yet member in the XBR network')

**JavaScript**

.. code-block:: javascript

    async function main (account) {

        const level = await xbr.xbrNetwork.getMemberLevel(account);
        if (level > 0) {
            console.log('account is already member in the XBR network (level=' + level + ')');
        } else {
            console.log('account is not yet member in the XBR network');
        }
    }

--------


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
