Developer Notes
===============

* Write a ``config.json`` node configuration.
* Encrypt the file with the node public key and the owner private key.
* Concatenate ciphertext and signature and upload to IPFS.

-------------

* https://www.maibornwolff.de/blog/zugriffskontrolle-bei-smart-contracts
* https://openzeppelin.org/api/docs/ownership_rbac_RBAC.html
* https://ethereum.meta.stackexchange.com/questions/443/blog-simple-storage-patterns-in-solidity
* https://medium.com/blockchannel/the-use-of-revert-assert-and-require-in-solidity-and-the-new-revert-opcode-in-the-evm-1a3a7990e06e


Solidity
--------

Scalar Types
............

Fixed size scalars:

* ``uint8``, ``uint16``, ``uint32``, ``uint64``, ``uint128``, ``uint256``
* ``int8``, ``int16``, ``int32``, ``int64``, ``int128``, ``int256``
* ``bytes1`` (aka ``byte``), ``bytes2``, ``bytes3``, ..., ``bytes32``.


Solidity includes 7 basic types:

* ``hash``: 256-bit, 32-byte data chunk, indexable into bytes and operable with bitwise operations.
* ``uint``: alias for an 256-bit unsigned integer, operable with bitwise and unsigned arithmetic operations.
* ``int``: alias for an 256-bit signed integer, operable with bitwise and signed arithmetic operations.
* ``string32``: zero-terminated ASCII string of maximum length 32-bytes (256-bit).
* ``address``: account identifier, similar to a 160-bit hash type.
* ``bool``: two-state value.


* **Timestamps**: we store timestamp as ``uint64`` with an integer with Unix epoch time in ns. 
* **UUIDs**: we store UUIDs as ``uint128`` with the binary 128 bits of the UUID
* **WAMP IDs**: WAMP IDs (should we ever have the need to store onchain) are integers in the range ``[0, 2**53]`` and we use ``uint64`` for storage.
* **WAMP-cryptsign keys**: WAMP ``cryptosign`` (public) keys are 256 bit (32 bytes)

Complex Types
.............

Structs are roughly like in C:

.. code-block:: solidity

    struct coinWallet {
        uint redCoin;
        uint greenCoin;
    }

    coinWallet myWallet;

    myWallet.redCoin = 500
    myWallet.greenCoin = 250

Mappings or associative arrays of keys to values look like this:

.. code-block:: solidity

    mapping (address => coinWallet) balances;

    balances[msg.sender].redCoin = 10000;
    balances[msg.sender].greenCoin = 5000;

Both keys and values can be of scalar or complex type themself.

The only data type that you cannot place inside a struct or a mapping is itself.

mapping (address => mapping (uint => uint)) balances;
balances[msg.sender][0] = 10000; ///red coin
balances[msg.sender][1] = 10000; ///orange coin
