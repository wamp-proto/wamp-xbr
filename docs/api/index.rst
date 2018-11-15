.. _XBRAPI:

XBR API
=======

This is the XBR smart contracts API reference documentation, generated from the Solidity source code
using `Sphinx <http://www.sphinx-doc.org>`_ and `Solidity domain for Sphinx <https://solidity-domain-for-sphinx.readthedocs.io>`_.

.. contents:: :local:

----------


Overview
--------

**XBR Market Owners** call:

1. :sol:func:`XBRNetwork.register` to register in the XBR network
2. :sol:func:`XBRNetwork.createMarket` to open a new market
3. :sol:func:`XBRNetwork.openPaymentChannel` to open a payment channel, depositing an amount of XBR token. this returns a new :sol:contract:`XBRPaymentChannel` SC
4. :sol:func:`XBRPaymentChannel.close` to close a payment channel.


**XBR Data Providers** call:

1. :sol:func:`XBRNetwork.register` to register in the XBR network
2. :sol:func:`XBRNetwork.joinMarket` to join a market, depositing an amount of XBR token as a security and for the market maker to open a payment channel with this data provider
3. :sol:func:`XBRNetwork.requestPayingChannel` to request a payment channel receiving money from the market maker, depositing an amount of XBR token. this returns a new :sol:contract:`XBRPaymentChannel` SC
4. :sol:func:`XBRPaymentChannel.close` to close a payment channel.


**XBR Data Consumers** call:

1. :sol:func:`XBRNetwork.register` to register in the XBR network
2. :sol:func:`XBRNetwork.joinMarket` to join a market, depositing an amount of XBR token as a security
3. :sol:func:`XBRNetwork.openPaymentChannel` to open a payment channel, depositing an amount of XBR token. this returns a new :sol:contract:`XBRPaymentChannel` SC
4. :sol:func:`XBRPaymentChannel.close` to close a payment channel.

.. thumbnail:: /_static/gen/xbr_consumer_interactions.svg

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
