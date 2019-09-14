.PHONY: crossbar coverage docs clean build test

TRUFFLE = ${PWD}/node_modules/truffle/build/cli.bundled.js
SOLHINT = ${PWD}/node_modules/solhint/solhint.js
COVERAGE = ${PWD}/node_modules/solidity-coverage/bin/exec.js
SCOUR = scour
SCOUR_FLAGS = --remove-descriptive-elements --enable-comment-stripping --enable-viewboxing --indent=none --no-line-breaks --shorten-ids

AWS_DEFAULT_REGION = eu-central-1
AWS_S3_BUCKET_NAME = xbr.foundation

XBR_DEBUG_TOKEN_ADDR="0xcfeb869f69431e42cdb54a4f4f105c19c080a601"
XBR_DEBUG_NETWORK_ADDR="0x254dffcd3277c0b1660f6d42efbb754edababc2b"


default:
	@echo 'Targets: clean compile test deploy'


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
	pip install -r requirements-dev.txt
	npm install
	npm outdated
	@echo "run 'ncu -u' to update deps .."
	$(TRUFFLE) version

update_dependencies:
	npm i -g npm-check-updates
	ncu -u
	npm install

lint:
	$(SOLHINT) "contracts/**/*.sol"

test:
	$(TRUFFLE) test --network ganache

coverage:
	solidity-coverage

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
run_ganache:
	docker-compose up --force-recreate ganache

clean_ganache:
	-docker rm xbr-protocol_ganache_1
	-rm -rf ./teststack/ganache/.data
	mkdir -p ./teststack/ganache/.data


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
#   => https://s3.eu-central-1.amazonaws.com/xbr.foundation/docs/index.html
#   => https://xbr.network/docs/index.html
publish_docs:
	aws s3 cp --recursive --acl public-read \
		./docs/_build s3://$(AWS_S3_BUCKET_NAME)/docs

clean_docs:
	-rm -rf docs/_build
