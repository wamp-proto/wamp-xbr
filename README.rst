The XBR Protocol
================

|Build| |Deploy| |Coverage| |Docs (on CDN)| |Docs (on S3)| |ABIs (on CDN)| |ABIs (on S3)|

The **XBR Protocol** enables secure peer-to-peer data-trading and -service microtransactions in
`Open Data Markets <https://xbr.network>`__ between multiple independent entities.

XBR as a protocol sits on top of `WAMP <https://wamp-proto.org>`__, an open messaging middleware and service mesh technology,
and enables secure integration, trusted sharing and monetization of data and data-driven microservices
between different parties and users.

The XBR Protocol specification is openly developed and freely usable.

The protocol is implemented in *smart contracts* written in `Solidity <https://solidity.readthedocs.io>`__
and open-source licensed (`Apache 2.0 <https://github.com/crossbario/xbr-protocol/blob/master/LICENSE>`__).
Smart contracts are designed to run on the `Ethereum blockchain <https://ethereum.org/>`__.
All source code for the XBR smart contracts is developed and hosted in the
project main `GitHub repository <https://github.com/crossbario/xbr-protocol>`__.

The XBR Protocol and reference documentation can be found `here <https://s3.eu-central-1.amazonaws.com/xbr.foundation/docs/protocol/index.html>`__.

Contract addresses
------------------

Contract addresses for local development on Ganache, using the

```
export XBR_HDWALLET_SEED="myth like bonus scare over problem client lizard pioneer submit female collect"
```

which result in the following contract addresses (when the deployment is the very first transactions on Ganache):

```
export XBR_DEBUG_TOKEN_ADDR=0xCfEB869F69431e42cdB54A4F4f105C19C080A601
export XBR_DEBUG_NETWORK_ADDR=0xC89Ce4735882C9F0f0FE26686c53074E09B0D550
export XBR_DEBUG_MARKET_ADDR=0x9561C133DD8580860B6b7E504bC5Aa500f0f06a7
export XBR_DEBUG_CATALOG_ADDR=0xD833215cBcc3f914bD1C9ece3EE7BF8B14f841bb
export XBR_DEBUG_CHANNEL_ADDR=0xe982E462b094850F12AF94d21D470e21bE9D0E9C
```

Application development
-----------------------

The XBR smart contracts primary build artifacts are the `contract ABIs JSON files <https://github.com/crossbario/xbr-protocol/tree/master/abi>`__.
The ABI files are built during compiling the `contract sources <https://github.com/crossbario/xbr-protocol/tree/master/contracts>`__.
Technically, the ABI files are all you need to interact and talk to the XBR smart contracts deployed to a blockchain
from any (client side) language or run-time that supports Ethereum, such as
`web3.js <https://web3js.readthedocs.io>`__ or `web3.py <https://web3py.readthedocs.io>`__.

However, this approach (using the raw XBR ABI files directly from a "generic" Ethereum client library) can be cumbersome
and error prone to maintain. An alternative way is using a client library with built-in XBR support.

The XBR project currently maintains the following **XBR-enabled client libraries**:

-  `Autobahn|Python <https://github.com/crossbario/autobahn-python>`__ for Python 3.5+
-  `Autobahn|JavaScript <https://github.com/crossbario/autobahn-js>`__ for JavaScript, in browser and NodeJS
-  `Autobahn|Java <https://github.com/crossbario/autobahn-java>`__ (*beta XBR support*) for Java on Android and Java 8 / Netty
-  `Autobahn|C++ <https://github.com/crossbario/autobahn-cpp>`__ (*XBR support planned*) for C++ 11+ and Boost/ASIO

XBR support can be added to any `WAMP client library <https://wamp-proto.org/implementations.html#libraries>`__
with a language run-time that has packages for Ethereum application development.

.. |Build| image:: https://github.com/crossbario/xbr-protocol/workflows/main/badge.svg
   :target: https://github.com/crossbario/xbr-protocol/actions?query=workflow%3Amain
   :alt: Build Status

.. |Deploy| image:: https://github.com/crossbario/xbr-protocol/workflows/deploy/badge.svg
   :target: https://github.com/crossbario/xbr-protocol/actions?query=workflow%3Adeploy
   :alt: Deploy Status

.. |Coverage| image:: https://img.shields.io/codecov/c/github/crossbario/xbr-protocol/master.svg
   :target: https://codecov.io/github/crossbario/xbr-protocol

.. |Docs (on CDN)| image:: https://img.shields.io/badge/Docs-CDN-yellow.svg?style=flat
   :target: https://xbr.network/docs/protocol/index.html

.. |Docs (on S3)| image:: https://img.shields.io/badge/Docs-S3-yellow.svg?style=flat
   :target: https://s3.eu-central-1.amazonaws.com/xbr.foundation/docs/protocol/index.html

.. |ABIs (on CDN)| image:: https://img.shields.io/badge/ABIs-CDN-blue.svg?style=flat
   :target: https://xbr.network/lib/abi/xbr-protocol-latest.zip

.. |ABIs (on S3)| image:: https://img.shields.io/badge/ABIs-S3-blue.svg?style=flat
   :target: https://s3.eu-central-1.amazonaws.com/xbr.foundation/lib/abi/xbr-protocol-latest.zip
