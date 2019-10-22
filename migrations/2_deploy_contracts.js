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

var OwnedUpgradeabilityProxy = artifacts.require("./OwnedUpgradeabilityProxy.sol");

// https://truffleframework.com/docs/truffle/getting-started/running-migrations#deployer
module.exports = async function (deployer, network, accounts) {

    // deploy proxy contracts
    //
    const self = this;
    const gas = 372446;
    const owner = accounts[0];

    console.log("Deploying proxy contracts from " + owner + " with gas " + gas + " ..");

    await deployer.deploy(OwnedUpgradeabilityProxy, {gas: gas, from: owner});
    const xbrtoken = await OwnedUpgradeabilityProxy.deployed();

    await deployer.deploy(OwnedUpgradeabilityProxy, {gas: gas, from: owner});
    const xbrnetwork = await OwnedUpgradeabilityProxy.deployed();

    await deployer.deploy(OwnedUpgradeabilityProxy, {gas: gas, from: owner});
    const xbrmarket = await OwnedUpgradeabilityProxy.deployed();

    await deployer.deploy(OwnedUpgradeabilityProxy, {gas: gas, from: owner});
    const xbrcatalog = await OwnedUpgradeabilityProxy.deployed();
};
