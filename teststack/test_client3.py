from pprint import pprint
from web3.auto import w3
import web3
import xbr

w3 = web3.Web3(web3.Web3.WebsocketProvider('ws://127.0.0.1:8545'))

xbr.setProvider(w3)

event_filter = xbr.xbrToken.events.Transfer.createFilter(fromBlock=0)
# event_filter = mycontract.events.myEvent.createFilter(fromBlock='latest', argument_filters={'arg1':10})

#print(event_filter)

# FIXME: event_filter.get_all_entries() should (also) allow to get the events

#result = w3.eth.getLogs(event_filter.filter_params)
#for evt in result:
#    receipt = w3.eth.getTransactionReceipt(evt['transactionHash'])
#    args = xbr.token.events.Transfer().processReceipt(receipt)
#    args = args[0].args
#    print('event: {} XBR token transferred from {} to {}'.format(args.value, args['from'], args.to))
