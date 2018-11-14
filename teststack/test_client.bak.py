import sys
import os
import json
import binascii
from pprint import pprint

import web3

# w3 = Web3(Web3.HTTPProvider("http://127.0.0.1:7545", request_kwargs={'timeout': 10}))
w3 = web3.Web3(web3.Web3.HTTPProvider("http://127.0.0.1:8545", request_kwargs={'timeout': 10}))

res = {}

res['current_block_no'] = w3.eth.blockNumber
# res['current_block'] = w3.eth.getBlock('latest')

accounts = {}
for account in w3.eth.accounts:
    accounts[account] = w3.eth.getBalance(account)

res['accounts'] = accounts

pprint(res)

XBR_NETWORK_ADDR = w3.toChecksumAddress('0xad888d0ade988ebee74b8d4f39bf29a8d0fe8a8d')

fn = os.path.join(os.path.dirname(__file__), '../build/contracts/XBRNetwork.json')

with open(fn) as f:
    data = json.loads(f.read())
    network = w3.eth.contract(address=XBR_NETWORK_ADDR, abi=data['abi'])
    #pprint(dir(network.functions))

    market_id = '0x475f7a898a86abbbd7a9e017abc7c0f0b674dd91b0fd2a3b463feb33e71853ca'
    actor = w3.eth.accounts[2]
    print(actor)

    actor_type = network.functions.getMarketActorType(market_id, actor).call()

    print('actor_type={}'.format(actor_type))

    # 0xd03ea8624C8C5987235048901fB614fDcA89b117
    private_key = '0xADD53F9A7E588D003326D1CBF9E4A43C061AADD9BC938C843A79E7B4FD2AD743'
    maker = web3.eth.Account.privateKeyToAccount(private_key)
    print(maker.address)

    market_id = network.functions.getMarketByMaker(maker.address).call()
    if _market_id:
        _market_id = '0x{}'.format(binascii.b2a_hex(_market_id).decode())
        print('_market_id', _market_id)
    else:
        print('market maker has no market assigned!')
        sys.exit(1)

    getAllMarketActors

    actor_type = network.functions.getMarketActorType(market_id, maker.address).call()
    print('actor_type={}'.format(actor_type))

    _maker = network.functions.getMarketMaker(market_id).call()
    print('_maker={}'.format(_maker))
