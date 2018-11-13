const xbr_network_addr = '0x3cc7b9a386410858b412b00b13264654f68364ed';

// ES6-based deferred factory
//
function defer () {
    var deferred = {};

    deferred.promise = new Promise(function (resolve, reject) {
        deferred.resolve = resolve;
        deferred.reject = reject;
    });

    return deferred;
};


function get_contract_json (filename) {
    var d = defer();
    var xmlhttp = new XMLHttpRequest();
    xmlhttp.onreadystatechange = function() {
        // console.log('onreadystatechange:', this.readyState, this.status)
        if (this.readyState == 4 && this.status == 200) {
            var obj = JSON.parse(this.responseText);
            d.resolve(obj);
        }
    };
    xmlhttp.open("GET", filename, true);
    xmlhttp.send();
    return d.promise;
}


async function account_access_granted (account) {
    console.log('user granted access to account: ' + account);

    document.getElementById('new_member_address').value = '' + account;
    document.getElementById('get_member_address').value = '' + account;


    XBRNetwork.setProvider(window.web3.currentProvider);
    let c = XBRNetwork.at(xbr_network_addr);
    console.log(c);

    const level = await c.getMemberLevel('0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1');
    console.log('level=' + level);

    /*
    get_contract_json('xbr/XBRNetwork.json').then(function (data) {
        xbr.network = web3.eth.contract(data['abi']).at(xbr_network_addr);

        console.log('XBRNetwork loaded at ' + xbr.network.address);

        xbr.network.network_token.call(function (error, result) {
            var xbr_token_addr = result;

            get_contract_json('xbr/XBRToken.json').then(function (data) {
                xbr.token = web3.eth.contract(data['abi']).at(xbr_token_addr);

                console.log('XBRToken loaded at ' + xbr.token.address);
            });
        });
    });
    */
}


function openInNewTab(url) {
    var win = window.open(url, '_blank');
    if (win) {
        win.focus();
    }
  }

window.addEventListener('load', async () => {
    // Modern dapp browsers...
    if (window.ethereum) {
        console.log('browser has modern dapp/web3 integration');

        window.web3 = new Web3(ethereum);
        try {
            // Request account access if needed
            await ethereum.enable();
            // Accounts now exposed
            console.log('ok, user granted access to accounts');
            account_access_granted(web3.eth.accounts[0]);
        } catch (error) {
            // User denied account access...
            console.log('nope: user denied account access');
        }
    }
    // Legacy dapp browsers...
    else if (window.web3) {
        console.log('browser has legacy dapp/web3 integration');

        window.web3 = new Web3(web3.currentProvider);

        // Acccounts always exposed
        console.log('accounts are exposed');
        account_access_granted(web3.eth.accounts[0]);
    }
    // Non-dapp browsers...
    else {
        console.log('non-Ethereum browser detected. You should consider trying MetaMask!');
        openInNewTab('https://metamask.io/');
    }
});





function test_register () {
    var new_member_address = document.getElementById('new_member_address').value;
    var new_member_eula = document.getElementById('new_member_eula').value;
    var new_member_profile = document.getElementById('new_member_profile').value;

    console.log('test_register(new_member_address=' + new_member_address + ', new_member_eula=' + new_member_eula + ', new_member_profile=' + new_member_profile + ')');

    xbr.network.register(new_member_eula,
                         new_member_profile,
                         function (error, txhash) {
                            if (error) {
                                console.log('transaction failed!', error);
                            } else {
                                console.log('transaction succeeded! txhash=' + txhash);
                            }
                         });
}


function test_get_member2 () {
    var get_member_address = document.getElementById('get_member_address').value;

    console.log('test_get_member(get_member_address=' + get_member_address + ')');

    xbr.network.getMemberLevel.call(get_member_address, function (error, level) {
        if (level > 0) {
            console.log('account is already a registered member: level=' + level);
        } else {
            console.log('account is currently not a member');
        }
    });
}


async function test_get_member () {
    var get_member_address = document.getElementById('get_member_address').value;

    console.log('test_get_member(get_member_address=' + get_member_address + ')');

    const level = await xbr.network.getMemberLevel(get_member_address);
    if (level > 0) {
        console.log('account is already a registered member: level=' + level);
    } else {
        console.log('account is currently not a member');
    }
}


function test_open_market () {
    var marketId = web3.sha3('MyMarket1');
    var maker = document.getElementById('new_market_maker_address').value;
    var terms = document.getElementById('new_market_terms').value;
    var providerSecurity = document.getElementById('new_market_provider_security').value;
    var consumerSecurity = document.getElementById('new_market_consumer_security').value;

    console.log('test_open_market(marketId=' + marketId + ', maker=' + maker + ', terms=' + terms + ', providerSecurity=' + providerSecurity + ', consumerSecurity=' + consumerSecurity + ')');

    // bytes32 marketId, address maker, bytes32 terms, uint providerSecurity, uint consumerSecurity

    xbr.network.open_market(marketId, maker, terms, providerSecurity, consumerSecurity,
        function (error, result) {
            console.log('RESULT:', result);
        });
}
