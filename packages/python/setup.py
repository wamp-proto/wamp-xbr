# Copyright (c) Crossbar.io Technologies GmbH. Licensed under the Apache 2.0 license.

from setuptools import setup

# read version string
with open('xbr/_version.py') as f:
    exec(f.read())  # defines __version__

# read package long description
with open('README.rst') as f:
    docstr = f.read()

setup(
    name='xbr',
    version=__version__,
    description='XBR protocol ABI files package',
    long_description=docstr,
    license='MIT License',
    author='Crossbar.io Technologies GmbH',
    url='https://github.com/crossbario/xbr-protocol',
    platforms='Any',
    install_requires=[],
    packages=[
        'xbr',
    ],
    package_data={
        'xbr': ['./xbr/abi/*.json'],
    },

    # this flag will make files from MANIFEST.in go into _source_ distributions only
    include_package_data=True,
    zip_safe=True,

    # http://pypi.python.org/pypi?%3Aaction=list_classifiers
    classifiers=["License :: OSI Approved :: Apache Software License",
                 "Development Status :: 4 - Beta",
                 "Environment :: No Input/Output (Daemon)",
                 "Intended Audience :: Developers",
                 "Operating System :: OS Independent",
                 "Programming Language :: Python",
                 "Topic :: Internet",
                 "Topic :: Internet :: WWW/HTTP",
                 "Topic :: Communications",
                 "Topic :: System :: Distributed Computing",
                 "Topic :: Software Development :: Libraries",
                 "Topic :: Software Development :: Libraries :: Python Modules",
                 "Topic :: Software Development :: Object Brokering"],
    keywords='xbr wamp data-markets blockchain ethereum autobahn crossbar'
)
