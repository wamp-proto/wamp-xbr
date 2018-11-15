from pprint import pprint

import web3
import xbr


if __name__ == '__main__':
    print('using web3.py v{}'.format(web3.__version__))

    if True:
        from web3.auto import w3
    else:
        provider = web3.Web3.HTTPProvider("http://127.0.0.1:8545", request_kwargs={'timeout': 5})
        w3 = web3.Web3(provider)

    if w3.isConnected():
        print('connected to network {}'.format(w3.version.network))

    xbr.initialize(w3)

    account = w3.eth.accounts[0]
    print('using account address {}'.format(account))

    balance_eth = w3.eth.getBalance(account)
    balance_xbr = xbr.token.functions.balanceOf(account).call()

    print('current balances: {} ETH, {} XBR'.format(balance_eth, balance_xbr))
