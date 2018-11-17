import sys
import web3
import xbr


def main(account):
    level = xbr.xbrNetwork.functions.getMemberLevel(account).call()
    if not level:
        eula = 'QmU7Gizbre17x6V2VR1Q2GJEjz6m8S1bXmBtVxS2vmvb81'
        #profile = 'QmdeJDNEimpjWPsHCVTDCowQSK9j1tpoW9eW3mjhrTw6wu'
        profile = ''

        xbr.xbrNetwork.functions.register(eula, profile).transact({'from': account, 'gas': 1000000})
        print('new member {} registered'.format(account))
    else:
        print('{} is already a member (Level {})'.format(account, level))

    eula = xbr.xbrNetwork.functions.getMemberEula(account).call()
    profile = xbr.xbrNetwork.functions.getMemberProfile(account).call()
    print('EULA: {}, Profile: {}'.format(eula, profile))


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
    main(w3.eth.accounts[1])
