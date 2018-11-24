Connecting to the Network
=========================

.. contents:: :local:

----------

Connect from JavaScript
-----------------------

Here is the boilerplate and a minimal starter example that connects to the
XBR Network from **JavaScript** in a browser with **MetaMask** using **Web3.js**,
and checks the ETH and XBR balances of the primary account:

.. code-block:: javascript

    // app entry point
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

            // now enter main ..
            await main(web3.eth.accounts[0]);

        } else {
            // no MetaMask (or other modern Ethereum integrated browser) .. redirect
            var win = window.open('https://metamask.io/', '_blank');
            if (win) {
                win.focus();
            }
        }
    }

The important step is to set the Web3 provider on the XBR library with
``xbr.setProvider(web3.currentProvider)``.

Above will jump into `main()` when the user has granted access. Here is an example where
we ask for the current XBR balance of the user account, and the XBR Network membership level:

.. code-block:: javascript

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
    }

You can download the complete example page with above code
:download:`from here </_static/html/xbr_app1.html>`.

When opening this Web page (remember, it needs to served from a Web server,
``file://`` will *not* work), you should see log output like the following
in your browser console:

.. code-block:: console

    ok, user granted access to MetaMask accounts
    xbr_app1.html:30 library versions: web3="0.20.3", xbr="18.11.1"
    xbr_app1.html:46 starting main from account 0x90f8bf6a479f320ead074411a4b0e7944ea8c9c1
    xbr_app1.html:52 account holds 1000000000 XBR
    xbr_app1.html:60 account is already member in the XBR network (level=2)


Connect from Python
-------------------

Here is the boilerplate and a minimal starter example that connects to the
XBR Network from **Python** using **Web3.py**, and checks the ETH and XBR balances
of the primary account:

.. code-block:: python

    import sys
    import web3
    import xbr


    def main (account):
        print('using account address {}'.format(account))

        balance_eth = w3.eth.getBalance(account)
        balance_xbr = xbr.xbrToken.functions.balanceOf(account).call()

        print('current balances: {} ETH, {} XBR'.format(balance_eth, balance_xbr))


    if __name__ == '__main__':
        print('using web3.py v{}'.format(web3.__version__))

        # using automatic provider detection:
        from web3.auto import w3

        # check we are connected, and check network ID
        if not w3.isConnected():
            print('could not connect to Web3/Ethereum')
            sys.exit(1)
        else:
            print('connected to network {}'.format(w3.version.network))

        # set new provider on XBR library
        xbr.setProvider(w3)

        # now enter main ..
        main(w3.eth.accounts[0])

The important step is to set the Web3 provider on the XBR library with
``xbr.setProvider(w3)``.

Example output of above:

.. code-block:: console

    (cpy371_1) oberstet@thinkpad-x1:~/scm/xbr/xbr-protocol$ python teststack/test_client1.py
    using web3.py v4.8.1
    connected to network 5777
    using account address 0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1
    current balances: 992385178585000000000 ETH, 1000000000000000000000000000 XBR

Congratulations! You are now connected to the XBR Network.

.. tip::

    Instead of relying on autodetecting the Web3 provider, one can also configure
    a provider explicitly, which allows to fine tune e.g. request timeouts:

    .. code-block:: python

        provider = web3.Web3.HTTPProvider("http://127.0.0.1:8545", request_kwargs={'timeout': 5})
        w3 = web3.Web3(provider)
