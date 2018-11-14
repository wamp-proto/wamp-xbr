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

XBR_TOKEN_ABI = load_json('XBRToken')['abi']
XBR_NETWORK_ABI = load_json('XBRNetwork')['abi']
XBR_PAYMENT_CHANNEL_ABI = load_json('XBRPaymentChannel')['abi']

XBR_TOKEN_ADDR_PLAIN = '0xcfeb869f69431e42cdb54a4f4f105c19c080a601'
XBR_TOKEN_ADDR = web3.Web3.toChecksumAddress(XBR_TOKEN_ADDR_PLAIN)
XBR_NETWORK_ADDR = web3.Web3.toChecksumAddress('0x254dffcd3277c0b1660f6d42efbb754edababc2b')


# https://web3py.readthedocs.io/en/v3.16.5/providers.html#web3.providers.rpc.HTTPProvider
# http://docs.python-requests.org/en/master/api/?highlight=timeout#requests.request

if True:
    provider = web3.Web3.HTTPProvider("http://127.0.0.1:8545", request_kwargs={'timeout': 5})
    w3 = web3.Web3(provider)
else:
    from web3.auto import w3

if w3.isConnected():
    print('connected to network {}'.format(w3.version.network))

account = w3.eth.accounts[0]
print('using account address {}'.format(account))

xbr_network = w3.eth.contract(address=XBR_NETWORK_ADDR, abi=XBR_NETWORK_ABI)
xbr_token = w3.eth.contract(address=XBR_TOKEN_ADDR, abi=XBR_TOKEN_ABI)

balance_eth = w3.eth.getBalance(account)
balance_xbr = xbr_token.functions.balanceOf(account).call()

print('current balances: {} ETH, {} XBR'.format(balance_eth, balance_xbr))

# web3.eth.filter({'fromBlock': 1000000, 'toBlock': 1000100, 'address': '0x6c8f2a135f6ed072de4503bd7c4999a1a17f824b'})

event_filter = w3.eth.filter({
    "address": XBR_TOKEN_ADDR
})

XBR_TOKEN_ADDR = XBR_TOKEN_ADDR_PLAIN

event_filter = {'fromBlock': 0, 'toBlock': 'latest', 'address': XBR_TOKEN_ADDR}
logs = w3.eth.getLogs(event_filter)
print(len(logs))
#pprint(logs)

event_filter = {'fromBlock': 0, 'toBlock': 'latest', 'address': XBR_TOKEN_ADDR}
logs = w3.eth.getLogs(event_filter)
print(len(logs))
#pprint(logs)

# Contract.events.<event name>.createFilter(fromBlock=block, toBlock=block, argument_filters={"arg1": "value"}, topics=[])
# https://web3py.readthedocs.io/en/stable/contracts.html#web3.contract.Contract.eventFilter

#event_filter = xbr_network.events.MemberCreated.createFilter(fromBlock=0, toBlock='latest', address=XBR_NETWORK_ADDR)
event_filter = xbr_network.events.MemberCreated.createFilter(fromBlock=0, toBlock='latest')
events = event_filter.get_new_entries()
pprint(events)

event_filter = xbr_network.events.PaymentChannelCreated.createFilter(fromBlock=0, toBlock='latest')
events = event_filter.get_new_entries()
pprint(events)


# https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/token/ERC20/IERC20.sol

event_filter = xbr_token.events.Transfer.createFilter(fromBlock=0, toBlock='latest', address=XBR_TOKEN_ADDR_PLAIN)
events = event_filter.get_all_entries()
pprint(events)


#print(xbr_network.events.MemberCreated())
#events = xbr_network.allEvents(filter).get()

myfilter = xbr_token.eventFilter('Transfer', {'fromBlock': 0,'toBlock': 'latest', 'address': XBR_TOKEN_ADDR})
eventlist = myfilter.get_all_entries()
pprint(eventlist)

myfilter =  xbr_token.events.Transfer.createFilter(fromBlock=0, toBlock='latest', address=XBR_TOKEN_ADDR)
eventlist = myfilter.get_all_entries()
pprint(eventlist)

#XBR_TOKEN_ADDR = '0x4bf749ec68270027c5910220ceab30cc284c7ba2'

#event_filter = xbr_token.events.Transfer.createFilter(argument_filters={'filter': {'address': XBR_TOKEN_ADDR}})
#entries = event_filter.get_all_entries()
#pprint(eventlist)

myfilter = xbr_token.eventFilter('Transfer', {'fromBlock': 0,'toBlock': 'latest'})
eventlist = myfilter.get_all_entries()
pprint(eventlist)

#event_filter = w3.eth.filter({'fromBlock':0, 'toBlock': 'latest', 'address': XBR_TOKEN_ADDR, 'topics':['0x0bd8ab3a75b603beb8c382868ae3ec451c35bb41444f6b0c2175e0505424e95c']})
event_filter = w3.eth.filter({'fromBlock':0, 'toBlock': 'latest', 'address': XBR_TOKEN_ADDR})

event_logs = w3.eth.getFilterLogs(event_filter.filter_id)

pprint(event_logs)

myfilter =  xbr_token.events.Transfer.createFilter(fromBlock=0)
logs = w3.eth.getLogs(myfilter.filter_params)
print(len(logs))


myfilter =  xbr_network.events.MemberCreated.createFilter(fromBlock=0)
pprint(dir(myfilter))
print(myfilter.get_all_entries())
print(myfilter.get_new_entries())
logs = w3.eth.getLogs(myfilter.filter_params)
print(len(logs))
