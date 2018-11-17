from __future__ import absolute_import

from xbr._version import __version__
from xbr._abi import XBR_DEBUG_TOKEN_ADDR, XBR_TOKEN_ABI
from xbr._abi import XBR_DEBUG_NETWORK_ADDR, XBR_NETWORK_ABI

version = __version__

xbrToken = None
xbrNetwork = None


def setProvider(_w3):
    global xbrToken
    global xbrNetwork
    xbrToken = _w3.eth.contract(address=XBR_DEBUG_TOKEN_ADDR, abi=XBR_TOKEN_ABI)
    xbrNetwork = _w3.eth.contract(address=XBR_DEBUG_NETWORK_ADDR, abi=XBR_NETWORK_ABI)


__all__ = (
    'version',
    'setProvider',
    'xbrToken',
    'xbrNetwork',
)
