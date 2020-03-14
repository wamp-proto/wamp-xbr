.. _XBRAPI:

Contracts Reference
===================

This is the public API reference documentation for the XBR protocol smart contracts:

.. contents:: :local:

.. note::
    The contracts are written in Solidity, and the documentation here is generated directly from
    the docstrings in the `XBR contracts <https://github.com/crossbario/xbr-protocol/tree/master/contracts>`__
    source code using `Sphinx <http://www.sphinx-doc.org>`__ and
    `Solidity domain for Sphinx <https://solidity-domain-for-sphinx.readthedocs.io>`__.

----------

XBRNetwork
----------

.. autosolcontract:: XBRNetwork
    :members:
        MemberRegistered,
        MemberRetired,
        verifyingChain,
        verifyingContract,
        eula,
        token,
        organization,
        members,
        coins

registerMember
..............

.. autosolfunction:: XBRNetwork.registerMember

registerMemberFor
.................

.. autosolfunction:: XBRNetwork.registerMemberFor


XBRMarket
---------

.. autosolcontract:: XBRMarket
    :members:
        network,
        markets,
        marketIds,
        MarketCreated,
        MarketClosed,
        ActorJoined,
        ActorLeft,
        ConsentSet

createMarket
............

.. autosolfunction:: XBRMarket.createMarket

createMarketFor
...............

.. autosolfunction:: XBRMarket.createMarketFor

joinMarket
..........

.. autosolfunction:: XBRMarket.joinMarket

joinMarketFor
.............

.. autosolfunction:: XBRMarket.joinMarketFor

setConsent
..........

.. autosolfunction:: XBRMarket.setConsent

setConsentFor
.............

.. autosolfunction:: XBRMarket.setConsentFor


XBRCatalog
----------

.. autosolcontract:: XBRCatalog
    :members:

createCatalog
.............

.. autosolfunction:: XBRCatalog.createCatalog

createCatalogFor
................

.. autosolfunction:: XBRCatalog.createCatalogFor

publishApi
..........

.. autosolfunction:: XBRCatalog.publishApi

publishApiFor
.............

.. autosolfunction:: XBRCatalog.publishApiFor


XBRChannel
----------

.. autosolcontract:: XBRChannel
    :members:
        Opened,
        Closing,
        Closed,
        market,
        channels,
        channelClosingStates

openChannel
.............

.. autosolfunction:: XBRChannel.openChannel

closeChannel
.............

.. autosolfunction:: XBRChannel.closeChannel


XBRToken
--------

.. autosolcontract:: XBRToken
    :members:
    :exclude-members:
        INITIAL_SUPPLY,
        constructor
