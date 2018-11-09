.. _Truffle:

Truffle
=======

.. contents:: :local:


Installation
------------

Install Truffle by

.. code-block:: console

    npm install -g truffle

For a complete intro into the development cycle with Truffle, check out
the `Truffle Quickstart <https://www.truffleframework.com/docs/truffle/quickstart>`_.

The most important Truffle commands are ``truffle compile``, ``truffle test``
and ``truffle migrate``:

.. code-block:: console

    (cpy370_1) oberstet@thinkpad-x1:~/scm/xbr/xbr-protocol$ truffle --help
    Truffle v4.1.14 - a development framework for Ethereum

    Usage: truffle <command> [options]

    Commands:
    init      Initialize new and empty Ethereum project
    compile   Compile contract source files
    migrate   Run migrations to deploy contracts
    deploy    (alias for migrate)
    build     Execute build pipeline (if configuration present)
    test      Run JavaScript and Solidity tests
    debug     Interactively debug any transaction on the blockchain (experimental)
    opcode    Print the compiled opcodes for a given contract
    console   Run a console with contract abstractions and commands available
    develop   Open a console with a local development blockchain
    create    Helper to create new contracts, migrations and tests
    install   Install a package from the Ethereum Package Registry
    publish   Publish a package to the Ethereum Package Registry
    networks  Show addresses for deployed contracts on each network
    watch     Watch filesystem for changes and rebuild the project automatically
    serve     Serve the build directory on localhost and watch for changes
    exec      Execute a JS module within this Truffle environment
    unbox     Download a Truffle Box, a pre-built Truffle project
    version   Show version number and exit

    See more at http://truffleframework.com/docs


.. _Zeppelin:

OpenZeppelin
------------

`OpenZeppelin Solidity library <https://openzeppelin.org/>`_

Install XBR project dependencies by

.. code-block:: console

    npm install

.. note::

    Truffle comes standard with
    `npm integration <https://www.truffleframework.com/docs/truffle/getting-started/package-management-via-npm>`_,
    and is aware of the node_modules directory in your project if it exists. This means you can use and
    distribute contracts, dapps and Ethereum-enabled libraries via npm, making your code available to others
    and other's code available to you.


Compiling XBR contracts
-----------------------

To build the XBR protocol smart contracts from Solidity sources:

.. code-block:: console

    truffle compile

This should produce the ABI artifacts in ``./build/contracts``:

.. code-block:: console

    (cpy370_1) oberstet@thinkpad-x1:~/scm/xbr/xbr-protocol$ ll build/contracts/
    insgesamt 1672
    drwxr-xr-x 2 oberstet oberstet   4096 Nov  9 08:12 ./
    drwxr-xr-x 3 oberstet oberstet   4096 Nov  9 08:12 ../
    -rw-r--r-- 1 oberstet oberstet  50352 Nov  9 08:12 ERC20Detailed.json
    -rw-r--r-- 1 oberstet oberstet 532803 Nov  9 08:12 ERC20.json
    -rw-r--r-- 1 oberstet oberstet  61689 Nov  9 08:12 IERC20.json
    -rw-r--r-- 1 oberstet oberstet  52544 Nov  9 08:12 Migrations.json
    -rw-r--r-- 1 oberstet oberstet 104719 Nov  9 08:12 Roles.json
    -rw-r--r-- 1 oberstet oberstet 127065 Nov  9 08:12 SafeMath.json
    -rw-r--r-- 1 oberstet oberstet  95984 Nov  9 08:12 XBRMaintained.json
    -rw-r--r-- 1 oberstet oberstet 325604 Nov  9 08:12 XBRNetwork.json
    -rw-r--r-- 1 oberstet oberstet  13566 Nov  9 08:12 XBRNetworkProxy.json
    -rw-r--r-- 1 oberstet oberstet 247466 Nov  9 08:12 XBRPaymentChannel.json
    -rw-r--r-- 1 oberstet oberstet  65475 Nov  9 08:12 XBRToken.json

