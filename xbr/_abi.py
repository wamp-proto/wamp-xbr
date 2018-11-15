import os
import json

import web3


if 'XBR_DEBUG_TOKEN_ADDR' in os.environ:
    XBR_DEBUG_TOKEN_ADDR = web3.Web3.toChecksumAddress(os.environ['XBR_DEBUG_TOKEN_ADDR'])
else:
    raise RuntimeError('The XBR smart contracts are not yet depoyed to public networks. Please set XBR_DEBUG_TOKEN_ADDR manually.')

if 'XBR_DEBUG_NETWORK_ADDR' in os.environ:
    XBR_DEBUG_NETWORK_ADDR = web3.Web3.toChecksumAddress(os.environ['XBR_DEBUG_NETWORK_ADDR'])
else:
    raise RuntimeError('The XBR smart contracts are not yet depoyed to public networks. Please set XBR_DEBUG_NETWORK_ADDR manually.')


def _load_json(contract_name):
    fn = os.path.join(os.path.dirname(__file__), '../build/contracts/{}.json'.format(contract_name))
    with open(fn) as f:
        data = json.loads(f.read())
    return data


XBR_TOKEN_ABI = _load_json('XBRToken')['abi']
XBR_NETWORK_ABI = _load_json('XBRNetwork')['abi']
