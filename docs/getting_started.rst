Getting Started
===============

We build on the following toolset:

* `Ganache <https://truffleframework.com/ganache>`_
* `OpenZeppelin Solidity library <https://openzeppelin.org/>`_
* `MetaMask <https://metamask.io/>`_


Docker
------

.. code-block:: console

    #export UID=$(id -u)
    export GID=$(id -g)


Running Ganache
---------------

We will run a local, personal Ethereum blockchain for development using Ganache.

Ganache is avaible bundled in two flavors which have different pros/cons:

* `Ganache (GUI) <https://truffleframework.com/ganache>`_
* `Ganache CLI <https://github.com/trufflesuite/ganache-cli>`

Ganache GUI
...........

The former is a full native desktop application with user interface (GUI) and
builtin blockchain, all bundled as a single-file executable (AppImage based.

To get it:

.. code-block:: console

    cd ~
    wget https://github.com/trufflesuite/ganache/releases/download/v1.2.2/ganache-1.2.2-x86_64.AppImage
    chmod +x ganache-1.2.2-x86_64.AppImage
    sudo cp ./ganache-1.2.2-x86_64.AppImage /usr/local/bin/ganache


Ganache CLI
...........

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
* ``-h`` or ``--host`` or ``--hostname``: Hostname to listen on. Defaults to ``127.0.0.1`` (defaults to ``0.0.0.0`` for Docker instances of ganache-cli).
* ``--db``: Specify a path to a directory to save the chain database. If a database already exists, ganache-cli will initialize that chain instead of creating a new one.
* ``-d`` or ``--deterministic``: Generate deterministic addresses based on a pre-defined mnemonic.
* ``-m`` or ``--mnemonic``: Use a **bip39 mnemonic phrase** for generating a PRNG seed, which is in turn used for hierarchical deterministic (HD) account generation.
* ``-i`` or ``--networkId``: Specify the network id ganache-cli will use to identify itself (defaults to the current time or the network id of the forked blockchain if configured)
* ``-a`` or ``--accounts``: Specify the number of accounts to generate at startup.
* ``-e`` or ``--defaultBalanceEther``: Amount of ether to assign each test account. Default is ``100``.

Ganache implements a personal Ethereum blockchain with the (almost) complete API of a full node.

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

* ``eth_sendRawTransaction``: used for submitting client pre-signed, raw transactions (to talk to SCs)


MetaMask
--------

.. note::

    Http(s) - Web Server Required: Due to browser security restrictions, we can't communicate with
    dapps running on ``file://``. Please use a local server for development.


Remix IDE
---------

To to give the remix web application access to a folder from your
local computer, you can use
`remixd <https://remix.readthedocs.io/en/latest/tutorial_remixd_filesystem.html>_.

Install (globally) by:

.. code-block:: console

    sudo npm install -g remixd

To run:

.. code-block:: console

    remixd -s ${PWD}/contracts



Deploying XBR Smart Contracts
-----------------------------

We will build the XBR protocol smart contracts from Solidity sources and deploy to Ganache.


Truffle
-------

.. note::

    Truffle comes standard with
    `npm integration <https://www.truffleframework.com/docs/truffle/getting-started/package-management-via-npm>`_,
    and is aware of the node_modules directory in your project if it exists. This means you can use and
    distribute contracts, dapps and Ethereum-enabled libraries via npm, making your code available to others
    and other's code available to you.

