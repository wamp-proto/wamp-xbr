Overview
========

.. contents:: :local:

----------

Contracts
---------

* :sol:contract:`XBRToken`
* :sol:contract:`XBRNetwork`
* :sol:contract:`XBRChannel`


Data Markets
------------

**XBR Data Markets** interact with the XBR Network calling:

1. :sol:func:`XBRNetwork.register` to register in the XBR network
2. :sol:func:`XBRNetwork.createMarket` to open a new market
3. :sol:func:`XBRNetwork.openPaymentChannel` to open a payment channel, depositing an amount of XBR token. this returns a new :sol:contract:`XBRPaymentChannel` SC
4. :sol:func:`XBRChannel.close` to close a payment channel.


Data Providers
---------------

**XBR Data Providers** interact with the XBR Network calling:

1. :sol:func:`XBRNetwork.register` to register in the XBR network
2. :sol:func:`XBRNetwork.joinMarket` to join a market, depositing an amount of XBR token as a security and for the market maker to open a payment channel with this data provider
3. :sol:func:`XBRNetwork.requestPayingChannel` to request a payment channel receiving money from the market maker, depositing an amount of XBR token. this returns a new :sol:contract:`XBRPaymentChannel` SC
4. :sol:func:`XBRChannel.close` to close a payment channel.


Data Consumers
--------------

**XBR Data Consumers** interact with the XBR Network calling:

1. :sol:func:`XBRNetwork.register` to register in the XBR network
2. :sol:func:`XBRNetwork.joinMarket` to join a market, depositing an amount of XBR token as a security
3. :sol:func:`XBRNetwork.openPaymentChannel` to open a payment channel, depositing an amount of XBR token. this returns a new :sol:contract:`XBRPaymentChannel` SC
4. :sol:func:`XBRChannel.close` to close a payment channel.

.. thumbnail:: /_static/gen/xbr_consumer_interactions.svg
