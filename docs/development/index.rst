Project Development
===================

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

    ganache
    metamask
    truffle
    remixide

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
