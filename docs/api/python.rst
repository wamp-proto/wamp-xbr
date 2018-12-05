Python API
==========

This is the **XBR Lib for Python** API reference documentation, generated from the Python source code
using `Sphinx <http://www.sphinx-doc.org>`_.

.. contents:: :local:

----------


Using the ABI files
-------------------

.. code-block:: python

    import json
    import pkg_resources
    from pprint import pprint

    with open(pkg_resources.resource_filename('xbr', 'contracts/XBRToken.json')) as f:
        data = json.loads(f.read())
        abi = data['abi']
        pprint(abi)


SimpleBuyer
-----------

.. autoclass:: xbr.SimpleBuyer
    :members:
        start,
        unwrap


SimpleSeller
------------

.. autoclass:: xbr.SimpleSeller
    :members:
        start,
        wrap,
        sell


IMarketMaker
------------

.. autoclass:: xbr.IMarketMaker
    :members:
        status,
        offer,
        revoke,
        quote,
        buy,
        get_payment_channels,
        get_payment_channel


IProvider
---------

.. autoclass:: xbr.IProvider
    :members:
        sell


IConsumer
---------

.. autoclass:: xbr.IConsumer
    :members:


ISeller
-------

.. autoclass:: xbr.ISeller
    :members:
        start,
        wrap


IBuyer
------

.. autoclass:: xbr.IBuyer
    :members:
        start,
        unwrap

