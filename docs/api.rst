.. _XBRAPI:

XBR API Reference
=================

Here is the API reference documentation directly generated from the XBR protocol Solidity smart contracts
using `Sphinx <http://www.sphinx-doc.org>`_ and `Solidity domain for Sphinx <https://solidity-domain-for-sphinx.readthedocs.io>`_.

.. contents:: :local:

:sol:contract:`XBRPaymentChannel`

----------


XBR Token
---------

.. autosolcontract:: XBRToken
    :members:
        INITIAL_SUPPLY,
        constructor


XBR Payment Channel
-------------------

.. autosolcontract:: XBRPaymentChannel
    :members:
        Closing,
        Closed,
        constructor,
        close,
        timeout


XBR Network
-----------

.. autosolcontract:: XBRNetwork
    :members:


XBR Network Proxy
-----------------

.. autosolcontract:: XBRNetworkProxy
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
