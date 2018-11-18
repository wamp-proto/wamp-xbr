.. _MetaMask:

MetaMask
========

.. contents:: :local:

.. note::

    A Web (HTTP(S)) server is required also for local development:
    due to browser security restrictions, MetaMask can't communicate with
    dapps running on ``file://``. Please use a local server for development.


Installing MetaMask
-------------------

Install MetaMask from `here <https://metamask.io>`_ or by opening the extension management in your browser.

.. figure:: /_static/screenshots/metamask_install.png
    :align: center
    :alt: Install MetaMask
    :figclass: align-center

    Install MetaMask for Chrome, Firefox or Opera


MetaMask with Ganache CLI
-------------------------

Generate a new seed phrase or import one:

.. figure:: /_static/screenshots/metamask_import_seedphrase.png
    :align: center
    :alt: Importing your seed phrase in MetaMask
    :figclass: align-center

    Importing a seed phrase in MetaMask

Create a total of 6 accounts:

.. figure:: /_static/screenshots/metamask_create_account.png
    :align: center
    :alt: Create an account
    :figclass: align-center

    Create an account

At the end, you should see your list of accounts switchable by clicking the top right account logo:

.. figure:: /_static/screenshots/metamask_accounts.png
    :align: center
    :alt: List of switchable accounts
    :figclass: align-center

    List of switchable accounts

Connect to the locally running Ganache CLI test blockchain at ``http://localhost:8545``:

.. figure:: /_static/screenshots/metamask_network_connect.png
    :align: center
    :alt: Connecting to Ganache
    :figclass: align-center

    Connecting to Ganache CLI


MetaMask with Ganache GUI
-------------------------

Start Ganache GUI, copy and import the seed phrase into MetaMask:

.. figure:: /_static/screenshots/ganache_gui_metamask_seedphrase.png
    :align: center
    :alt: Importing Ganache GUI seedphrase in MetaMask
    :figclass: align-center

    Importing Ganache GUI seedphrase in MetaMask

Connect to the locally running Ganache CLI test blockchain at ``http://localhost:7545``:

.. figure:: /_static/screenshots/ganache_gui_metamask_network.png
    :align: center
    :alt: Connecting to Ganache
    :figclass: align-center

    Connecting to Ganache CLI


Creating XBR Test Accounts
--------------------------

For testing, create the following accounts in MetaMask:

=========  ======================
Account    Actor / Stakeholder
=========  ======================
Account 1  The XBR project
Account 2  XBR Market Maker M1
Account 3  XBR Data Provider P1
Account 4  XBR Data Provider P2
Account 5  XBR Data Consumer C1
Account 6  XBR Data Consumer C2
=========  ======================

**Account 1** (The XBR project) is used to deploy the XBR Protocol smart contracts.

**Account 2** (XBR Market Maker M1) will call smart contract functions:

* ``XBRNetwork.register`` to register in the XBR network
* ``XBRNetwork.open_market`` to open a new market

**Account 3/4** (XBR Data Provider P1/P2) will call smart contract functions:

* ``XBRNetwork.register`` to register in the XBR network
* ``XBRNetwork.join_market`` to join a market, depositing an amount of XBR token as a security and for the market maker to open a payment channel with this data provider
* ``XBRNetwork.request_channel`` to request a payment channel receiving money from the market maker, depositing an amount of XBR token. this returns a new ``XBRPaymentChannel`` SC
* ``XBRPaymentChannel.close`` to close a payment channel.

Select **Account 5/6** (XBR Data Consumer C1/C2) will call smart contract functions:

* ``XBRNetwork.register`` to register in the XBR network
* ``XBRNetwork.join_market`` to join a market, depositing an amount of XBR token as a security
* ``XBRNetwork.open_channel`` to open a payment channel, depositing an amount of XBR token. this returns a new ``XBRPaymentChannel`` SC
* ``XBRPaymentChannel.close`` to close a payment channel.


Call Structure and Control Flow
-------------------------------

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
