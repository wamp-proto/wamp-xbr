from pprint import pprint
import os
import json
import web3

print('using web3.py v{}'.format(web3.__version__))

def load_json(contract_name):
    fn = os.path.join(os.path.dirname(__file__), '../build/contracts/{}.json'.format(contract_name))
    with open(fn) as f:
        data = json.loads(f.read())
    return data

TOKEN_ABI = load_json('XBRToken')['abi']

from web3.auto import w3

token = w3.eth.contract(address='0xcfeb869f69431e42cdb54a4f4f105c19c080a601', abi=TOKEN_ABI)

event_filter = token.events.Transfer().createFilter(fromBlock=0)

l1 = len(event_filter.get_all_entries())
l2 = len(w3.eth.getLogs(event_filter.filter_params))

print(l1, l2)

print(dir(token.events.Transfer))
print(dir(token.events.Transfer()))

pprint(event_filter.filter_params)


tx_hash = '0xe82699c7a262b331c9ffea17a34775f36d47501ba0d6b624b04e629e940a0b85'
receipt = w3.eth.getTransactionReceipt(tx_hash)
print(receipt)
args = token.events.Transfer().processReceipt(receipt)
print(args)


res = w3.eth.getLogs(event_filter.filter_params)
pprint(res)
for r in res:
    recepit = w3.eth.getTransactionReceipt(r['transactionHash'])
    args = token.events.Transfer().processReceipt(receipt)
    args = args[0].args
    print(args)
