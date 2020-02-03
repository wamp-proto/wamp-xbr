.PHONY: list coverage docs clean build test

TRUFFLE = ${PWD}/node_modules/.bin/truffle
SOLHINT = ${PWD}/node_modules/.bin/solhint
COVERAGE = ${PWD}/node_modules/.bin/solidity-coverage

SCOUR = scour
SCOUR_FLAGS = --remove-descriptive-elements --enable-comment-stripping --enable-viewboxing --indent=none --no-line-breaks --shorten-ids

AWS_DEFAULT_REGION = eu-central-1
AWS_S3_BUCKET_NAME = xbr.foundation

XBR_DEBUG_TOKEN_ADDR="0x78890bF748639B82D225FA804553FcDBe5819576"
XBR_DEBUG_NETWORK_ADDR="0x96f2b95733066aD7982a7E8ce58FC91d12bfbB2c"


default:
	@echo 'Targets:'
	@echo
	@echo '   clean                  '
	@echo '   clean_all              '
	@echo '   clean_docs             '
	@echo ' * clean_ganache          '
	@echo '   clean_images           '
	@echo
	@echo ' * install                '
	@echo '   update_dependencies    '
	@echo
	@echo ' * run_ganache            '
	@echo
	@echo '   compile                '
	@echo '   lint                   '
	@echo ' * test                   '
	@echo '   coverage               '
	@echo ' * deploy                 '
	@echo '   deploy_ropsten         '
	@echo '   deploy_ropsten_dryrun  '
	@echo
	@echo '   docs                   '
	@echo '   run_docs               '
	@echo '   images                 '
	@echo '   check_docs             '
	@echo '   spellcheck_docs        '
	@echo '   publish_docs           '
	@echo
	@echo '   publish_ipfs_eula      '
	@echo '   publish_ipfs_members   '
	@echo
	@echo '   truffle_build          '
	@echo '   truffle_compile        '
	@echo '   truffle_test           '
	@echo

list_targets:
	@grep '^[^#[:space:]].*:' Makefile

clean: clean_docs
	-rm -rf ./build/
	-rm -rf ./dist/
	-rm -rf ./*.egg-info/
	-rm -rf ./.tox/
	-rm -rf ./coverage
	-rm -rf ./coverageEnv
	-rm -f ./coverage.json
	-rm -f ./npm-debug.log
	-rm -f ./scTopics
	-rm -f ./*.pid
	-find . -name "__pycache__" -type d -exec rm -rf {} \;

clean_all: clean_docs clean
	-rm -rf ./node_modules/
	-rm -f ./package-lock.json


install:
	pip install -r requirements.txt
	npm install --only=dev
	npm outdated
	@echo "run 'ncu -u' to update deps .."
	$(TRUFFLE) version
	$(SOLHINT) version

update_dependencies:
	npm i -g npm-check-updates
	ncu -u
	npm install

lint:
	$(SOLHINT) "contracts/**/*.sol"

test:
	$(TRUFFLE) test --network ganache

coverage:
	truffle run coverage

