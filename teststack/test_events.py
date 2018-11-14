# https://github.com/ethereum/web3.py/issues/730#issuecomment-379136038

import time
import web3

from solc import compile_source

from web3 import Web3, EthereumTesterProvider


contract_code = '''
contract EmitEvent {

    uint8 public _myVar;
    event Event(string indexed _var);

    function emitEvent() public {
        Event("!!!");
    }
}
'''

def wait_on_tx_receipt(tx_hash):
    start_time = time.time()
    while True:
        if start_time + 60 < time.time():
            raise TimeoutError("Timeout occurred waiting for tx receipt")
        if w3.eth.getTransactionReceipt(tx_hash):
            return w3.eth.getTransactionReceipt(tx_hash)

compiled_sol = compile_source(contract_code)
contract_interface = compiled_sol['<stdin>:EmitEvent']

w3 = Web3(EthereumTesterProvider())

contract = w3.eth.contract(
    abi=contract_interface['abi'],
    bytecode=contract_interface['bin'])


tx_hash = contract.constructor().transact(
    transaction={
        'from': w3.eth.accounts[0],
        'gas': 410000})

tx_receipt = w3.eth.getTransactionReceipt(tx_hash)
contract_address = tx_receipt['contractAddress']

# Instatiate contract
emitEvent = w3.eth.contract(address=contract_address, abi=contract_interface['abi'])

# Create log filter instance
_filter = emitEvent.events.Event.createFilter(fromBlock=0)

# Event emitting transaction
tx_hash = emitEvent.functions.emitEvent().transact()

# Wait for transaction to be mined
receipt = wait_on_tx_receipt(tx_hash)

# Poll filter
print(_filter.get_new_entries())
