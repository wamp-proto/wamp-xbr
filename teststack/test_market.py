import os
import sys
import web3
import xbr


def main(accounts):
    acct_network = accounts[0]
    acct_market = accounts[1]
    acct_provider = accounts[2]
    acct_consumer = accounts[3]
    acct_market_maker = accounts[4]
    acct_provider_delegate = accounts[5]
    acct_consumer_delegate = accounts[6]

    marketId = '0x' + os.urandom(16).hex()
    marketId = '0xa1b8d6741ae8492017fafd8d4f8b67a2'
    owner = xbr.xbrNetwork.functions.getMarketOwner(marketId).call()

    if owner:
        print('market already exists! owner is {}'.format(owner))
    else:
        terms = ''
        meta = ''
        maker = acct_market_maker
        providerSecurity = 100 * 10**18
        consumerSecurity = 100 * 10**18
        marketFee = 10**7 * 10**18

        xbr.xbrNetwork.functions.createMarket(marketId, terms, meta, maker,
            providerSecurity, consumerSecurity, marketFee).transact({'from': acct_market, 'gas': 1000000})

        print('market {} created!'.format(marketId))

    actor = acct_provider
    actorType = xbr.ActorType.PROVIDER
    atype = xbr.xbrNetwork.functions.getMarketActorType(actor).call()
    if atype:
        assert(atype == actorType)
        print('provider is already actor (with the correct actor type)')
    else:
        xbr.xbrNetwork.functions.joinMarket(marketId, actorType).transaction({'from': acct_provider, 'gas': 200000})
        print('joined as provider in the market!')


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
