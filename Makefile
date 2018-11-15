.PHONY: crossbar docs clean build test

CROSSBAR = crossbarfx edge

#BROWSERIFY = ./node_modules/browserify/bin/cmd.js
BROWSERIFY = browserify

SCOUR = scour
SCOUR_FLAGS = --remove-descriptive-elements --enable-comment-stripping --enable-viewboxing --indent=none --no-line-breaks --shorten-ids

GCLOSURE = ./node_modules/google-closure-compiler/cli.js


default:
	@echo 'Targets: clean compile test'

clean: clean_docs
	-rm -rf ./build/
	-rm -rf ./.tox/


install:
	pip install -r requirements.txt
	npm install


#
# XBR Protocol smart contracts
#
lint:
	solhint "contracts/**/*.sol"

compile:
	truffle compile --all

test:
	truffle test --network ganache

deploy:
	truffle compile --all
	truffle migrate --reset --network ganache

browserify:
	$(BROWSERIFY) ./index.js --ignore-missing --standalone xbr -o ./build/xbr.js

build: compile browserify
	./node_modules/google-closure-compiler/cli.js -W QUIET --js ./build/xbr.js --js_output_file ./build/xbr.min.js
	gzip -c -k -9 build/xbr.min.js > build/xbr.min.jgz

publish:
	aws s3 cp --recursive --acl public-read ./build s3://xbr.foundation/lib


publish_ipfs_eula:
	cd ipfs && zip -r - xbr-eula | ipfs add

publish_ipfs_members:
	cd ipfs/members && ipfs add *.rdf


build_python:
	python setup.py sdist bdist_wheel --universal

# publish to PyPI
publish_python:	build_python
	twine upload dist/*


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
	-rm -rf ./teststack/ganache/.data
	mkdir -p ./teststack/ganache/.data


#
# Remix (and remixd as part (!) of RemixIDE when it is installed)
#
run_remix:
	remix-ide


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
