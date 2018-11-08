.PHONY: crossbar docs clean build

CROSSBAR=crossbarfx edge

default:
	@echo 'Targets: clean compile test'

clean: clean_docs
	-rm -rf ./build


install:
	pip install -r requirements.txt
	npm install


#
# XBR Protocol smart contracts
#
build:
	truffle compile

deploy:
	truffle compile --all
	truffle migrate --reset


#
# XBR Protocol documentation
#
docs:
	# cd docs && sphinx-build -nWT -b dummy . _build
	cd docs && sphinx-build -b html . _build

clean_docs:
	-rm -rf docs/_build

run_docs: docs
	twistd --nodaemon web --path=docs/_build --listen=tcp:8090

spellcheck_docs:
	sphinx-build -b spelling -d docs/_build/doctrees docs docs/_build/spelling

# build and deploy latest docs:
#   => https://s3.eu-central-1.amazonaws.com/xbr.foundation/docs/index.html
#   => https://xbr.network/docs/index.html
publish_docs:
	aws s3 cp --recursive --acl public-read docs/_build s3://xbr.foundation/docs


#
# Ganache test blockchain
#
run_ganache:
	docker-compose up ganache

clean_ganache:
	-sudo rm -rf ./ganache/.data/*


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
