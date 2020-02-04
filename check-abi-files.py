import os
import json

# https://github.com/ethereum/EIPs/blob/master/EIPS/eip-170.md
MAX_CONTRACT_BYTECODE_SIZE = 24 * 1024


for fn in os.listdir('abi'):
    fn = os.path.join('abi', fn)
    with open(fn, 'rb') as f:
        data = f.read()
        obj = json.loads(data)
        bytecode = int((len(obj.get('bytecode', '0x')) - 2) / 2)
        deployedBytecode = int((len(obj.get('deployedBytecode', '0x')) - 2) / 2)
        if deployedBytecode > MAX_CONTRACT_BYTECODE_SIZE:
            warn = True
        else:
            warn = False
        print('ABI file {:<30} bytecode= {:<6} bytes, deployedBytecode= {:<6} bytes {}'.format(
            '"' + fn + '"', bytecode, deployedBytecode, '  WARNING - maximum deployed contract size of 24kB exceeded' if warn else ''))
