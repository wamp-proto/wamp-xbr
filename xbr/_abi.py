import os
import json
import pkg_resources

os.environ['ETH_HASH_BACKEND'] = 'pycryptodome'

from eth_hash.backends.pycryptodome import keccak256  # noqa
import web3


print('Using eth_hash backend {}'.format(keccak256))


XBR_TOKEN_FN = pkg_resources.resource_filename('xbr', 'contracts/XBRToken.json')
XBR_NETWORK_FN = pkg_resources.resource_filename('xbr', 'contracts/XBRNetwork.json')
XBR_PAYMENT_CHANNEL_FN = pkg_resources.resource_filename('xbr', 'contracts/XBRPaymentChannel.json')


if 'XBR_DEBUG_TOKEN_ADDR' in os.environ:
    XBR_DEBUG_TOKEN_ADDR = web3.Web3.toChecksumAddress(os.environ['XBR_DEBUG_TOKEN_ADDR'])
else:
    XBR_DEBUG_TOKEN_ADDR = '0x0'
    print('WARNING: The XBR smart contracts are not yet depoyed to public networks. Please set XBR_DEBUG_TOKEN_ADDR manually.')

if 'XBR_DEBUG_NETWORK_ADDR' in os.environ:
    XBR_DEBUG_NETWORK_ADDR = web3.Web3.toChecksumAddress(os.environ['XBR_DEBUG_NETWORK_ADDR'])
else:
    XBR_DEBUG_NETWORK_ADDR = '0x0'
    print('WARNING: The XBR smart contracts are not yet depoyed to public networks. Please set XBR_DEBUG_NETWORK_ADDR manually.')


def _load_json(contract_name):
    fn = pkg_resources.resource_filename('xbr', 'contracts/{}.json'.format(contract_name))
    # fn = os.path.join(os.path.dirname(__file__), '../build/contracts/{}.json'.format(contract_name))
    with open(fn) as f:
        data = json.loads(f.read())
    return data


XBR_TOKEN_ABI = _load_json('XBRToken')['abi']
XBR_NETWORK_ABI = _load_json('XBRNetwork')['abi']
XBR_PAYMENT_CHANNEL_ABI = _load_json('XBRPaymentChannel')['abi']
