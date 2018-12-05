.. _InitialSetup:



Initial Setup
-------------

.. contents:: :local:


Install Requirements
====================


Install the global requirements by doing

.. code-block:: console

    make requirements

.. note::

    Most of the toolchains here are Node.js based. We are using the Ubuntu 18.04 system version of this (8.10.0), and more current versions may cause problems!

Then install additional dependencies in a Python virtualenv (here the system Python on Ubuntu 18.04 is too old, which can e.g. be solved by building Python from sources).

.. code-block:: console

    make install
    make install_python


Set Up ganache
==============

For development and testing, you need ganache running and set up with test accounts and the XBR contracts deployed.

To run ganache do

.. code-block:: console

    make run_ganache_cli

.. note::

    You may need to set ownership and rights for the ganache directory by doing e.g. `sudo chown -R goeddea:goeddea teststack/ganache/.data` and `chmod 755 teststack/ganache/.data/`

The above sets up ganache with a default set of accounts, and results in a determined initial state.

You should get the output

.. code-block:: console

    ganache_1   | Ganache CLI v6.1.8 (ganache-core: 2.2.1)
    ganache_1   |
    ganache_1   | Available Accounts
    ganache_1   | ==================
    ganache_1   | (0) 0x90f8bf6a479f320ead074411a4b0e7944ea8c9c1 (~1000 ETH)
    ganache_1   | (1) 0xffcf8fdee72ac11b5c542428b35eef5769c409f0 (~1000 ETH)
    ganache_1   | (2) 0x22d491bde2303f2f43325b2108d26f1eaba1e32b (~1000 ETH)
    ganache_1   | (3) 0xe11ba2b4d45eaed5996cd0823791e0c93114882d (~1000 ETH)
    ganache_1   | (4) 0xd03ea8624c8c5987235048901fb614fdca89b117 (~1000 ETH)
    ganache_1   | (5) 0x95ced938f7991cd0dfcb48f0a06a40fa1af46ebc (~1000 ETH)
    ganache_1   | (6) 0x3e5e9111ae8eb78fe1cc3bb8915d5d461f3ef9a9 (~1000 ETH)
    ganache_1   | (7) 0x28a8746e75304c0780e011bed21c72cd78cd535e (~1000 ETH)
    ganache_1   | (8) 0xaca94ef8bd5ffee41947b4585a84bda5a3d3da6e (~1000 ETH)
    ganache_1   | (9) 0x1df62f291b2e969fb0849d99d9ce41e2f137006e (~1000 ETH)
    ganache_1   | (10) 0x610bb1573d1046fcb8a70bbbd395754cd57c2b60 (~1000 ETH)
    ganache_1   | (11) 0x855fa758c77d68a04990e992aa4dcdef899f654a (~1000 ETH)
    ganache_1   | (12) 0xfa2435eacf10ca62ae6787ba2fb044f8733ee843 (~1000 ETH)
    ganache_1   | (13) 0x64e078a8aa15a41b85890265648e965de686bae6 (~1000 ETH)
    ganache_1   | (14) 0x2f560290fef1b3ada194b6aa9c40aa71f8e95598 (~1000 ETH)
    ganache_1   |
    ganache_1   | Private Keys
    ganache_1   | ==================
    ganache_1   | (0) 0x4f3edf983ac636a65a842ce7c78d9aa706d3b113bce9c46f30d7d21715b23b1d
    ganache_1   | (1) 0x6cbed15c793ce57650b9877cf6fa156fbef513c4e6134f022a85b1ffdd59b2a1
    ganache_1   | (2) 0x6370fd033278c143179d81c5526140625662b8daa446c22ee2d73db3707e620c
    ganache_1   | (3) 0x646f1ce2fdad0e6deeeb5c7e8e5543bdde65e86029e2fd9fc169899c440a7913
    ganache_1   | (4) 0xadd53f9a7e588d003326d1cbf9e4a43c061aadd9bc938c843a79e7b4fd2ad743
    ganache_1   | (5) 0x395df67f0c2d2d9fe1ad08d1bc8b6627011959b79c53d7dd6a3536a33ab8a4fd
    ganache_1   | (6) 0xe485d098507f54e7733a205420dfddbe58db035fa577fc294ebd14db90767a52
    ganache_1   | (7) 0xa453611d9419d0e56f499079478fd72c37b251a94bfde4d19872c44cf65386e3
    ganache_1   | (8) 0x829e924fdf021ba3dbbc4225edfece9aca04b929d6e75613329ca6f1d31c0bb4
    ganache_1   | (9) 0xb0057716d5917badaf911b193b12b910811c1497b5bada8d7711f758981c3773
    ganache_1   | (10) 0x77c5495fbb039eed474fc940f29955ed0531693cc9212911efd35dff0373153f
    ganache_1   | (11) 0xd99b5b29e6da2528bf458b26237a6cf8655a3e3276c1cdc0de1f98cefee81c01
    ganache_1   | (12) 0x9b9c613a36396172eab2d34d72331c8ca83a358781883a535d2941f66db07b24
    ganache_1   | (13) 0x0874049f95d55fb76916262dc70571701b5c4cc5900c0691af75f1a8a52c8268
    ganache_1   | (14) 0x21d7212f3b4e5332fd465877b64926e3532653e2798a11255a46f533852dfe46
    ganache_1   |
    ganache_1   | HD Wallet
    ganache_1   | ==================
    ganache_1   | Mnemonic:      myth like bonus scare over problem client lizard pioneer submit female collect
    ganache_1   | Base HD Path:  m/44'/60'/0'/0/{account_index}
    ganache_1   |
    ganache_1   | Gas Price
    ganache_1   | ==================
    ganache_1   | 1
    ganache_1   |
    ganache_1   | Gas Limit
    ganache_1   | ==================
    ganache_1   | 17592186044415


