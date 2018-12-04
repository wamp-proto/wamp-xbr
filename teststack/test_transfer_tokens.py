import sys
import web3
import xbr
import os

from accounts import addr_owner, addr_alice_market, addr_alice_market_maker1, addr_bob_market, addr_bob_market_maker1, \
    addr_charlie_provider, addr_charlie_provider_delegate1, addr_donald_provider, addr_donald_provider_delegate1, \
    addr_edith_consumer, addr_edith_consumer_delegate1, addr_frank_consumer, addr_frank_consumer_delegate1


def main(accounts):
    # XBR tokens to transfer
    amount = 1000

    # raw amount of XBR tokens (taking into account decimals)
    raw_amount = amount * 10**18

    for acct in [addr_alice_market, addr_bob_market, addr_charlie_provider, addr_donald_provider, addr_edith_consumer, addr_frank_consumer]:
        success = xbr.xbrToken.functions.transfer(acct, raw_amount).transact({'from': addr_owner, 'gas': 100000})
        if success:
            print('Transferred {} XBR to {}'.format(amount, acct))
        else:
            print('Failed to transfer tokens!')


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
