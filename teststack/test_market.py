import os
import sys
import web3
import xbr

from accounts import addr_owner, addr_alice_market, addr_alice_market_maker1, addr_bob_market, addr_bob_market_maker1, \
    addr_charlie_provider, addr_charlie_provider_delegate1, addr_donald_provider, addr_donald_provider_delegate1, \
    addr_edith_consumer, addr_edith_consumer_delegate1, addr_frank_consumer, addr_frank_consumer_delegate1


def main(accounts):
    for market in [
        {
            # '0x' + os.urandom(16).hex()
            'id': '0xa1b8d6741ae8492017fafd8d4f8b67a2',
            'owner': addr_alice_market,
            'maker': addr_alice_market_maker1,
            'terms': '',
            'meta': '',
            'providerSecurity': 100 * 10**18,
            'consumerSecurity': 100 * 10**18,
            'marketFee': 10**7 * 10**18,
            'providers': [addr_charlie_provider, addr_donald_provider],
            'consumers': [addr_edith_consumer, addr_frank_consumer]
        },
        {
            'id': '0xa42474d7e8ed084e13d22690f9d002d5',
            'owner': addr_bob_market,
            'maker': addr_bob_market_maker1,
            'terms': '',
            'meta': '',
            'providerSecurity': 100 * 10**18,
            'consumerSecurity': 100 * 10**18,
            'marketFee': 10**7 * 10**18,
            'providers': [],
            'consumers': []
        }
    ]:
        owner = xbr.xbrNetwork.functions.getMarketOwner(market['id']).call()

        if owner != '0x0000000000000000000000000000000000000000':
            if owner != market['owner']:
                print('Market {} already exists, but has wrong owner!! Expected {}, but owner is {}'.format(market['id'], market['owner'], owner))
            else:
                print('Market {} already exists and has expected owner {}'.format(market['id'], owner))
        else:
            xbr.xbrNetwork.functions.createMarket(
                market['id'],
                market['terms'],
                market['meta'],
                market['maker'],
                market['providerSecurity'],
                market['consumerSecurity'],
                market['marketFee']).transact({'from': market['owner'], 'gas': 1000000})

            print('Market {} created with owner!'.format(market['id'], market['owner']))

        for provider in market['providers']:
            atype = xbr.xbrNetwork.functions.getMarketActorType(market['id'], provider).call()
            if atype:
                if atype != xbr.ActorType.PROVIDER:
                    print('Account {} is already actor in the market, but has wrong actor type! Expected {}, but got {}.'.format(provider, xbr.ActorType.PROVIDER, atype))
                else:
                    print('Account {} is already actor in the market and has correct actor type {}'.format(provider, atype))
            else:
                result = xbr.xbrToken.functions.approve(xbr.xbrNetwork.address, market['providerSecurity']).transact({'from': provider, 'gas': 1000000})
                if not result:
                    print('Failed to allow transfer of tokens for market security!', result)
                else:
                    print('Allowed transfer of {} XBR from {} to {} as security for joining market'.format(market['providerSecurity'], provider, xbr.xbrNetwork.address))
                    security = xbr.xbrNetwork.functions.joinMarket(market['id'], xbr.ActorType.PROVIDER).transact({'from': provider, 'gas': 1000000})
                    print('Actor {} joined market {} as actor type {} with security {}!'.format(provider, market['id'], xbr.ActorType.PROVIDER, security))


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
