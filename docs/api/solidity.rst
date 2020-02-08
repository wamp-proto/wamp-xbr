Solidity API
============

This is the XBR smart contracts API reference documentation, generated from the Solidity source code
using `Sphinx <http://www.sphinx-doc.org>`__ and `Solidity domain for Sphinx <https://solidity-domain-for-sphinx.readthedocs.io>`__.

.. contents:: :local:

----------


XBRToken
--------

.. autosolcontract:: XBRToken
    :members:
        INITIAL_SUPPLY,
        constructor


XBRNetwork
----------

.. autosolcontract:: XBRNetwork
    :members:
    :exclude-members:
        marketSeq,
        domainSeq,
        members,
        domains,
        nodes,
        nodesByKey,
        markets,
        marketsByMaker


XBRChannel
-----------------

.. autosolcontract:: XBRChannel
    :members:


XBRMaintained
-------------

.. autosolcontract:: XBRMaintained
    :members:
        MaintainerAdded,
        MaintainerRemoved,
        onlyMaintainer,
        isMaintainer,
        addMaintainer,
        renounceMaintainer

