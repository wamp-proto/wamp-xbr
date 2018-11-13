async function account_access_granted (account) {
    console.log('user granted access to account: ' + account);

    xbr.setProvider(window.web3.currentProvider);

    //xbr.XBRToken.setProvider(window.web3.currentProvider);
    //xbr.XBRNetwork.setProvider(window.web3.currentProvider);

    //token = xbr.XBRToken.at('0x7b83908271437c08eac9afba56d7080b8d94038c');
    //network = xbr.XBRNetwork.at('0x69774e9a4a003b3576e27bb0ba687b4267657604');

    const balance = await xbr.xbrToken.balanceOf(account);
    if (balance > 0) {
        console.log('account holds ' + balance + ' XBR');
    } else {
        console.log('account does not hold XBR currently');
    }

    const level = await xbr.xbrNetwork.getMemberLevel(account);
    if (level > 0) {
        console.log('account is already member in the XBR network (level=' + level + ')');
    } else {
        console.log('account is not yet member in the XBR network');
    }
}

async function login () {

    if (window.ethereum) {
        await ethereum.enable();

        window.web3 = new Web3(ethereum);

        console.log('ok, user granted access to accounts', web3.eth.accounts[0]);

        await account_access_granted(web3.eth.accounts[0]);

        if (typeof web3 !== 'undefined') {
            console.log('undefined');
            //web3 = new Web3(web3.currentProvider);
        } else {
            // set the provider you want from Web3.providers
            //web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
            console.log('defined');
        }

    } else {
        var win = window.open('https://metamask.io/', '_blank');
        if (win) {
            win.focus();
        }
    }
}


window.addEventListener('load2', async () => {
    // modern dapp browsers
    if (window.ethereum) {
        console.log('browser has modern dapp/web3 integration');

        window.web3 = new Web3(ethereum);
        try {
            // request account access if needed
            await ethereum.enable();

            // accounts now exposed
            console.log('ok, user granted access to accounts', web3.eth.accounts[0]);
            //account_access_granted(web3.eth.accounts[0]);
        } catch (error) {
            // user denied account access...
            console.log('nope: user denied account access', error);
        }

        account_access_granted(web3.eth.accounts[0]);
    }
    // legacy dapp browsers
    else if (window.web3) {
        console.log('browser has legacy dapp/web3 integration');

        window.web3 = new Web3(web3.currentProvider);

        // accounts are always exposed in legacy browser
        console.log('accounts are exposed');
        account_access_granted(web3.eth.accounts[0]);
    }
    // non-dapp browsers
    else {
        console.log('non-Ethereum browser detected. you should consider trying MetaMask!');
        var win = window.open('https://metamask.io/', '_blank');
        if (win) {
            win.focus();
        }
    }

    account_access_granted(web3.eth.accounts[0]);
});
