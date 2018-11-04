.PHONY: crossbar docs clean build

CROSSBAR=crossbarfx edge

default:
	@echo 'Targets: clean compile test'

clean: clean_docs
	-rm -rf ./build


requirements:
	pip install -r requirements.txt
	npm install


build:
	truffle compile

deploy:
	truffle compile --all
	truffle migrate --reset


docs:
	cd docs && sphinx-build -b html . _build

clean_docs:
	-rm -rf docs/_build

run_docs: docs
	twistd --nodaemon web --path=docs/_build --listen=tcp:8090


run_ganache:
	docker-compose up ganache

clean_ganache:
	-sudo rm -rf ./ganache/.data/*


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
