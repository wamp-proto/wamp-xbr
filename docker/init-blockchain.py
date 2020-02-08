import os
import sys
import web3

import txaio
txaio.use_twisted()

from autobahn import xbr
import argparse

from autobahn.xbr import generate_seedphrase, check_seedphrase, account_from_seedphrase

if 'XBR_HDWALLET_SEED' not in os.environ:
    raise RuntimeError('XBR_HDWALLET_SEED not set!')
_XBR_HDWALLET_SEED = os.environ['XBR_HDWALLET_SEED']

ACCOUNTS = []
for i in range(20):
    account = account_from_seedphrase(_XBR_HDWALLET_SEED, i)
    ACCOUNTS.append(account)


def _print_balances(w3):
    owner_address = w3.eth.accounts[0]

    print('-' * 120)
    print('Current balances of executing (owner) account:\n')
    balance_eth = w3.eth.getBalance(owner_address)
    balance_xbr = xbr.xbrtoken.functions.balanceOf(owner_address).call()
    balance_eth = float(balance_eth / 10 ** 18)
    balance_xbr = float(balance_xbr / 10 ** 18)
    print('    {:>20}: {:>30} ETH {:>30} XBR'.format(owner_address, balance_eth, balance_xbr))

    print('-' * 120)
    print('Current balances of test accounts:\n')
    for account in ACCOUNTS:
        balance_eth = w3.eth.getBalance(account.address)
        balance_xbr = xbr.xbrtoken.functions.balanceOf(account.address).call()
        balance_eth = float(balance_eth / 10 ** 18)
        balance_xbr = float(balance_xbr / 10 ** 18)
        print('    {:>20}: {:>30} ETH {:>30} XBR'.format(account.address, balance_eth, balance_xbr))


def _top_up(w3, accounts, eth_amount, xbr_amount):
    # ETH and XBR are transferred from this account
    owner_address = w3.eth.accounts[0]

    total_eth_transferred = 0
    total_xbr_transferred = 0
    for account in accounts:
        if account.address == owner_address:
            print('Skipping transfer to ourself!')
            continue

        # top up ETH balance
        balance_eth = w3.eth.getBalance(account.address)
        if balance_eth < eth_amount:
            transfer_eth = eth_amount - balance_eth
            success = w3.eth.sendTransaction({'to': account.address, 'from': owner_address, 'value': transfer_eth})
            assert(success)
            total_eth_transferred += transfer_eth

        # top up XBR balance
        balance_xbr = xbr.xbrtoken.functions.balanceOf(account.address).call()
        if balance_xbr < xbr_amount:
            transfer_xbr = xbr_amount - balance_xbr
            success = xbr.xbrtoken.functions.transfer(account.address, transfer_xbr).transact({'from': owner_address, 'gas': 100000})
            assert(success)
            total_xbr_transferred += transfer_xbr

    return total_eth_transferred, total_xbr_transferred


def main(w3, eth_target, xbr_target, showonly=False):
    print('Using XBR token contract address: {}'.format(xbr.xbrtoken.address))
    print('Using XBR network contract address: {}'.format(xbr.xbrnetwork.address))

    _print_balances(w3)

    if not showonly:
        total_eth_transferred, total_xbr_transferred = _top_up(w3,
                                                            ACCOUNTS,
                                                            w3.toWei(eth_target, 'ether'),
                                                            xbr_target * 10**18)

        total_eth_transferred = w3.fromWei(total_eth_transferred, 'ether')
        total_xbr_transferred = float(total_xbr_transferred / 10**18)

        print('\nAccounts have been topped up by a total amount of {} ETH and {} XBR!\n'.format(total_eth_transferred, total_xbr_transferred))

        _print_balances(w3)



if __name__ == '__main__':
    print('Using web3.py v{}'.format(web3.__version__))

    parser = argparse.ArgumentParser()

    parser.add_argument('--gateway',
                        dest='gateway',
                        type=str,
                        default=None,
                        help='Ethereum HTTP gateway URL or None for auto-select (default: -, means let web3 auto-select).')

    parser.add_argument('--showonly',
                        dest='showonly',
                        action='store_true',
                        default=False,
                        help='Do not top up accounts, but only show current ETH and XBR balances of accounts.')

    args = parser.parse_args()

    if args.gateway:
        w3 = web3.Web3(web3.Web3.HTTPProvider(args.gateway))
    else:
        # using automatic provider detection:
        from web3.auto import w3

    # check we are connected, and check network ID
    if not w3.isConnected():
        print('Could not connect to Web3/Ethereum at: {}'.format(args.gateway or 'auto'))
        sys.exit(1)
    else:
        print('Connected to provider "{}"'.format(args.gateway or 'auto'))

    # set new provider on XBR library
    xbr.setProvider(w3)

    # now enter main, topping up accounts to 20 ETH and 20,000 XBR
    main(w3, 20, 20000, showonly=args.showonly)
