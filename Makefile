.PHONY: crossbar coverage docs clean build test

CROSSBAR = crossbarfx edge

#BROWSERIFY = ./node_modules/browserify/bin/cmd.js
BROWSERIFY = browserify

SCOUR = scour
SCOUR_FLAGS = --remove-descriptive-elements --enable-comment-stripping --enable-viewboxing --indent=none --no-line-breaks --shorten-ids

GCLOSURE = ./node_modules/google-closure-compiler/cli.js

#XBR_DEBUG_TOKEN_ADDR = 0x67b5656d60a809915323bf2c40a8bef15a152e3e
#XBR_DEBUG_NETWORK_ADDR = 0x2612af3a521c2df9eaf28422ca335b04adf3ac66

AWS_DEFAULT_REGION = eu-central-1
AWS_S3_BUCKET_NAME = xbr.foundation


default:
	@echo 'Targets: clean compile test'

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

distclean: clean_docs clean
	-rm -rf ./node_modules/
	-rm -f ./package-lock.json

# cd $HOME
# wget https://nodejs.org/dist/v10.15.3/node-v10.15.3-linux-x64.tar.xz
# export PATH=${HOME}/node-v10.15.3-linux-x64/bin:${PATH}

requirements:
	sudo apt install -y nodejs nodejs-dev npm

npm:
	npm install google-closure-compiler
	npm install node-buffer
	npm install browserify
	npm install coveralls
	npm install nodeunit

	npm install ganache-cli@v6.4.1
	sudo rm -f /usr/local/bin/ganache-cli
	sudo ln -s ${PWD}/node_modules/ganache-cli/cli.js /usr/local/bin/ganache-cli

	npm install truffle@v5.0.9
	sudo rm -f /usr/local/bin/truffle
	sudo ln -s ${PWD}/node_modules/truffle/build/cli.bundled.js /usr/local/bin/truffle

	npm install solhint@v2.0.0
	sudo rm -f /usr/local/bin/solhint
	sudo ln -s ${PWD}/node_modules/solhint/solhint.js /usr/local/bin/solhint

	npm install solidity-coverage@v0.5.11
	sudo rm -f /usr/local/bin/solidity-coverage
	sudo ln -s ${PWD}/node_modules/solidity-coverage/bin/exec.js /usr/local/bin/solidity-coverage

update_deps:
	npm i -g npm-check-updates
	ncu -u
	npm install

install_remixide:
	npm install remix-ide
	sudo rm -f /usr/local/bin/remix-ide
	sudo ln -s ${PWD}/node_modules/remix-ide/bin/remix-ide /usr/local/bin/remix-ide

npm_global:
	sudo npm install -g google-closure-compiler
	sudo npm install -g node-buffer
	sudo npm install -g browserify
	sudo npm install -g coveralls
	sudo npm install -g nodeunit
	# https://github.com/trufflesuite/ganache-cli/issues/593
	sudo npm install -g ganache-cli@v6.2.4
	sudo npm install -g truffle@v5.0.3
	sudo npm install -g solhint@v1.5.1
	sudo npm install -g solidity-coverage@v0.5.1
	sudo npm install -g remix-ide
	sudo npm install -g npm-check-updates

install:
	npm install
	npm outdated
	@echo "run 'ncu -u' to update deps .."
	# pip install -r requirements-dev.txt
	# pip install -e .

web3:
	# https://github.com/ethereum/web3.js/issues/1041#issuecomment-335434041
	npm install ethereum/web3.js
	cp node_modules/web3/dist/web3.min.js teststack/crossbar/web/

build: compile docs build_js build_python

publish: publish_docs publish_js publish_python


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
lint:
	solhint "contracts/**/*.sol"

