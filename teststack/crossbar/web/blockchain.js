window.web3 = null;

function account_access_granted (account) {
    console.log('user granted access to account: ' + account);

    document.getElementById('maker_reg_address').value = '' + account;
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
    }
});


const xbr_token_addr = '0x5459625c5559dac609b94f92ae3c8129a887762e';
const xbr_network_addr = '0x7fcc7fed93bd4a288a5614e890e351e4de761db6';

function register_maker() {
    var maker_reg_address = document.getElementById('maker_reg_address').value;
    var maker_reg_eula = document.getElementById('maker_reg_eula').value;
    var maker_reg_profile = document.getElementById('maker_reg_profile').value;

    console.log('register_maker(address=' + maker_reg_address + ', eula=' + maker_reg_eula + ', profile=' + maker_reg_profile + ')');
}
