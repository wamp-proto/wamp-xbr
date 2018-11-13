.PHONY: crossbar docs clean build test

CROSSBAR=crossbarfx edge

default:
	@echo 'Targets: clean compile test'

clean: clean_docs
	-rm -rf ./build/
	-rm -rf ./.tox/


install:
	pip install -r requirements.txt
	npm install


#BROWSERIFY=./node_modules/browserify/bin/cmd.js
BROWSERIFY=browserify

#
# XBR Protocol smart contracts
#
build:
	truffle compile
	cp ./build/contracts/*.json ./teststack/crossbar/web/xbr/

lint:
	solhint "contracts/**/*.sol"

deploy:
	truffle compile --all
	truffle migrate --reset --network ganache
	cp ./build/contracts/*.json ./teststack/crossbar/web/xbr/

test:
	truffle test --network ganache

build_browser:
	$(BROWSERIFY) ./index.js --ignore-missing --standalone xbr -o ./build/xbr.js
	#$(BROWSERIFY) ./standalone.js --ignore-missing --standalone xbr -o ./build/xbr.js
	ls -la ./build/xbr.js



#
# build optimized SVG files from source SVGs
#
BUILDDIR = docs/_static/gen
SCOUR = scour
SCOUR_FLAGS = --remove-descriptive-elements --enable-comment-stripping --enable-viewboxing --indent=none --no-line-breaks --shorten-ids

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
	cd docs && sphinx-build -b spelling -d ./_build/doctrees . ./_build/spelling

run_docs: docs
	twistd --nodaemon web --path=docs/_build --listen=tcp:8090

# build and deploy latest docs:
#   => https://s3.eu-central-1.amazonaws.com/xbr.foundation/docs/index.html
#   => https://xbr.network/docs/index.html
publish_docs:
	aws s3 cp --recursive --acl public-read docs/_build s3://xbr.foundation/docs

clean_docs:
	-rm -rf docs/_build


#
# Ganache test blockchain
#
run_ganache:
	ganache

run_ganache_cli:
	docker-compose up ganache

clean_ganache_cli:
	-sudo rm -rf ./ganache/.data/*


#
# Remix (and remixd)
#
run_remix:
	remix-ide

run_remixd:
	#remixd -s ${PWD}/contracts --remix-ide http://127.0.0.1:8080
	#remixd -s ${PWD}/contracts --rpc --rpc-port 8545
	#remixd -s ./contracts --remix-ide http://127.0.0.1:8080/#optimize=true&version=soljson-v0.4.25+commit.59dbf8f1.js
	remixd -s ./contracts --remix-ide http://127.0.0.1:8080/
	#remixd -s ./contracts


#
# CrossbarFX
#
run_crossbar:
	$(CROSSBAR) start \
		--cbdir=${PWD}/teststack/crossbar/.crossbar \
		--loglevel=info

clean_db:
	rm -f ${PWD}/teststack/crossbar/.testdb/*
	# rm -f ./teststack/crossbar/.crossbar/key.*

check_db:
	du -hs teststack/crossbar/.testdb/
	ls -la teststack/crossbar/.testdb/
