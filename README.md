# The XBR Protocol

The XBR protocol, with "protocol" used in the context of the decentralized Internet, all things blockchain based, mainly consists of a set of smart contracts, programs to run on a blockchain that has a virtual machine to run programs, and a database to store data.

This repository contains the XBR smart contracts, with Ethereum as blockchain, and Solidity as implementation language for the XBR smart contracts.


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
