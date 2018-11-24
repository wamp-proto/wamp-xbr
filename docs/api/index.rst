.. _XBRAPI:

API Reference
=============

This is the XBR smart contracts API reference documentation, generated from the Solidity source code
using `Sphinx <http://www.sphinx-doc.org>`_ and `Solidity domain for Sphinx <https://solidity-domain-for-sphinx.readthedocs.io>`_.

.. contents:: :local:

----------

XBR Token
---------

.. autosolcontract:: XBRToken
    :members:
        INITIAL_SUPPLY,
        constructor


XBR Network
-----------

.. autosolcontract:: XBRNetwork
    :members:
    :exclude-members:
        marketSeq
        domainSeq
        members
        domains
        nodes
        nodesByKey
        markets
        marketsByMaker


XBR Payment Channel
-------------------

.. autosolcontract:: XBRPaymentChannel
    :members:


XBR Maintained
--------------

.. autosolcontract:: XBRMaintained
    :members:
        MaintainerAdded,
        MaintainerRemoved,
        onlyMaintainer,
        isMaintainer,
        addMaintainer,
        renounceMaintainer
