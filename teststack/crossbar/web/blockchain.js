window.web3 = null;

window.addEventListener('load', async () => {
    // Modern dapp browsers...
    if (window.ethereum) {
        console.log('browser has modern dapp/web3 integration');

        window.web3 = new Web3(ethereum);
        try {
            // Request account access if needed
            await ethereum.enable();
            // Acccounts now exposed
            // web3.eth.sendTransaction({/* ... */});
            console.log('ok, user granted access to accounts');
        } catch (error) {
            // User denied account access...
            console.log('nope: user dnied account access');
        }
    }
    // Legacy dapp browsers...
    else if (window.web3) {
        console.log('browser has legacy dapp/web3 integration');

        window.web3 = new Web3(web3.currentProvider);

        // Acccounts always exposed
        //web3.eth.sendTransaction({/* ... */});
        console.log('accounts are exposed');
    }
    // Non-dapp browsers...
    else {
        console.log('Non-Ethereum browser detected. You should consider trying MetaMask!');
    }
});
