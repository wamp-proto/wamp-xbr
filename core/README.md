


a caller adds a "max price willing to pay" attribute and signs the outgoing, WAMP-cryptobox encrypted call with the Ethereum signing algorithm (ecsign, sec256k1)

each CF routing node the call is passing through updates its current balance for the call originator, adds the updated balance to the call and signs with Ethereum

the callee, when answering the call, will update the current balance for the call originator (caller), adds the updated balance to the call and signs with Ethereum

each CF routing node on the way back of the call result to the caller will again update the current balance for the caller, add the updated balance to the call and signs with Ethereum

the caller will receive the call result with the appended list of balance updates and signatures

the chain above will be interrupted when the price appended in the call request exceeds the "max price" the caller initially announced

all of above can at any time request clearing by submitting the latest transactions per originator



participant 7 asks market to be cleared
participant 7 asks market to be cleared for all transactions with participant 19



Clear participant in market:

all CFC nodes are watching the blockchain and will read the request to clear a participant in a market (this triggers a timer)

each CFC node will call into all its CF nodes:

    get_last_transaction(market_id, participant_id)

the CFC node will aggregate the results by participant, and filing a transaction
to the blockchain calling into the xbr smart contract to submit its know last transaction

when the timeout is over, anyone can call the finalize method to distribute tokens according to the last transaction submitted




publish a management event to all CF nodes:

    clear_participant (market_id, participant_id)

each CF node receiving the management event will accumulate everything for market/participant and report back to CFC


- P256k1 replaced with ALT_BN128

https://blog.ethereum.org/2017/01/19/update-integrating-zcash-ethereum/



tls-unique