Deploy the XBR Contracts
========================

To deploy the XBR contracts to ganache do

.. code-block:: console

    make deploy

This should give you output like

.. code-block:: console

    truffle compile --all
    Compiling ./contracts/Migrations.sol...
    Compiling ./contracts/XBRMaintained.sol...
    Compiling ./contracts/XBRNetwork.sol...
    Compiling ./contracts/XBRNetworkProxy.sol...
    Compiling ./contracts/XBRPaymentChannel.sol...
    Compiling ./contracts/XBRToken.sol...
    Compiling openzeppelin-solidity/contracts/access/Roles.sol...
    Compiling openzeppelin-solidity/contracts/cryptography/ECDSA.sol...
    Compiling openzeppelin-solidity/contracts/math/SafeMath.sol...
    Compiling openzeppelin-solidity/contracts/token/ERC20/ERC20.sol...
    Compiling openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol...
    Compiling openzeppelin-solidity/contracts/token/ERC20/IERC20.sol...
    Writing artifacts to ./build/contracts

    truffle migrate --reset --network ganache
    Using network 'ganache'.

    Running migration: 1_initial_migration.js
    Deploying Migrations...
    ... 0xf481b474a2796341b3baa09621f0af314f5c231c5480c362f8a2273a6143eda2
    Migrations: 0xe78a0f7e598cc8b0bb87894b0f60dd2a88d6a8ab
    Saving successful migration to network...
    ... 0xc46707af8e58be774a7dcd2896aed1b063884e2bd7e9aa32e3f3a39d65fcada0
    Saving artifacts...
    Running migration: 2_deploy_contracts.js
    gas set to 6721975 on network ganache
    Deploying XBRToken...
    ... 0x52404bf8a84c3bf34273f21cc6b4a941609e4a4dd7d611b72d243d5809cbbbb9
    XBRToken: 0xcfeb869f69431e42cdb54a4f4f105c19c080a601
    Deploying XBRNetwork...
    ... 0xcdb5abd9c01f0a4fde847902ebc78c2a77d15b45e40faded24bf239161e7df97
    XBRNetwork: 0x254dffcd3277c0b1660f6d42efbb754edababc2b
    Saving successful migration to network...
    ... 0x55d81aa99eb9b4da8e5408ece477658e9f6c8b2bc9988aa9c5be7f2bd34c25e0
    Saving artifacts...

You should also see activity in the ganache log, e.g.

