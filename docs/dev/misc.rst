Other functions and services
============================

.. contents:: :local:

----------

Cryptographic Hashing
---------------------

Ethereum widely uses Keccak 256 bit hashes - which are almost, but not completely
the same as SHA3-256 hashes.

You can use ``Web3.js`` to compute hashes in `JavaScript <https://web3js.readthedocs.io/en/1.0/web3-utils.html#sha3>`_:

.. code-block:: console

    web3.sha3('hello');
    "0x1c8aff950685c2ed4bc3174f3472287b56d9517b9c948127319a09a7a36deac8"

For Python, ``Web3.py`` provides similar `functionality <https://web3py.readthedocs.io/en/stable/overview.html?highlight=Web3.sha3#cryptographic-hashing>`_:

.. code-block:: python

    >>> import web3
    >>> web3.Web3.sha3('hello'.encode('utf8'))
    HexBytes('0x1c8aff950685c2ed4bc3174f3472287b56d9517b9c948127319a09a7a36deac8')


Local Private Keys
------------------


Receiving Blockchain Events
---------------------------