compile:
	-rm ./abi/*.json
	-rm ./build/contracts/*.json
	$(TRUFFLE) compile --all
	cp build/contracts/*.json ./abi/
	rm ./abi/XBRTest.json
	find ./abi
	-rm ../../crossbario/autobahn-python/autobahn/xbr/contracts/*.json
	cp -r abi/*.json ../../crossbario/autobahn-python/autobahn/xbr/contracts/
	-rm ../../crossbario/autobahn-js/packages/autobahn-xbr/lib/contracts/*.json
	cp -r abi/*.json ../../crossbario/autobahn-js/packages/autobahn-xbr/lib/contracts/

deploy:
	$(TRUFFLE) migrate --reset --network ganache

deploy_ropsten_dryrun:
	$(TRUFFLE) migrate --reset --network ropsten --dry-run

deploy_ropsten:
	$(TRUFFLE) migrate --reset --network ropsten

deploy_rinkeby_dryrun:
	$(TRUFFLE) migrate --reset --network rinkeby --dry-run

deploy_rinkeby:
	$(TRUFFLE) migrate --reset --network rinkeby

#
# Truffle in Docker
#
truffle_build:
	# docker-compose build --no-cache truffle
	docker-compose build truffle

truffle_compile:
	docker run -it --rm --volume=${PWD}:/code:rw crossbario/truffle
	# docker run -it --rm -v${PWD}:/code --network host --entrypoint /bin/bash crossbario/truffle

truffle_test:
	docker run -it --rm --volume=${PWD}:/code:rw --network=host crossbario/truffle test --network ganache


#
# XBR Protocol smart contracts
#
publish_ipfs_eula:
	cd ipfs && zip -r - xbr-eula | ipfs add

publish_ipfs_members:
	cd ipfs/members && ipfs add *.rdf


#
# Ganache test blockchain as docker container "xbr-protocol_ganache_1"
#

# The following is for building our development blockchain docker image, which is
# Ganache + deployed XBR smart contracts + initial balances for testaccounts (both ETH and XBR).
#
# The XBR contracts are deployed using a different seedphrase than the test accounts
# which are initialized with some ETH+XBR balance!
#
# The deploying onwer is derived from a seedphrase read from an env var:
#
# 	export XBR_HDWALLET_SEED="..."
#
# and results in contract addresses:
#
# 	export XBR_DEBUG_TOKEN_ADDR="0x78890bF748639B82D225FA804553FcDBe5819576"
# 	export XBR_DEBUG_NETWORK_ADDR="0x96f2b95733066aD7982a7E8ce58FC91d12bfbB2c"
#
# Then, 20 test accounts are setup from this seed phrase:
#
# 	"myth like bonus scare over problem client lizard pioneer submit female collect"
#
# The resulting XBR blockchain docker image is published to:
#
# public: 	https://hub.docker.com/r/crossbario/crossbarfx-blockchain
# admin:  	https://cloud.docker.com/u/crossbario/repository/docker/crossbario/crossbarfx-blockchain
#

# clean file staging area to create blockchain docker image
clean_ganache:
	-rm -rf ./docker/data/
	mkdir ./docker/data/

# run a blockchain from the empty staging area
run_ganache:
	# sudo chown -R 1000:1000 docker/data/
	docker-compose up --force-recreate ganache

# deploy xbr smart contract to blockchain
deploy_ganache:
	$(TRUFFLE) migrate --reset --network ganache

# initialize blockchain data
init_ganache:
	XBR_DEBUG_TOKEN_ADDR=0xcfeb869f69431e42cdb54a4f4f105c19c080a601 \
	XBR_DEBUG_NETWORK_ADDR=0x254dffcd3277c0b1660f6d42efbb754edababc2b \
	python docker/init-blockchain.py --gateway http://localhost:1545

# build a blockchain (ganache based) docker image using the initialized data from the staging area
build_ganache:
	cd docker && docker build -t crossbario/crossbarfx-blockchain:latest -f Dockerfile.ganache .

# publish locally created docker image with xbr-preinitialized ganache blockchain
publish_ganache:
	docker push crossbario/crossbarfx-blockchain:latest


#
# build optimized SVG files from source SVGs
#
BUILDDIR = docs/_static/gen

# build "docs/_static/gen/*.svg" optimized SVGs from "docs/_graphics/*.svg" using Scour
# note: this currently does not recurse into subdirs! place all SVGs flat into source folder
SOURCEDIR = docs/_static/drawing

SOURCES = $(wildcard $(SOURCEDIR)/*.svg)
OBJECTS = $(patsubst $(SOURCEDIR)/%.svg, $(BUILDDIR)/%.svg, $(SOURCES))

$(BUILDDIR)_exists:
	mkdir -p $(BUILDDIR)

images: $(BUILDDIR)_exists $(BUILDDIR)/$(OBJECTS)
	@echo "optimizing images:\n"$(SOURCES)

$(BUILDDIR)/%.svg: $(SOURCEDIR)/%.svg
	$(SCOUR) $(SCOUR_FLAGS) $< $@

clean_images:
	-rm -rf docs/_static/gen


#
# XBR Protocol documentation
#
docs:
	cd docs && sphinx-build -b html . _build

check_docs:
	cd docs && sphinx-build -nWT -b dummy . _build

spellcheck_docs:
	cd docs && sphinx-build -nWT -b spelling \
		-d ./_build/doctrees . ./_build/spelling

run_docs: docs
	twistd --nodaemon web --path=docs/_build --listen=tcp:8090

# build and deploy latest docs:
#   => https://s3.eu-central-1.amazonaws.com/xbr.foundation/docs/protocol/index.html
#   => https://xbr.network/docs/protocol/index.html
publish_docs:
	aws s3 cp --recursive --acl public-read \
		./docs/_build s3://$(AWS_S3_BUCKET_NAME)/docs/protocol

clean_docs:
	-rm -rf docs/_build
