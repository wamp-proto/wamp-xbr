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

        // now start main from the first account ..
        await main(web3.eth.accounts[0]);

    } else {
        // no MetaMask (or other modern Ethereum integrated browser) .. redirect
        var win = window.open('https://metamask.io/', '_blank');
        if (win) {
            win.focus();
        }
    }
}

// main app: this runs with the 1st MetaMask account (given the user has granted access)
async function main (account) {
    console.log('starting main from account ' + account);

    // ask for current balance in XBR
    var balance = await xbr.xbrToken.balanceOf(account);
    if (balance > 0) {
        balance = balance / 10**18;
        console.log('account holds ' + balance + ' XBR');
    } else {
        console.log('account does not hold XBR currently');
    }

    // ask for XBR network membership level
    const level = await xbr.xbrNetwork.getMemberLevel(account);
    if (level > 0) {
        console.log('account is already member in the XBR network (level=' + level + ')');
    } else {
        console.log('account is not yet member in the XBR network');
    }
}
