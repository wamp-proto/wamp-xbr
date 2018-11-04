Getting Started
===============

$ npm install -g ganache-cli
$ npm install -g truffle
$ mkdir my-ico && cd my-ico
$ truffle init
$ npm install openzeppelin-solidity@2.0.0

We build on the following toolset:

* `Ganache <https://truffleframework.com/ganache>`_
* `OpenZeppelin Solidity library <https://openzeppelin.org/>`_
* `MetaMask <>`_



Running Ganache
---------------

fire up a personal Ethereum blockchain


docker run -d -p 8545:8545 trufflesuite/ganache-cli:latest



We will run a local (only) Ethereum blockchain using Ganache CLI and Docker.

Ganache CLI, part of the Truffle suite of Ethereum development tools, is the command line version of Ganache, your personal blockchain for Ethereum development.


https://github.com/trufflesuite/ganache-cli


Truffle has taken the TestRPC under its wing and made it part of the Truffle suite of tools. 


Use a bip39 mnemonic phrase for generating a PRNG seed, which is in turn used for hierarchical deterministic (HD) account generation.

Port number to listen on. Defaults to 8545.


--networkId: Specify the network id ganache-cli will use to identify itself (defaults to the current time or the network id of the forked blockchain if configured)



eth_blockNumber
eth_estimateGas
eth_gasPrice
eth_getBalance
eth_getBlockByNumber
eth_getTransactionByHash
eth_getTransactionReceipt
eth_getStorageAt
eth_getLogs

eth_sendRawTransaction



MetaMask
--------

Http(s) - Web Server Required
Due to browser security restrictions, we can't communicate with dapps running on file://. Please use a local server for development.




Deploying XBR Smart Contracts
-----------------------------

We will build the XBR protocol smart contracts from Solidity sources and deploy to Ganache.
