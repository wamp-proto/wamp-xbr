Quickstart
==========

This section outlines some basic action for testing and development on the XBR smart contracts themself (not
applications using XBR).

Local development
.................

To install development tools and the XBR smart contract development environment on the host, run:

.. code-block:: console

    make install

To compile the XBR smart contract in the development environment on the host, run:

.. code-block:: console

    make install

To compile and deploy the XBR smart contracts to the locally running blockchain, run:

.. code-block:: console

    make deploy

To compile and deploy the XBR smart contracts to a public Ethereum network, run one of the following:

.. code-block:: console

    make deploy_rinkeby
    make deploy_rinkeby_dryrun
    make deploy_ropsten
    make deploy_ropsten_dryrun

Full CI test run
................

To test XBR smart contracts, open a first shell and run:

.. code-block:: console

    make run_ganache_docker

Open a second shell and run:

.. code-block:: console

    tox

This should run all test and CI steps locally, eg here is sample summary output for a successful run:

.. code-block:: console

    truffle-build: commands succeeded
    truffle-test: commands succeeded
    solhint: commands succeeded
    coverage: commands succeeded
    sphinx: commands succeeded
    xbr-js: commands succeeded
    congratulations :)

Building the documentation
..........................

For a complete rebuild with all steps:

.. code-block:: console

    make clean_docs images docs run_docs

The individual steps are described in the following.

To optimize image files for the web and build the documentation on the host:

.. code-block:: console

    make images
    make clean_docs
    make docs

To run a local Web server from the built docs:

.. code-block:: console

    make run_docs

and open `http://localhost:8090/ <http://localhost:8090/>`__.

To spellcheck the docs and code docstrings:

.. code-block:: console

    make spellcheck_docs

To publish the docs to AWS S3:

.. code-block:: console

    make publish_docs

.. note::

    The docs cached on AWS Cloudfront are automatically updated (after some time lag).


Development Blockchain
......................

For development of XBR Protocol compliant software components, such as Crossbar.io FX, community projects
or third party systems, we provide a Docker image that contains a locally running Ganache blockchain
that has all XBR smart contracts already installed, and test accounts with some ETH and XBR (tokens) filled up.

Using the development blockchain
................................

For further information, please see `CrossbarFX Blockchain on Dockerhub <https://hub.docker.com/r/crossbario/crossbarfx-blockchain>`__.


Building the development blockchain image
.........................................

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

To run a Docker container locally from the built blockchain development image:

.. code-block:: console

    make run_ganache_docker

Show balances of ETH and XBR on test accounts (on either a host- or Docker-based running blockchain):

.. code-block:: console

    make check_ganache

