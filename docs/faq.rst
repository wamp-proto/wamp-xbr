FAQ
===

.. contents:: :local:


What Blockchain options do I have?
----------------------------------

**Local Development Network**

**Public Ethereum Networks**

Mainnet and Ropsten

**Infura**

**QuikNode**

https://quiknode.io/

Yes, by avoiding queues to public/shared nodes, especially those which form during a crowdsale,
your transaction has a higher chance of success. QuikNodes are on high-speed Internet connections,
always online, and always synced, so your transaction is broadcast to the Ethereum network
as quickly as possible.

Over 1000 total QNodes launched (Q3 2018)

QuikNode costs 0.77 Ether for 30 days. 7-day & 3/6/12-month terms are available!


**Running an own Node**

You can totally run your own Ethereum full node, connected to the public Mainnet,
or the Ropsten testnet. We recommend `Go Ethereum ("geth") <https://geth.ethereum.org/>`__:

"Go Ethereum is one of the three original implementations (along with C++ and Python) of
the Ethereum protocol. It is written in Go, fully open source and licensed under
the GNU LGPL v3."

Here are minimum requirements for a full (geth) node on the Ropsten testnet:

* Minimum: 4GB RAM, 50GB disk (e.g. AWS EC2 ``t3.medium``)
* Full sync: 4 hours


**Private Ethereum Networks**

**Non-Ethereum Blockchain**

---------


Why run an own (public) Ethereum node?
--------------------------------------

By avoiding queues to public/shared nodes (e.g. during a crowdsale)
transactions submitted via your node (presumably allowed only from your app)
have a higher chance of being mined quickly, and finalized with success.

Your own node can have a redundant high-speed Internet connection,
always online, and is always synced, so your transaction is broadcast to the
Ethereum public network as quickly as possible.

Event monitors - When creating customized block explorers and monitors, these need
access to the complete transaction logs including events. Infura does not seem to
provide wholesale event monitoring (via WebSocket). Quiknodes does support that,
as does of course an own (geth) node.

Running your own node can allow you to queue and cache a batch of transactions
that can be pushed out to the network.

---------


What are the gas costs for XBR operations?
------------------------------------------

Estimated gas costs for XBR Network operations:


How to resolve the MetaMask error ``"tx doesn't have the correct nonce"``?
--------------------------------------------------------------------------

From `here <https://ethereum.stackexchange.com/questions/30921/tx-doesnt-have-the-correct-nonce-metamask>`_:

"If you're running a test blockchain that you've shut down and restarted from a blank state with MetaMask
connected to it, you can get MetaMask confused, because it caches some information about the network it
is currently connected to, including completed transactions, which it uses to derive the correct nonce.

You can clear this cache by selecting a different network in MetaMask or reinstall MetaMask."
