clean:
	-rm -rf ./privchain/geth
	-rm -rf ./privchain/keystore
	ls -la ./privchain

init:
	geth --datadir ./privchain init genesis.json
	find ./privchain

run:
	geth --datadir ./privchain --networkid 5777 --port 3000 --nodiscover --maxpeers=0 --allow-insecure-unlock \
		--nodiscover --rpc --rpcport 1545 --rpcaddr 127.0.0.1 --rpccorsdomain "*" --rpcapi "eth,net,web3" \
		--unlock 0 \
		--mine --minerthreads 1 --etherbase 0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1

# --unlock 0x4c5E35F5bC1D26d7a6Bb7Ff343CDaB110bC87B5E \
# --rpcapi eth,web3,personal,net --unlock 0 --password ~/ethereum-tutorial/private/password.sec

# > eth.getBalance("0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1")
# 1e+23
# > eth.getBalance("0x0000000000000000000000000000000000000001")
# 0
# eth.blockNumber
# 0
console:
	geth --datadir ./privchain attach

account:
	geth --datadir ./privchain account new
	geth --datadir ./privchain account list

_console:
	geth --datadir ./privchain --networkid 5777 --port 3000 --nodiscover --maxpeers=0 --allow-insecure-unlock \
		--rpc --rpcport 1545 --rpcaddr 127.0.0.1 --rpccorsdomain "*" --rpcapi "eth,net,web3" console

# personal.listAccounts
# web3.fromWei(eth.getBalance(eth.accounts[0]), "ether")

# eth.sendTransaction({from: eth.coinbase, to: eth.accounts[1], value: web3.toWei(10, "ether")})
# eth.sendTransaction({from: eth.accounts[0], to: "0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1", value: web3.toWei(10, "ether")})

# miner.setEtherbase("0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1")
# miner.start(1)
