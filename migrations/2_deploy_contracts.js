///////////////////////////////////////////////////////////////////////////////
//
//  XBR Open Data Markets - https://xbr.network
//
//  JavaScript client library for the XBR Network.
//
//  Copyright (C) Crossbar.io Technologies GmbH and contributors
//
//  Licensed under the Apache 2.0 License:
//  https://opensource.org/licenses/Apache-2.0
//
///////////////////////////////////////////////////////////////////////////////

var XBRToken = artifacts.require("./XBRToken.sol");
var XBRNetwork = artifacts.require("./XBRNetwork.sol");
var XBRTest = artifacts.require("./XBRTest.sol");
// var XBRPaymentChannel = artifacts.require("./XBRPaymentChannel.sol");
// var XBRNetworkProxy = artifacts.require("./XBRNetworkProxy.sol");

// https://truffleframework.com/docs/truffle/getting-started/running-migrations#deployer
module.exports = function (deployer, network, accounts) {

    var self = this;

    // https://etherscan.io/chart/gaslimit
    // https://www.rinkeby.io/#stats
    // https://ropsten.etherscan.io/blocks

    if (network === "coverage") {
        gas = 0xfffffffffff;
    } else {
        gas = 6900000;
    }

    const organization = accounts[0];
    // const organization = "0x0000000000000000000000000000000000000000";

    console.log("Deploying contracts from " + organization + " with gas " + gas + " ..");

    if (false && network === "ganache") {
        // https://solidity.readthedocs.io/en/v0.5.3/units-and-global-variables.html#mathematical-and-cryptographic-functions
        // https://ethereum.stackexchange.com/questions/1607/out-of-gas-invoking-precompiled-contracts-on-private-blockchains#2536
        // https://ethereum.stackexchange.com/a/15483/17806
        // const amount = 1000000000000000000;
        const amount = 1;
        for (var i = 1; i < 8; ++i) {
            var precompile = "0x000000000000000000000000000000000000000" + i;
            self.web3.eth.sendTransaction({from: organization, to: precompile, value: amount});
            console.log("Transferred " + amount + " wei to precompile contract " + precompile + "!")
        }
    }

    // Deploy XBRToken, then deploy XBRNetwork, passing in XBRToken's newly deployed address
    deployer.deploy(XBRToken, {gas: gas, from: organization}).then(function() {
        return deployer.deploy(XBRNetwork, XBRToken.address, organization, {gas: gas, from: organization});
    });

    deployer.deploy(XBRTest, {gas: gas, from: organization});

    // deployer.deploy(XBRPaymentChannel);
    // deployer.deploy(XBRNetworkProxy);
};
