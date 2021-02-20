# Copyright (c) Crossbar.io Technologies GmbH. Licensed under Apache 2.0.

from setuptools import setup

with open('xbr/_version.py') as f:
    exec(f.read())  # defines __version__

with open('README.rst') as f:
    docstr = f.read()

setup(
    name='xbr',
    version=__version__,
    description='XBR smart contracts and ABIs',
    long_description=docstr,
    license='Apache 2.0 License',
    author='Crossbar.io Technologies GmbH',
    author_email='autobahnws@googlegroups.com',
    url='https://github.com/crossbario/xbr-protocol',
    platforms=('Any'),
    python_requires='>=3.7',
    packages=['xbr'],

    # this flag will make files from MANIFEST.in go into _source_ distributions only
    include_package_data=True,

    # in addition, the following will make the specified files go into
    # source _and_ bdist distributions! For the LICENSE file
    # specifically, see setup.cfg
    # data_files=[('.', ['list', 'of', 'files'])],

    # this package does not access its own source code or data files
    # as normal operating system files
    zip_safe=True,

    # http://pypi.python.org/pypi?%3Aaction=list_classifiers
    classifiers=[
        "License :: OSI Approved :: Apache Software License",
        "Development Status :: 4 - Beta",
        "Environment :: Console",
        "Intended Audience :: Developers",
        "Operating System :: OS Independent",
        "Programming Language :: Python",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.7",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: Implementation :: CPython",
        "Programming Language :: Python :: Implementation :: PyPy",
        "Topic :: Software Development :: Libraries",
        "Topic :: Software Development :: Libraries :: Application Frameworks",
    ],
    keywords='autobahn crossbar wamp xbr ethereum abi',
)
