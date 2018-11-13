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

// entry point: asks user to grant access to MetaMask ..
async function unlock () {

    if (window.ethereum) {
        // if we have MetaMask, ask user for access
        await ethereum.enable();

        // instantiate Web3 from MetaMask as provider
        window.web3 = new Web3(ethereum);
        console.log('ok, user granted access to MetaMask accounts');

        // set new provider on XBR library
        xbr.setProvider(window.web3.currentProvider);
        console.log('library versions: web3="' + web3.version.api + '", xbr="' + xbr.version + '"');

        // now start testing from the accounts ..
        await test();

    } else {
        // no MetaMask (or other modern Ethereum integrated browser) .. redirect
        var win = window.open('https://metamask.io/', '_blank');
        if (win) {
            win.focus();
        }
    }
}


// main app: this runs with the 1st MetaMask account (given the user has granted access)
async function test () {
    // primary account used for testing
    const account = web3.eth.accounts[0];
    console.log('starting main from account ' + account);

    // set main account as default in form elements
    document.getElementById('new_member_address').value = '' + account;
    document.getElementById('get_member_address').value = '' + account;

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

    await xbr.xbrNetwork.register(new_member_eula, new_member_profile, {from: account});
}
