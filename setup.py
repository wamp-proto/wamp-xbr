from __future__ import absolute_import
from setuptools import setup

# read version string
__version__ = None
with open('xbr/_version.py') as f:
    exec(f.read())  # defines __version__

# read package long description
with open('README.md') as f:
    docstr = f.read()

setup(
    name='xbr',
    version=__version__,
    description='The XBR Protocol - blockchain protocol for decentralized open data markets',
    long_description=docstr,
    license='Apache 2.0 License',
    author='Crossbar.io Technologies GmbH',
    author_email='support@crossbario.com',
    url='https://xbr.network',
    platforms='Any',
    install_requires=[
        'web3>=4.8.1',      # MIT license
    ],
    extras_require={},
    packages=[
        'xbr',
    ],
    package_data={'xbr': ['./xbr/contracts/*.json']},

    # this flag will make files from MANIFEST.in go into _source_ distributions only
    include_package_data=True,
    zip_safe=False,

    # http://pypi.python.org/pypi?%3Aaction=list_classifiers
    classifiers=["License :: OSI Approved :: MIT License",
                 "Development Status :: 5 - Production/Stable",
                 "Environment :: No Input/Output (Daemon)",
                 "Framework :: Twisted",
                 "Intended Audience :: Developers",
                 "Operating System :: OS Independent",
                 "Programming Language :: Python",
                 "Programming Language :: Python :: 2",
                 "Programming Language :: Python :: 2.7",
                 "Programming Language :: Python :: 3",
                 "Programming Language :: Python :: 3.4",
                 "Programming Language :: Python :: 3.5",
                 "Programming Language :: Python :: 3.6",
                 "Programming Language :: Python :: 3.7",
                 "Programming Language :: Python :: Implementation :: CPython",
                 "Programming Language :: Python :: Implementation :: PyPy",
                 "Programming Language :: Python :: Implementation :: Jython",
                 "Topic :: Internet",
                 "Topic :: Internet :: WWW/HTTP",
                 "Topic :: Communications",
                 "Topic :: System :: Distributed Computing",
                 "Topic :: Software Development :: Libraries",
                 "Topic :: Software Development :: Libraries :: Python Modules",
                 "Topic :: Software Development :: Object Brokering"],
    keywords='autobahn crossbar websocket realtime rfc6455 wamp rpc pubsub twisted asyncio'
)
