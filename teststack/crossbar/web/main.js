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


// demo app entry point
window.addEventListener('load', function () {
    unlock_metamask();
});


// check for MetaMask and ask user to grant access to accounts ..
// https://medium.com/metamask/https-medium-com-metamask-breaking-change-injecting-web3-7722797916a8
async function unlock_metamask () {
    if (window.ethereum) {
        // if we have MetaMask, ask user for access
        await ethereum.enable();

        // instantiate Web3 from MetaMask as provider
        window.web3 = new Web3(ethereum);
        console.log('ok, user granted access to MetaMask accounts');

        // set new provider on XBR library
        xbr.setProvider(window.web3.currentProvider);
        console.log('library versions: web3="' + web3.version.api + '", xbr="' + xbr.version + '"');

        // now setup testing from the accounts ..
        await setup_test();

    } else {
        // no MetaMask (or other modern Ethereum integrated browser) .. redirect
        var win = window.open('https://metamask.io/', '_blank');
        if (win) {
            win.focus();
        }
    }
}


// setup test
async function setup_test () {
    // primary account used for testing
    const account = web3.eth.accounts[0];
    console.log('testing with primary account ' + account);

    // display addresses of XBR smart contract instances
    document.getElementById('account').innerHTML = '' + account;
    document.getElementById('xbr_network_address').innerHTML = '' + xbr.xbrNetwork.address;
    document.getElementById('xbr_token_address').innerHTML = '' + xbr.xbrToken.address;

    // set main account as default in form elements
    document.getElementById('new_member_address').value = '' + account;
    document.getElementById('get_member_address').value = '' + account;

    // run one test
    await test_get_member();
}


async function test_get_member () {
    var get_member_address = document.getElementById('get_member_address').value;

    // ask for current balance in XBR
    var balance = await xbr.xbrToken.balanceOf(get_member_address);
    if (balance > 0) {
        balance = balance / 10**18;
        console.log('account holds ' + balance + ' XBR');
    } else {
        console.log('account does not hold XBR currently');
    }

    // ask for XBR network membership level
    const level = await xbr.xbrNetwork.getMemberLevel(get_member_address);
    if (level > 0) {
        console.log('account is already member in the XBR network (level=' + level + ')');
    } else {
        console.log('account is not yet member in the XBR network');
    }
}


async function test_register () {
    // primary account used for testing
    const account = web3.eth.accounts[0];

    const new_member_address = document.getElementById('new_member_address').value;
    const new_member_eula = document.getElementById('new_member_eula').value;
    const new_member_profile = document.getElementById('new_member_profile').value;

    console.log('test_register(new_member_address=' + new_member_address + ', new_member_eula=' + new_member_eula + ', new_member_profile=' + new_member_profile + ')');

    // bytes32 eula, bytes32 profile
    await xbr.xbrNetwork.register(new_member_eula, new_member_profile, {from: account});
}


async function test_open_market () {
    // primary account used for testing
    const account = web3.eth.accounts[0];

    var marketId = web3.sha3('MyMarket1');
    var maker = document.getElementById('new_market_maker_address').value;
    var terms = document.getElementById('new_market_terms').value;
    var providerSecurity = document.getElementById('new_market_provider_security').value;
    var consumerSecurity = document.getElementById('new_market_consumer_security').value;

    console.log('test_open_market(marketId=' + marketId + ', maker=' + maker + ', terms=' + terms + ', providerSecurity=' + providerSecurity + ', consumerSecurity=' + consumerSecurity + ')');

    // bytes32 marketId, address maker, bytes32 terms, uint providerSecurity, uint consumerSecurity
    await xbr.xbrNetwork.openMarket(marketId, maker, terms, providerSecurity, consumerSecurity, {from: account});
}
