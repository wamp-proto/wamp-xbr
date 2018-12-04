import sys
import web3
import xbr


def main (accounts):
    for acct in accounts:
        balance_eth = w3.eth.getBalance(acct)
        balance_xbr = xbr.xbrToken.functions.balanceOf(acct).call()
        print('current balances of {}: {:>30} ETH, {:>30} XBR'.format(acct, balance_eth, balance_xbr))


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
