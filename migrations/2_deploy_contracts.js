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

    if (network === "soliditycoverage") {
        gas = 0xfffffffffff;
    } else {
        gas = 6900000;
        // gas = 8000000;
    }

    const organization = accounts[0];

    console.log("Deploying contracts from " + organization + " with gas " + gas + " ..");

    // Deploy XBRToken, then deploy XBRNetwork, passing in XBRToken's newly deployed address
    deployer.deploy(XBRToken, {gas: gas, from: organization}).then(function() {
        return deployer.deploy(XBRNetwork, XBRToken.address, organization, {gas: gas, from: organization});
    });

    if (network === "ganache" || network === "soliditycoverage") {
        deployer.deploy(XBRTest, {gas: gas, from: organization});
    }
};
