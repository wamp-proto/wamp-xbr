# The XBR Protocol

This repository contains the XBR smart contracts, with Ethereum as target blockchain, and Solidity as implementation language for the XBR smart contracts.

Copyright Crossbar.io Technologies GmbH. Licensed under the [Apache 2.0 license](https://www.apache.org/licenses/LICENSE-2.0).

---


## Development

Development is using the [Truffle](http://truffleframework.com/) Ethereum toolbelt, and the [OpenZeppelin](https://openzeppelin.org/) Solidity smart contracts framework, and the [Ganache CLI](https://github.com/trufflesuite/ganache-cli/#welcome-to-ganache-cli) local blockchain.

### Requirements

Install NodeJS and NPM.

Install Ethereum:

```console
sudo add-apt-repository -y ppa:ethereum/ethereum
sudo apt-get update
sudo apt-get install -y ethereum
```

Install Solidity:

```console
sudo add-apt-repository -y ppa:ethereum/ethereum
sudo apt-get update
sudo apt-get install -y solc
```

Install Truffle + Ganache:

```console
npm install -g truffle
npm install -g ganache-cli
npm install -g zeppelin-solidity
```

Install Populus (in a fresh Python 3 virtualenv):

```console
pip install -U populus
pip install eth_utils==0.7.4
```

---


### Using Populus

Scaffold an example, compile and test:

```console
truffle unbox metacoin
truffle compile
truffle test
```

---


### Using Truffle

Scaffold an example, compile and test:

```console
truffle unbox metacoin
truffle compile
truffle test
```

Eg:

```console
oberstet@thinkpad-t430s:~/scm/xbr/xbr-protocol/core$ truffle test
Using network 'test'.

Compiling ./contracts/ConvertLib.sol...
Compiling ./contracts/MetaCoin.sol...
Compiling ./contracts/SimpleStorage.sol...
Compiling ./test/TestMetacoin.sol...
Compiling ./test/TestSimpleStorage.sol...
Compiling truffle/Assert.sol...
Compiling truffle/DeployedAddresses.sol...


  TestMetacoin
    ✓ testInitialBalanceUsingDeployedContract (86ms)
    ✓ testInitialBalanceWithNewMetaCoin (72ms)

  TestSimpleStorage
    ✓ test_deployed_initial_value (87ms)
    ✓ test_new_initial_value (63ms)

  Contract: MetaCoin
    ✓ should put 10000 MetaCoin in the first account
    ✓ should call a function that depends on a linked library (41ms)
    ✓ should send coin correctly (120ms)


  7 passing (2s)
```

---
