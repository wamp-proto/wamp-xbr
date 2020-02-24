.PHONY: build

default:
	@echo "Targets:"
	@echo ""
	@echo "   clean       Clean build artifacts"
	@echo "   build       Build package"
	@echo "   publish     Publish package"
	@echo ""

clean:
	-rm -rf ./build
	-rm -rf ./dist
	-rm -rf ./xbr.egg-info

build:
	python setup.py sdist bdist_wheel --universal
	ls -la ./dist

publish: clean build
	twine upload dist/*
