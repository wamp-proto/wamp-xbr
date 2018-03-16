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
populus init
populus compile
py.test tests
```

Connect to the chain:

```console
oberstet@thinkpad-t430s:~/scm/xbr/xbr-protocol/main$ geth attach chains/horton/chain_data/geth.ipc
Welcome to the Geth JavaScript console!

instance: Geth/v1.6.7-stable-ab5646c5/linux-amd64/go1.8.3
coinbase: 0x70e9c4c76190b628f04a146e7db00fe889c2d258
at block: 0 (Thu, 01 Jan 1970 01:00:00 CET)
 datadir: /home/oberstet/scm/xbr/xbr-protocol/main/chains/horton/chain_data
 modules: admin:1.0 debug:1.0 eth:1.0 miner:1.0 net:1.0 personal:1.0 rpc:1.0 txpool:1.0 web3:1.0

> web3.fromWei(eth.getBalance(eth.coinbase))
1000000000000
>
```

---


geth account new



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