compile:
	-rm ./abi/*.json
	-rm ./build/contracts/*.json
	truffle compile --all
	cp build/contracts/*.json ./abi/
	find ./abi
	-rm ../../crossbario/autobahn-python/autobahn/xbr/contracts/*.json
	cp -r abi/*.json ../../crossbario/autobahn-python/autobahn/xbr/contracts/
	-rm ../../crossbario/autobahn-js/packages/autobahn-xbr/lib/contracts/*.json
	cp -r abi/*.json ../../crossbario/autobahn-js/packages/autobahn-xbr/lib/contracts/

test:
	truffle test --network ganache

coverage:
	solidity-coverage

deploy:
	truffle compile --all
	#truffle migrate --reset --network ganache
	truffle migrate --reset --network geth

browserify:
	$(BROWSERIFY) ./index.js --ignore-missing --standalone xbr -o ./build/xbr.js

build_js: browserify
	google-closure-compiler -W QUIET --js ./build/xbr.js --js_output_file ./build/xbr.min.js
	gzip -c -k -9 ./build/xbr.min.js > build/xbr.min.jgz

publish_js: build_js
	aws s3 cp --acl public-read ./build/xbr.js      s3://$(AWS_S3_BUCKET_NAME)/lib/js/
	aws s3 cp --acl public-read ./build/xbr.min.js  s3://$(AWS_S3_BUCKET_NAME)/lib/js/
	aws s3 cp --acl public-read ./build/xbr.min.jgz s3://$(AWS_S3_BUCKET_NAME)/lib/js/

build_npm:
	@echo "XBR Lib for NodeJS does not require a build step"

publish_npm:
	npm publish --access public

publish_ipfs_eula:
	cd ipfs && zip -r - xbr-eula | ipfs add

publish_ipfs_members:
	cd ipfs/members && ipfs add *.rdf


build_python: compile
	python setup.py sdist bdist_wheel --universal
	ls -la ./dist

install_python:
	pip install -e .

test_python:
	XBR_DEBUG_TOKEN_ADDR=$(XBR_DEBUG_TOKEN_ADDR) \
	XBR_DEBUG_NETWORK_ADDR=$(XBR_DEBUG_NETWORK_ADDR) \
		python teststack/test_client1.py

	XBR_DEBUG_TOKEN_ADDR=$(XBR_DEBUG_TOKEN_ADDR) \
	XBR_DEBUG_NETWORK_ADDR=$(XBR_DEBUG_NETWORK_ADDR) \
		python teststack/test_client2.py


clean_python:
	-rm -rf ./dist/
	-rm -rf ./xbr.egg-info/

publish_python:	build_python
	twine upload dist/*
	# aws s3 cp --recursive --acl public-read ./dist s3://$(AWS_S3_BUCKET_NAME)/lib/python/xbr/


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

build_images: $(BUILDDIR)_exists $(BUILDDIR)/$(OBJECTS)

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
	cd docs && sphinx-build -nWT -b spelling -d ./_build/doctrees . ./_build/spelling

run_docs: docs
	twistd --nodaemon web --path=docs/_build --listen=tcp:8090

# build and deploy latest docs:
#   => https://s3.eu-central-1.amazonaws.com/xbr.foundation/docs/index.html
#   => https://xbr.network/docs/index.html
publish_docs:
	aws s3 cp --recursive --acl public-read ./docs/_build s3://$(AWS_S3_BUCKET_NAME)/docs

clean_docs:
	-rm -rf docs/_build


#
# Ganache test blockchain
#
run_ganache:
	ganache

run_ganache_cli:
	docker-compose up --force-recreate ganache

clean_ganache_cli:
	-rm -rf ./teststack/ganache/.data
	mkdir -p ./teststack/ganache/.data


#
# Remix (and remixd as part (!) of RemixIDE when it is installed)
#
#run_remix:
#	remix-ide

#
# Remixd, then open https://remix.ethereum.org/
#
run_remixd:
	remixd -s . --remix-ide https://remix.ethereum.org


#
# CrossbarFX
#
run_crossbar:
	$(CROSSBAR) start \
		--cbdir=${PWD}/teststack/crossbar/.crossbar \
		--loglevel=info

run_crossbar_version:
	$(CROSSBAR) version

run_crossbar_docker:
	docker pull crossbario/crossbarfx:latest
	docker-compose up --force-recreate crossbar

clean_db:
	-rm -rf ${PWD}/teststack/crossbar/.xbrdb
	-rm -rf ${PWD}/teststack/crossbar/.xbrdb-transactions
	# rm -f ${PWD}/teststack/crossbar/.testdb/*
	# rm -f ./teststack/crossbar/.crossbar/key.*

check_db:
	du -hs teststack/crossbar/.testdb/
	ls -la teststack/crossbar/.testdb/


#
# Juypter
#
run_jupyter:
	docker-compose up --force-recreate jupyter

run_jupyter_host:
	jupyter notebook \
		--config=${PWD}/teststack/jupyter/.jupyter/jupyter_notebook_config.py \
		--notebook-dir=${PWD}/teststack/jupyter/notebooks


run_test_xbr:
	python teststack/test_connect.py
	python teststack/test_transfer_tokens.py
	python teststack/test_connect.py
	python teststack/test_register.py
	python teststack/test_market.py
	python teststack/test_connect.py
	python teststack/test_payment_channel.py
	python teststack/test_connect.py


run_webserver:
	twistd --nodaemon web --listen tcp:8080 --path teststack/crossbar/web
