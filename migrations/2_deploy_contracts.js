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

const XBRTest = artifacts.require("./XBRTest.sol");
const XBRToken = artifacts.require("./XBRToken.sol");
const XBRNetwork = artifacts.require("./XBRNetwork.sol");
const XBRTypes = artifacts.require("./XBRTypes.sol");
const XBRMarket = artifacts.require("./XBRMarket.sol");
const XBRCatalog = artifacts.require("./XBRCatalog.sol");
const XBRChannel = artifacts.require("./XBRChannel.sol");
// const XBRNetworkProxy = artifacts.require("./XBRNetworkProxy.sol");

// https://truffleframework.com/docs/truffle/getting-started/running-migrations#deployer
module.exports = function (deployer, network, accounts) {

    // https://etherscan.io/chart/gaslimit
    // https://www.rinkeby.io/#stats
    // https://ropsten.etherscan.io/blocks

    var gas;
    if (network === "soliditycoverage") {
        gas = 0xfffffffffff;
    } else {
        // the block gas limit on Rinkeby and Mainnet hovers _around_ 10m (!)
        // eg on Mainnet: Min. 9,955,619 - gas Max. 9,999,175 gas
        // so we use (10m - sth) as limit (not outright 10m)
        // gas = 9950000;
        // gas = 10000000 - 100;
        gas = 10000000;
    }

    const organization = accounts[0];
    console.log("Deploying contracts from " + organization + " with gas " + gas + " ..");

    deployer.then(async () => {
        await deployer.deploy(XBRToken, {gas: gas, from: organization});
        console.log('>>>> XBRToken deployed at ' + XBRToken.address);

        await deployer.deploy(XBRTypes);
        console.log('>>>> XBRTypes deployed at ' + XBRTypes.address);

        await deployer.link(XBRTypes, XBRNetwork);
        await deployer.deploy(XBRNetwork, XBRToken.address, organization, {gas: gas, from: organization});
        console.log('>>>> XBRNetwork deployed at ' + XBRNetwork.address);

        await deployer.link(XBRTypes, XBRCatalog);
        await deployer.link(XBRNetwork, XBRCatalog);
        await deployer.deploy(XBRCatalog, XBRNetwork.address, {gas: gas, from: organization});
        console.log('>>>> XBRCatalog deployed at ' + XBRCatalog.address);

        await deployer.link(XBRTypes, XBRMarket);
        await deployer.link(XBRNetwork, XBRMarket);
        await deployer.link(XBRCatalog, XBRMarket);
        await deployer.deploy(XBRMarket, XBRNetwork.address, XBRCatalog.address, {gas: gas, from: organization});
        console.log('>>>> XBRMarket deployed at ' + XBRMarket.address);

        await deployer.link(XBRTypes, XBRChannel);
        await deployer.link(XBRNetwork, XBRChannel);
        await deployer.link(XBRMarket, XBRChannel);
        await deployer.deploy(XBRChannel, XBRMarket.address, {gas: gas, from: organization});
        console.log('>>>> XBRChannel deployed at ' + XBRMarket.address);

        // keep this at the end of deployment, so that the addresses of the XBR
        // contracts "stay constant" for CI
        if (network === "ganache" || network === "soliditycoverage") {
            await deployer.deploy(XBRTest, {gas: gas, from: organization});
        }

        console.log('\nDeployed XBR contract addresses:\n');
        console.log('export XBR_DEBUG_TOKEN_ADDR=' + XBRToken.address);
        console.log('export XBR_DEBUG_NETWORK_ADDR=' + XBRNetwork.address);
        console.log('export XBR_DEBUG_MARKET_ADDR=' + XBRMarket.address);
        console.log('export XBR_DEBUG_CATALOG_ADDR=' + XBRCatalog.address);
        console.log('export XBR_DEBUG_CHANNEL_ADDR=' + XBRChannel.address);
        console.log('\n^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n');
    });
};
