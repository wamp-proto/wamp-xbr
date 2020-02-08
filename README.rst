The XBR Protocol
================

|Docs (on CDN)| |Docs (on S3)| |Travis| |Coverage|

The **XBR Protocol** enables peer-to-peer data trading and data service microtransactions in
[Open Data Markets](https://xbr.network/).

The protocol sits on top of messaging middleware and service mesh technologies, enabling
secure integration, trusted sharing and monetization of data and data-driven microservices
between different parties and users.

The XBR Protocol specification is implemented in *smart contracts*, which are written in Solidity,
open-source MIT licensed and running on the Ethereum blockchain. All source code for the XBR smart contracts
in contained and developed in this Git repository.


XBR Client Libraries
--------------------

The XBR smart contracts primary build artifacts are the contract ABIs JSON files in [abi/contracts](abi/contracts).

Technically, these files are all you need to interact and talk to the XBR smart contracts from
any (client side) language or run-time that supports Ethereum, such as
`web3.js <https://web3js.readthedocs.io>`__ or `web3.py <https://web3py.readthedocs.io>`__.

However, doing it that way (using the raw ABI files and presumably some generic Ethereum library) is cumbersome
and error prone to maintain. An alternative is using a client library with XBR support.

The XBR project currently maintains the following **XBR-enabled client libraries**:

-  `Autobahn|Python <https://github.com/crossbario/autobahn-python>`__ for Python 3.5+
-  `Autobahn|JavaScript <https://github.com/crossbario/autobahn-js>`__ for JavaScript, in browser and NodeJS
-  `Autobahn|Java <https://github.com/crossbario/autobahn-java>`__ (*beta XBR support*) for Java on Android and Java 8 / Netty

XBR support can be added to any `WAMP client library <https://wamp-proto.org/implementations.html#libraries>`__
with a language run-time that has packages for Ethereum application development.


Ganache development blockchain
------------------------------

For development of XBR Protocol compliant software components, such as Crossbar.io FX, community projects
or third party systems, we provide a Docker image that contains a locally running Ganache blockchain
that has all XBR smart contracts already installed, and test accounts with some ETH and XBR (tokens) filled up.

Using the CrossbarFX Blockchain image
.....................................

For further information, please see `CrossbarFX Blockchain on Dockerhub <https://hub.docker.com/r/crossbario/crossbarfx-blockchain>`__.


Building the CrossbarFX Blockchain image
........................................

The CrossbarFX Blockchain Docker image is published to DockerHub, and the administration of the respective
area can be done `here <https://hub.docker.com/repository/docker/crossbario/crossbarfx-blockchain>`__.

To **build and publish the CrossbarFX Blockchain image**, run the following commands in a Python virtualenv.

**(1)** Clean file staging area and scratch all blockchain data before rebuilding:

.. code-block:: console

    make clean_ganache

**(2)** Run an empty blockchain from the (empty) staging area (and keep this container running):

.. code-block:: console

    make run_ganache

**(3)** Compile and deploy the XBR smart contract to the blockchain (from a second terminal):

.. code-block:: console

    make deploy_ganache

**(4)** Top-up test accounts with ETH and XBR token:

.. code-block:: console

    make init_ganache

**Now stop the blockchain started above before continuing.**

**(5)** Build the Docker image using the blockchain data from the staging area:

.. code-block:: console

    source ./.versions.sh
    make build_ganache_docker

**(6)** To publish the Docker image to DockerHub, run:

.. code-block:: console

    make publish_ganache_docker

-------

**Testing**

To run a container from the built image locally:

.. code-block:: console

    make run_ganache_docker

Show balances of ETH and XBR on test accounts (on either a host- or Docker-based running blockchain):

.. code-block:: console

    make check_ganache



Testing
-------

To test, open a first shell and run:

.. code-block:: console

    make run_ganache

Open a second shell and run:

.. code-block:: console

    tox

This should run all CI steps locally, eg here is sample output:

.. code-block:: console

    truffle-build: commands succeeded
    truffle-test: commands succeeded
    solhint: commands succeeded
    coverage: commands succeeded
    sphinx: commands succeeded
    xbr-js: commands succeeded
    congratulations :)


Please see the `documentation <https://s3.eu-central-1.amazonaws.com/xbr.foundation/docs/network/index.html>`__
for more information.

.. note::

    * `The XBR Protocol documentation <https://s3.eu-central-1.amazonaws.com/xbr.foundation/docs/protocol/index.html>`__) (THIS)
    * `The XBR Network documentation <https://s3.eu-central-1.amazonaws.com/xbr.foundation/docs/network/index.html>`__)


--------------

Copyright Crossbar.io Technologies GmbH. Licensed under the `Apache 2.0
license <https://www.apache.org/licenses/LICENSE-2.0>`__.

.. |Docs (on CDN)| image:: https://img.shields.io/badge/docs-cdn-brightgreen.svg?style=flat
   :target: https://xbr.network/docs/network/index.html
.. |Docs (on S3)| image:: https://img.shields.io/badge/docs-s3-brightgreen.svg?style=flat
   :target: https://s3.eu-central-1.amazonaws.com/xbr.foundation/docs/network/index.html
.. |Travis| image:: https://travis-ci.org/crossbario/xbr-protocol.svg?branch=master
   :target: https://travis-ci.org/crossbario/xbr-protocol
.. |Coverage| image:: https://img.shields.io/codecov/c/github/crossbario/xbr-protocol/master.svg
   :target: https://codecov.io/github/crossbario/xbr-protocol
