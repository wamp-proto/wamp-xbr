.. _XBRAPI:

XBR Contracts Reference
=======================

This is the public API reference documentation for the XBR protocol smart contracts:

.. contents:: :local:

.. note::
    The contracts are written in Solidity, and the documentation here is generated directly from
    the docstrings in the Solidity source code using `Sphinx <http://www.sphinx-doc.org>`__
    and `Solidity domain for Sphinx <https://solidity-domain-for-sphinx.readthedocs.io>`__.

----------


XBRNetwork
----------

.. autosolcontract:: XBRNetwork
    :members:
    :exclude-members:
        constructor
        _registerMember


XBRMarket
---------

.. autosolcontract:: XBRMarket
    :members:
    :exclude-members:
        constructor,
        marketSeq,
        marketIds,
        marketsByMaker,
        marketsByOwner,
        _createMarket,
        _joinMarket


XBRCatalog
----------

.. autosolcontract:: XBRCatalog
    :members:


XBRChannel
----------

.. autosolcontract:: XBRChannel
    :members:


XBRTypes
--------

.. autosollibrary:: XBRTypes
    :members:


XBRToken
--------

.. autosolcontract:: XBRToken
    :members:
    :exclude-members:
        INITIAL_SUPPLY,
        constructor


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

