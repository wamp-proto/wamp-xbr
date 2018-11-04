.PHONY: docs clean build

default:
	@echo 'Targets: clean compile test'

clean:
	-rm -rf ./build
	-rm -rf docs/_build

requirements:
	pip install -r requirements.txt
	npm install

# populus does not follow symlinks: https://github.com/ethereum/populus/issues/379
zeppelin:
	cp -R openzeppelin-solidity/contracts contracts/zeppelin

build:
	populus compile contracts/XBRToken.sol

test: build
	#pytest --disable-pytest-warnings tests
	pytest -p no:warnings 2> /dev/null


chain_init:
	populus chain new horton
	chains/horton/./init_chain.sh

chain_run:
	chains/horton/./run_chain.sh

chain_deploy:
	populus deploy --chain tester --no-wait-for-sync

chain_attach:
	geth attach chains/horton/chain_data/geth.ipc


docs:
	cd docs && sphinx-build -b html . _build

clean_docs:
	-rm -rf docs/_build

test_docs: docs
	twistd --nodaemon web --path=docs/_build --listen=tcp:8080
