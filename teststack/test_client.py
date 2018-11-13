import json
from pprint import pprint
from web3 import Web3

# w3 = Web3(Web3.HTTPProvider("http://127.0.0.1:7545", request_kwargs={'timeout': 10}))
w3 = Web3(Web3.HTTPProvider("http://127.0.0.1:8545", request_kwargs={'timeout': 10}))

res = {}

res['current_block_no'] = w3.eth.blockNumber
# res['current_block'] = w3.eth.getBlock('latest')

accounts = {}
for account in w3.eth.accounts:
    accounts[account] = w3.eth.getBalance(account)

res['accounts'] = accounts

pprint(res)

XBR_NETWORK_ADDR = w3.toChecksumAddress('0x3cc7b9a386410858b412b00b13264654f68364ed')


with open('../build/contracts/XBRNetwork.json') as f:
    data = json.loads(f.read())
    network = w3.eth.contract(address=XBR_NETWORK_ADDR, abi=data['abi'])
    pprint(dir(network.functions))

    actor_type = network.functions.getMarketActorType(w3.eth.accounts[0])
    print('actor_type={}'.format(actor_type))
