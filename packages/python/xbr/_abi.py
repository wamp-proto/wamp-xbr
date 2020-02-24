# Copyright (c) Crossbar.io Technologies GmbH. Licensed under the Apache 2.0 license.

import json
import pkg_resources


__all__ = ('XBR_TOKEN_ABI', 'XBR_NETWORK_ABI', 'XBR_CHANNEL_ABI')

def _load_json(contract_name):
    fn = pkg_resources.resource_filename('xbr', 'abi/{}.json'.format(contract_name))
    with open(fn) as f:
        data = json.loads(f.read())
    return data


XBR_TOKEN_ABI = _load_json('XBRToken')['abi']
XBR_NETWORK_ABI = _load_json('XBRNetwork')['abi']
XBR_CHANNEL_ABI = _load_json('XBRChannel')['abi']
