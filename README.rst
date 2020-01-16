The XBR Protocol
================

|Docs (on CDN)| |Docs (on S3)| |Travis| |Coverage|

This repository contains the XBR smart contracts, with Ethereum as
target blockchain, and Solidity as implementation language for the **XBR
Protocol**.

Please see the `documentation <https://s3.eu-central-1.amazonaws.com/xbr.foundation/docs/network/index.html>`__
for more information.

.. note::

    * `The XBR Protocol documentation <https://s3.eu-central-1.amazonaws.com/xbr.foundation/docs/protocol/index.html>`__) (THIS)
    * `The XBR Network documentation <https://s3.eu-central-1.amazonaws.com/xbr.foundation/docs/network/index.html>`__)


XBR Client Libraries
--------------------

The XBR Protocol - at its core - is made of the XBR smart contracts, and
the primary artifacts built are the contract ABI files (in
``./build/contracts/*.json``).

Technically, these files are all you need to interact and talk to the
XBR smart contracts.

However, doing it that way (using the raw ABI files and presumably some
generic Ethereum library) is cumbersome and error prone to maintain.

Therefore, we create wrapper libraries for XBR, currently for Python and
JavaScript, that make interaction with XBR contract super easy.

The libraries are available here:

-  `XBR client library for Python <https://github.com/crossbario/autobahn-python>`__
-  `XBR client library for JavaScript (Browser and Node) <https://github.com/crossbario/autobahn-js>`__

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
