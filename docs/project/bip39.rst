HD Wallets
==========

To generate a set of Ethereum accounts from a BIP39 (mnemonic) seedphrase one easy way
is to use `iancoleman/bip39 <https://github.com/iancoleman/bip39>`_:

.. code-block:: console

    cd ~
    wget https://github.com/iancoleman/bip39/releases/download/0.3.12/bip39-standalone.html
    firefox bip39-standalone.html

Then either generate a new seedphrase (BIP39 Mnemonic) or insert your known seedphrase.
For "Coin", select "ETH - Ethereum". Then goto "Derived Addresses" to get a list of *public addresses*
and *private keys*.
