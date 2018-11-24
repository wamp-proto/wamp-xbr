.. _GanacheBlockchain:

Ganache
=======

`Ganache <https://truffleframework.com/ganache>`_, one click blockchain:

.. contents:: :local:

---------

Ganache implements a personal (development/test) Ethereum blockchain with the (almost) complete API of a full node.

In particular it implements on the **blockchain read side**:

* ``eth_blockNumber``
* ``eth_estimateGas``
* ``eth_gasPrice``
* ``eth_getBalance``
* ``eth_getBlockByNumber``
* ``eth_getTransactionByHash``
* ``eth_getTransactionReceipt``
* ``eth_getStorageAt``
* ``eth_getLogs``

and on the **blockchain write side**, it provides

* ``eth_sendRawTransaction``: used for submitting client presigned, raw transactions (to talk to SCs)

Ganache is available bundled in two flavors which have different pros/cons:

* `Ganache (GUI) <https://truffleframework.com/ganache>`__
* `Ganache CLI <https://github.com/trufflesuite/ganache-cli>`__

.. note::

    Ganache GUI per default listens on ``http://127.0.0.1:7545``,
    while Ganache CLI will listen on ``http://127.0.0.1:8545``.


Running Ganache GUI
-------------------

Ganache GUI is a desktop application with native user interface (GUI) and
builtin blockchain, all bundled as a single-file executable (AppImage based).

Ganache GUI is available as a single-file executable (AppImage-based). To install:

.. code-block:: console

    cd ~
    wget https://github.com/trufflesuite/ganache/releases/download/v1.2.2/ganache-1.2.2-x86_64.AppImage
    chmod +x ganache-1.2.2-x86_64.AppImage
    sudo cp ./ganache-1.2.2-x86_64.AppImage /usr/local/bin/ganache

and start Ganache GUI

.. code-block:: console

    ganache

Ganache per default will listen (blockchain node RPC endpoint) on ``http://127.0.0.1:7545``.
Here is a screenshot of Ganache GUI with Remix IDE connected:

.. thumbnail:: /_static/screenshots/xbr_payment_channel.png


Running Ganache CLI
-------------------

Ganache CLI is part of the Truffle suite of Ethereum development tools, and is the command line version of Ganache.

.. note::

    Ganache CLI is the TestRPC successor. Truffle has taken TestRPC under its wing and made it part
    of the Truffle suite of tools.

To run Ganache CLI using Docker:

.. code-block:: console

    docker run -d -p 8545:8545 trufflesuite/ganache-cli:latest

To pass in command line parameters to Ganache CLI use this syntax:

.. code-block:: console

    docker run -d -p 8545:8545 trufflesuite/ganache-cli:latest -a 10 --debug

The most important command line arguments to Ganache CLI are:

* ``-p`` or ``--port``: Port number to listen on. Defaults to ``8545``.
* ``-h`` or ``--host`` or ``--hostname``: Hostname to listen on. Defaults to ``127.0.0.1`` (defaults to ``0.0.0.0`` for Docker instances of ``ganache-cli``).
* ``--db``: Specify a path to a directory to save the chain database. If a database already exists, ``ganache-cli`` will initialize that chain instead of creating a new one.
* ``-d`` or ``--deterministic``: Generate deterministic addresses based on a predefined mnemonic.
* ``-m`` or ``--mnemonic``: Use a **bip39 mnemonic phrase** for generating a PRNG seed, which is in turn used for hierarchical deterministic (HD) account generation.
* ``-i`` or ``--networkId``: Specify the network id ``ganache-cli`` will use to identify itself (defaults to the current time or the network id of the forked blockchain if configured)
* ``-a`` or ``--accounts``: Specify the number of accounts to generate at startup.
* ``-e`` or ``--defaultBalanceEther``: Amount of ether to assign each test account. Default is ``100``.

.. code-block:: console

    ganache_1   | Available Accounts
    ganache_1   | ==================
    ganache_1   | (0) 0x90f8bf6a479f320ead074411a4b0e7944ea8c9c1 (~1000 ETH)
    ganache_1   | (1) 0xffcf8fdee72ac11b5c542428b35eef5769c409f0 (~1000 ETH)
    ganache_1   | (2) 0x22d491bde2303f2f43325b2108d26f1eaba1e32b (~1000 ETH)
    ganache_1   | (3) 0xe11ba2b4d45eaed5996cd0823791e0c93114882d (~1000 ETH)
    ganache_1   | (4) 0xd03ea8624c8c5987235048901fb614fdca89b117 (~1000 ETH)