.. code-block:: console

    ganache_1   |   Transaction: 0xf481b474a2796341b3baa09621f0af314f5c231c5480c362f8a2273a6143eda2
    ganache_1   |   Contract created: 0xe78a0f7e598cc8b0bb87894b0f60dd2a88d6a8ab
    ganache_1   |   Gas usage: 224195
    ganache_1   |   Block Number: 1
    ganache_1   |   Block Time: Tue Dec 04 2018 12:42:44 GMT+0000 (UTC)


Setting up MetaMask
===================

You need MetaMask installed in your browser. After installing (from https://metamask.io/), we import the test account using the same seed phrase that is used in setting up ganache_1

.. code-block:: console

    myth like bonus scare over problem client lizard pioneer submit female collect

Then you connect MetaMask to our ganache blockchain - select "Localhost 8545" from the dropdown  next to the account switcher in the upper right corner.

This will give you account 1 from ganache set up. Add the other accounts required for testing (accounts 2 through 5) as well, simply by clicking "set up account" and then OK'ing things - this will automatically use these in sequence.

We also need to set up the XBR token. In account 1, click on "add token" and use the XBR token smart contract address on your ganache deployment. If you set up the XBR contracts immediately after launching ganache, without any prior transactions, this should be

.. code-block:: console

    0xcfeb869f69431e42cdb54a4f4f105c19c080a601

This action makes account 1 the owner of the full amount of XBR tokens.


Setting up Python Environment Variables
=======================================

In order to use the Python tests we need to set environment variables which allow our code to connect to our test network. For this in the terminal you will be using to run the test code, do

.. code-block:: console

    export XBR_DEBUG_TOKEN_ADDR="0xcfeb869f69431e42cdb54a4f4f105c19c080a601"
    export XBR_DEBUG_NETWORK_ADDR="0x254dffcd3277c0b1660f6d42efbb754edababc2b"


You should now be able to run tests, e.g.

.. code-block:: console

    python teststack/test_connect.py

which should give output like

.. code-block:: console

    using web3.py v4.8.2
    connected to network 5777
    current balances of 0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1:          999346774900000000000 ETH,    999999000000000000000000000 XBR
    current balances of 0xFFcf8FDEE72ac11b5c542428B35EEF5769C409f0:         1000000000000000000000 ETH,         1000000000000000000000 XBR
    current balances of 0x22d491Bde2303f2f43325b2108D26f1eAbA1e32b:         1000000000000000000000 ETH,                              0 XBR
    current balances of 0xE11BA2b4D45Eaed5996Cd0823791E0C93114882d:         1000000000000000000000 ETH,                              0 XBR
    current balances of 0xd03ea8624C8C5987235048901fB614fDcA89b117:         1000000000000000000000 ETH,                              0 XBR
    current balances of 0x95cED938F7991cd0dFcb48F0a06a40FA1aF46EBC:         1000000000000000000000 ETH,                              0 XBR
    current balances of 0x3E5e9111Ae8eB78Fe1CC3bb8915d5D461F3Ef9A9:         1000000000000000000000 ETH,                              0 XBR
    current balances of 0x28a8746e75304c0780E011BEd21C72cD78cd535E:         1000000000000000000000 ETH,                              0 XBR
    current balances of 0xACa94ef8bD5ffEE41947b4585a84BdA5a3d3DA6E:         1000000000000000000000 ETH,                              0 XBR
    current balances of 0x1dF62f291b2E969fB0849d99D9Ce41e2F137006e:         1000000000000000000000 ETH,                              0 XBR
    current balances of 0x610Bb1573d1046FCb8A70Bbbd395754cD57C2b60:         1000000000000000000000 ETH,                              0 XBR
    current balances of 0x855FA758c77D68a04990E992aA4dcdeF899F654A:         1000000000000000000000 ETH,                              0 XBR
    current balances of 0xfA2435Eacf10Ca62ae6787ba2fB044f8733Ee843:         1000000000000000000000 ETH,                              0 XBR
    current balances of 0x64E078A8Aa15A41B85890265648e965De686bAE6:         1000000000000000000000 ETH,                              0 XBR
    current balances of 0x2F560290FEF1B3Ada194b6aA9c40aa71f8e95598:         1000000000000000000000 ETH,                              0 XBR
