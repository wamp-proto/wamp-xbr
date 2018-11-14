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

def load_json(contract_name):
    fn = os.path.join(os.path.dirname(__file__), '../build/contracts/{}.json'.format(contract_name))
    with open(fn) as f:
        data = json.loads(f.read())
    return data


XBR_TOKEN_ABI = load_json('XBRToken')['abi']
XBR_NETWORK_ABI = load_json('XBRNetwork')['abi']
XBR_PAYMENT_CHANNEL_ABI = load_json('XBRPaymentChannel')['abi']

XBR_TOKEN_ADDR = w3.toChecksumAddress('0x4bf749ec68270027c5910220ceab30cc284c7ba2')
XBR_NETWORK_ADDR = w3.toChecksumAddress('0xad888d0ade988ebee74b8d4f39bf29a8d0fe8a8d')

xbr_network = w3.eth.contract(address=XBR_NETWORK_ADDR, abi=XBR_NETWORK_ABI)
xbr_token = w3.eth.contract(address=XBR_TOKEN_ADDR, abi=XBR_TOKEN_ABI)

# 0xd03ea8624C8C5987235048901fB614fDcA89b117
private_key = '0xADD53F9A7E588D003326D1CBF9E4A43C061AADD9BC938C843A79E7B4FD2AD743'
maker = web3.eth.Account.privateKeyToAccount(private_key)
print(maker.address)

market_id = xbr_network.functions.getMarketByMaker(maker.address).call()
if market_id:
    market_id = '0x{}'.format(binascii.b2a_hex(market_id).decode())
    print('market_id', market_id)
else:
    print('market maker has no market assigned!')
    sys.exit(1)

actors = xbr_network.functions.getAllMarketActors(market_id).call()
if actors:
    print('{} actors in market'.format(len(actors)))
    for actor in actors:
        actor_type = xbr_network.functions.getMarketActorType(market_id, actor).call()
        print('actor: addr={}, type={}'.format(actor, actor_type))
else:
    print('no actors in market yet')

channels = xbr_network.functions.getAllMarketPaymentChannels(market_id).call()
if channels:
    print('{} channels in market'.format(len(channels)))
    for channel in channels:
        xbr_payment_channel = w3.eth.contract(address=channel, abi=XBR_PAYMENT_CHANNEL_ABI)

        sender = xbr_payment_channel.functions.sender().call()
        delegate = xbr_payment_channel.functions.delegate().call()
        recipient = xbr_payment_channel.functions.recipient().call()
        amount = xbr_payment_channel.functions.amount().call()

        print('channel {}: amount={}, sender={}, delegate={}, recipient={}'.format(channel, amount, sender, delegate, recipient))


private_key = '646F1CE2FDAD0E6DEEEB5C7E8E5543BDDE65E86029E2FD9FC169899C440A7913'
consumer = web3.eth.Account.privateKeyToAccount(private_key)
print(consumer.address)


private_key = '6CBED15C793CE57650B9877CF6FA156FBEF513C4E6134F022A85B1FFDD59B2A1'
market = web3.eth.Account.privateKeyToAccount(private_key)
print(market.address)


account = market.address
name = 'MyMarket42'
#decimals = xbr_token.decimals()
decimals = 18
terms = '0x0000000000000000000000000000000000000000000000000000000000000000'
providerSecurity = 100 * (10 ** decimals)
consumerSecurity = 100 * (10 ** decimals)

import os

marketId = str(web3.Web3.sha3(account.encode() + 'Market2'.encode()))
marketId = os.urandom(32)

xbr_network.functions.openMarket(marketId, consumer.address, terms, providerSecurity,
    consumerSecurity).transact({'from': market.address, 'gas': 1000000})

#>>> from web3.auto import w3
#>>> token = w3.eth.contract(abi=...)
#>>> transfer = token.functions.transfer("ethereumfoundation.eth", 1).buildTransaction()

#>>> signed = w3.eth.account.signTransaction(transfer, key)
#>>> w3.eth.sendRawTransaction(signed.rawTransaction)
