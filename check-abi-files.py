import os
import json

# https://github.com/ethereum/EIPs/blob/master/EIPS/eip-170.md
MAX_CONTRACT_BYTECODE_SIZE = 24 * 1024

results = []

for fn in os.listdir('build/contracts'):
    fn = os.path.join('build/contracts', fn)
    with open(fn, 'rb') as f:
        data = f.read()
        obj = json.loads(data)
        bytecode = int((len(obj.get('bytecode', '0x')) - 2) / 2)
        deployedBytecode = int((len(obj.get('deployedBytecode', '0x')) - 2) / 2)
        if deployedBytecode > MAX_CONTRACT_BYTECODE_SIZE:
            warn = True
        else:
            warn = False
        results.append((fn, bytecode, deployedBytecode))
results = sorted(results)

print('\nCompiled (deployed) contract size - the maximum allowed (per-contract) is {} bytes!\n\n'.format(MAX_CONTRACT_BYTECODE_SIZE))
for fn, bytecode, deployedBytecode in results:
    print('ABI file: {:<50} bytecode: {:>5} bytes    deployedBytecode: {:>5} bytes {}'.format(
        '"' + fn + '"', bytecode, deployedBytecode, '  WARNING - maximum deployed contract size of 24kB exceeded' if warn else ''))
print('\n')
