import sys
import web3
import xbr

from test_accounts import hl


def main (accounts):
    print('\nTest accounts:')
    for acct in accounts:
        balance_eth = w3.eth.getBalance(acct)
        balance_xbr = xbr.xbrToken.functions.balanceOf(acct).call()
        print('    balances of {}: {:>30} ETH, {:>30} XBR'.format(hl(acct), balance_eth, balance_xbr))

    print('\nXBR contracts:')
    for acct in [xbr.xbrToken.address, xbr.xbrNetwork.address]:
        balance_eth = w3.eth.getBalance(acct)
        balance_xbr = xbr.xbrToken.functions.balanceOf(acct).call()
        print('    balances of {}: {:>30} ETH, {:>30} XBR'.format(hl(acct), balance_eth, balance_xbr))

    print()

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
    main(w3.eth.accounts)
