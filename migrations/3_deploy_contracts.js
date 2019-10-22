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
var XBRMarket = artifacts.require("./XBRMarket.sol");
var XBRCatalog = artifacts.require("./XBRCatalog.sol");
// var XBRTest = artifacts.require("./XBRTest.sol");
var OwnedUpgradeabilityProxy = artifacts.require("./OwnedUpgradeabilityProxy.sol");


// https://truffleframework.com/docs/truffle/getting-started/running-migrations#deployer
module.exports = async function (deployer, network, accounts) {

    // deploy implementation contracts
    //
    const self = this;
    const gas = 6900000;
    const owner = accounts[0];
    console.log("Deploying implementation contracts from " + owner + " with gas " + gas + " ..");

    // FIXME
    // const xbrtoken = await OwnedUpgradeabilityProxy.deployed();
    // const xbrnetwork = await OwnedUpgradeabilityProxy.deployed();
    if (true) {
        token_adr = "0xCfEB869F69431e42cdB54A4F4f105C19C080A601";
        network_adr = "0x254dffcd3277C0b1660F6d42EFbB754edaBAbC2B";
        market_adr = "0xC89Ce4735882C9F0f0FE26686c53074E09B0D550";
        catalog_adr = "0xD833215cBcc3f914bD1C9ece3EE7BF8B14f841bb";
    } else {
        token_adr = process.env['XBR_DEBUG_TOKEN_ADDR'];
        network_adr = process.env['XBR_DEBUG_NETWORK_ADDR'];
    }

    const xbrtoken = await OwnedUpgradeabilityProxy.at(token_adr);
    const xbrnetwork = await OwnedUpgradeabilityProxy.at(network_adr);
    const xbrmarket = await OwnedUpgradeabilityProxy.at(market_adr);
    const xbrcatalog = await OwnedUpgradeabilityProxy.at(catalog_adr);

    await deployer.deploy(XBRToken, {gas: gas, from: owner});
    const xbrtoken_impl = await XBRToken.deployed();
    await xbrtoken.upgradeTo(xbrtoken_impl.address);

    await deployer.deploy(XBRMarket, {gas: gas, from: owner});
    const xbrmarket_impl = await XBRMarket.deployed();
    await xbrmarket.upgradeTo(xbrmarket_impl.address);

    await deployer.deploy(XBRCatalog, {gas: gas, from: owner});
    const xbrcatalog_impl = await XBRCatalog.deployed();
    await xbrcatalog.upgradeTo(xbrcatalog_impl.address);

    await deployer.deploy(XBRNetwork,
        xbrtoken.address,
        xbrcatalog.address,
        xbrmarket.address,
        owner, {gas: gas, from: owner});
    const xbrnetwork_impl = await XBRNetwork.deployed();
    await xbrnetwork.upgradeTo(xbrnetwork_impl.address);

    console.log('xbrtoken proxy ' + xbrtoken.address + ' upgraded to implementation ' + xbrtoken_impl.address);
    console.log('xbrnetwork proxy ' + xbrnetwork.address + ' upgraded to implementation ' + xbrnetwork_impl.address);
    console.log('xbrmarket proxy ' + xbrmarket.address + ' upgraded to implementation ' + xbrmarket_impl.address);
    console.log('xbrcatalog proxy ' + xbrcatalog.address + ' upgraded to implementation ' + xbrcatalog_impl.address);

    /*
    if (network === "ganache" || network === "coverage") {
        deployer.deploy(XBRTest, {gas: gas, from: owner});
    }
*/
};
