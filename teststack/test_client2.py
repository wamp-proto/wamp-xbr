from pprint import pprint
from web3.auto import w3
import xbr

xbr.initialize(w3)

event_filter = xbr.token.events.Transfer().createFilter(fromBlock=0)

# FIXME: event_filter.get_all_entries() should (also) allow to get the events

result = w3.eth.getLogs(event_filter.filter_params)
for evt in result:
    receipt = w3.eth.getTransactionReceipt(evt['transactionHash'])
    args = xbr.token.events.Transfer().processReceipt(receipt)
    args = args[0].args
    print('event: {} XBR token transferred from {} to {}'.format(args.value, args['from'], args.to))
