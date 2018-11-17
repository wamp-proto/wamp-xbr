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
    document.getElementById('get_market_actor_address').value = '' + account;
    document.getElementById('get_market_owner').value = '' + account;
    document.getElementById('join_market_owner').value = '' + account;
    document.getElementById('get_market_actor_market_owner').value = '' + account;
    document.getElementById('open_channel_market_owner').value = '' + account;

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
        const eula = await xbr.xbrNetwork.getMemberEula(get_member_address);
        const profile = await xbr.xbrNetwork.getMemberProfile(get_member_address);
        console.log('eula:', eula);
        console.log('profile:', profile);
    } else {
        console.log('account is not yet member in the XBR network');
    }
}


async function test_register () {
    const account = web3.eth.accounts[0];

    const new_member_address = document.getElementById('new_member_address').value;
    const new_member_eula = document.getElementById('new_member_eula').value;
    const new_member_profile = document.getElementById('new_member_profile').value;

    console.log('test_register(new_member_address=' + new_member_address + ', new_member_eula=' + new_member_eula + ', new_member_profile=' + new_member_profile + ')');

    // bytes32 eula, bytes32 profile
    await xbr.xbrNetwork.register(new_member_eula, new_member_profile, {from: account});
}


async function test_create_market () {
    const account = web3.eth.accounts[0];

    const decimals = parseInt('' + await xbr.xbrToken.decimals())

    var name = document.getElementById('new_market_name').value;
    var terms = document.getElementById('new_market_terms').value;
    var meta = document.getElementById('new_market_meta').value;
    var maker = document.getElementById('new_market_maker_address').value;
    var providerSecurity = document.getElementById('new_market_provider_security').value;
    var consumerSecurity = document.getElementById('new_market_consumer_security').value;
    var marketFee = document.getElementById('new_market_fee').value;

    providerSecurity = providerSecurity * (10 ** decimals);
    consumerSecurity = consumerSecurity * (10 ** decimals);
    marketFee = marketFee * (10 ** decimals);

    var marketId = web3.sha3((account, name));

    console.log('test_create_market(marketId=' + marketId + ', maker=' + maker + ', terms=' + terms + ', providerSecurity=' + providerSecurity + ', consumerSecurity=' + consumerSecurity + ', marketFee=' + marketFee + ')');

    // bytes32 marketId, address maker, bytes32 terms, uint providerSecurity, uint consumerSecurity
    await xbr.xbrNetwork.createMarket(marketId, terms, meta, maker, providerSecurity, consumerSecurity, marketFee, {from: account});
}


async function test_get_market () {
    const account = web3.eth.accounts[0];

    const totalSupply = parseInt('' + await xbr.xbrToken.totalSupply())
    const decimals = parseInt('' + await xbr.xbrToken.decimals())

    var name = document.getElementById('get_market_name').value;
    var owner = document.getElementById('get_market_owner').value;

    var marketId = web3.sha3((owner, name));

    console.log('test_get_market(marketId=' + marketId + ')');

    owner = await xbr.xbrNetwork.getMarketOwner(marketId);
    var maker = await xbr.xbrNetwork.getMarketMaker(marketId);
    var providerSecurity = await xbr.xbrNetwork.getMarketProviderSecurity(marketId);
    var consumerSecurity = await xbr.xbrNetwork.getMarketConsumerSecurity(marketId);
    var marketFee = await xbr.xbrNetwork.getMarketFee(marketId);

    providerSecurity = providerSecurity / (10 ** decimals);
    consumerSecurity = consumerSecurity / (10 ** decimals);
    marketFee = (marketFee / 100.) * totalSupply;

    console.log('market ' + marketId + ' owner:', owner);
    console.log('market ' + marketId + ' maker:', maker);
    console.log('market ' + marketId + ' providerSecurity:', providerSecurity);
    console.log('market ' + marketId + ' consumerSecurity:', consumerSecurity);
    console.log('market ' + marketId + ' marketFee:', marketFee);
}


async function test_join_market () {
    const account = web3.eth.accounts[0];

    var name = document.getElementById('join_market_name').value;
    var owner = document.getElementById('join_market_owner').value;

    var marketId = web3.sha3((owner, name));

    var actorType = 0;
    if (document.getElementById('join_market_actor_type_provider').checked) {
        actorType = 3;
    }
    else if (document.getElementById('join_market_actor_type_consumer').checked) {
        actorType = 4;
    }
    else {
        assert(false);
    }

    console.log('test_join_market(marketId=' + marketId + ', actorType=' + actorType + ')');

    // bytes32 marketId, ActorType actorType
    await xbr.xbrNetwork.joinMarket(marketId, actorType, {from: account});
}


async function test_get_market_actor_type () {
    const account = web3.eth.accounts[0];

    var name = document.getElementById('get_market_actor_market_name').value;
    var owner = document.getElementById('get_market_actor_market_owner').value;

    var marketId = web3.sha3((owner, name));

    var actor = document.getElementById('get_market_actor_address').value;

    // bytes32 marketId, address actor
    const actorType = await xbr.xbrNetwork.getMarketActorType(marketId, actor);

    if (actorType > 0) {
        console.log('account is actor of type=' + actorType + ' in this market');
    } else {
        console.log('account is not an actor in this market');
    }
}


async function test_open_payment_channel () {
    const account = web3.eth.accounts[0];

    var name = document.getElementById('open_channel_market_name').value;
    var owner = document.getElementById('open_channel_market_owner').value;

    var marketId = web3.sha3((owner, name));

    var consumer = document.getElementById('open_channel_consumer_address').value;

    const decimals = parseInt('' + await xbr.xbrToken.decimals())
    var amount = document.getElementById('open_channel_amount').value;
    amount = amount * (10 ** decimals);

    const success = await xbr.xbrToken.approve(xbr.xbrNetwork.address, amount, {from: account});

    if (!success) {
        throw 'transfer was not approved';
    }

    var watch = {
        tx: null
    }

    const options = {};
    xbr.xbrNetwork.PaymentChannelCreated(options, function (error, event)
        {
            console.log('PaymentChannelCreated', event);
            if (event) {
                if (watch.tx && event.transactionHash == watch.tx) {
                    console.log('new payment channel created: marketId=' + event.args.marketId + ', channel=' + event.args.channel + '');
                }
            }
            else {
                console.error(error);
            }
        }
    );

    console.log('test_open_payment_channel(marketId=' + marketId + ', consumer=' + consumer + ', amount=' + amount + ')');

    // bytes32 marketId, address consumer, uint256 amount
    const tx = await xbr.xbrNetwork.openPaymentChannel(marketId, consumer, amount, {from: account});

    console.log(tx);

    watch.tx = tx.tx;

    console.log('transaction completed: tx=' + tx.tx + ', gasUsed=' + tx.receipt.gasUsed);
}


async function test_request_paying_channel () {

}
