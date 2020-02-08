Project Development
===================

.. contents:: :local:

.. note::

    This is documentation addressing XBR project developers, not XBR application developers.
    For XBR application developer documentation, please see the other sections of this documentation.

We build on the following toolset:

* `Ganache <https://truffleframework.com/ganache>`_, the personal blockchain
* `MetaMask <https://metamask.io/>`_, the dApps Ethereum bridge
* `Truffle <https://truffleframework.com/>`_, the Ethereum development framework
* `Remix IDE <https://remix.ethereum.org/>`_, the browser based Ethereum IDE


.. toctree::
    :maxdepth: 1
    :caption: Contents:

    quickstart
    setup
    ganache
    metamask
    truffle
    remixide
    ipfs
    bip39


Build, Test and Deploy
----------------------

To syntax-check and lint the Solidity sources:

.. code-block:: console

    make lint

To build the XBR smart contracts and ABI files (``./build/contracts/*.json``) from the Solidity sources:

.. code-block:: console

    make compile

To run the unit tests on the XBR smart contracts (against the configured local ``ganache`` test blockchain):

.. code-block:: console

    make test

To compile and deploy the XBR smart contracts (to the configured local ``ganache`` test blockchain):

.. code-block:: console

    make deploy

To build the XBR client libraries for JavaScript and Python:

.. code-block:: console

    make build

To publish the XBR client libraries to:

* `XBR Client library for JavaScript <https://xbr.network/lib/xbr.min.js>`_
* `XBR Client library for Python <https://pypi.org/project/xbr/>`_



Writing documentation
---------------------

The XBR protocol is documented primarily directly
within source code using the
`Natspec (Ethereum Natural Specification Format) <https://github.com/ethereum/wiki/wiki/Ethereum-Natural-Specification-Format>`_
and `Sphinx <http://www.sphinx-doc.org/>`_ is used to generate static HTML
from the Solidity source code files.

The following sphinx Xref roles are available with the Solidity domain:

* ``sol:contract``
* ``sol:lib``
* ``sol:interface``
* ``sol:svar``
* ``sol:cons``
* ``sol:func``
* ``sol:mod``
* ``sol:event``
* ``sol:struct``
* ``sol:enum``

So referencing a Solidity contract, function or event works like this in Sphinx:

.. code-block:: rst

    :sol:contract:`XBRToken`

    :sol:func:`XBRNetwork.open_market`

    :sol:event:`XBRPaymentChannel.Closing`

Code Style
----------

visibility levels (public, private, external, internal)
https://github.com/melonproject/oyente

https://medium.com/@ProtoFire_io/solhint-an-advanced-linter-for-ethereums-solidity-c6b155aced7b
https://protofire.github.io/solhint/
https://github.com/protofire/solhint


// solhint-disable-line


Transactions and Calls
----------------------

With non-constant function vote, you can only get the transaction hash back immediately because the transaction may never get mined. Or it could take several blocks as indicated by "Waiting for transaction to be mined..."

Return values can be used by other contracts, but ``Web3.js`` can only use events.

the return value could be helpful so that other contracts

https://ethereum.stackexchange.com/a/770
https://ethereum.stackexchange.com/a/3293
https://ethereum.stackexchange.com/q/765/42
https://github.com/ethereum/wiki/wiki/JavaScript-API#contract-events
