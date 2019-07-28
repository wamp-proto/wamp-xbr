clean:
	-rm -rf ./privchain/geth
	-rm -rf ./privchain/keystore
	ls -la ./privchain

init:
	geth --datadir ./privchain init genesis.json
	find ./privchain

run:
	geth --datadir ./privchain --networkid 5777 --port 3000 --nodiscover --maxpeers=0 --allow-insecure-unlock \
		--rpc --rpcport 1545 --rpcaddr 127.0.0.1 --rpccorsdomain "*" --rpcapi "eth,net,web3"
