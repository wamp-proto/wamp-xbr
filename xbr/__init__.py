from __future__ import absolute_import

from xbr._version import __version__
from xbr._abi import XBR_DEBUG_TOKEN_ADDR, XBR_TOKEN_ABI
from xbr._abi import XBR_DEBUG_NETWORK_ADDR, XBR_NETWORK_ABI

version = __version__

token = None
network = None


def initialize(_w3):
    global token
    global network
    token = _w3.eth.contract(address=XBR_DEBUG_TOKEN_ADDR, abi=XBR_TOKEN_ABI)
    network = _w3.eth.contract(address=XBR_DEBUG_NETWORK_ADDR, abi=XBR_NETWORK_ABI)
    # print('xbr initialized!', token, network)


__all__ = (
    'version',
    'initialize',
    'token',
    'network',
)
