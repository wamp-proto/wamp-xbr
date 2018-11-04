API Reference
=============

Here is the API reference documentation directly generated from the XBR protocol Solidity smart contracts
using `Sphinx <http://www.sphinx-doc.org>`_ and `Solidity domain for Sphinx <https://solidity-domain-for-sphinx.readthedocs.io>`_.

.. autosolcontract:: XBRToken
    :members:

.. autosolcontract:: XBRNetwork
    :members:
        network_token,
        network_organization,
        members,
        join

.. autosolcontract:: XBRMarket


.. autosolcontract:: "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol"


Write a ``config.json`` node configuration.

Encrypt the file with the node public key and the owner private key.

Concatenate ciphertext and signature and upload to IPFS.

