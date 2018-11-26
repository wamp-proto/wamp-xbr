.. _XBRAPI:

API Reference
=============

This is the XBR smart contracts API reference documentation, generated from the Solidity source code
using `Sphinx <http://www.sphinx-doc.org>`_ and `Solidity domain for Sphinx <https://solidity-domain-for-sphinx.readthedocs.io>`_.

.. contents:: :local:

----------

Using the ABI files
-------------------

Python
......

.. code-block:: python

    import json
    import pkg_resources
    from pprint import pprint

    with open(pkg_resources.resource_filename('xbr', 'contracts/XBRToken.json')) as f:
        data = json.loads(f.read())
        abi = data['abi']
        pprint(abi)


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
