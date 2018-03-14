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
```

