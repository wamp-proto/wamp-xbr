Domains
=======

.. contents:: :local:

----------

Creating Domains
----------------

After registering in the XBR Network, stakeholders that want to run their own
data routing nodes will first need to create a XBR Domain.

JavaScript
..........

.. code-block:: javascript

    async function main (account) {

        // domainId (like all IDs in XBR) is a 128 bit (16 bytes) unique value
        // here, we derive a deterministic ID from a name. other approaches to
        // get an ID are fine too - as long as the ID is unique
        const domainId = web3.sha3('MyDomain1').substring(0, 34);

        const key = '';
        const license = '';
        const terms = '';
        const meta = '';

        // now actually create the domain. the sender will become domain owner.
        // bytes16 domainId, bytes32 domainKey, string license, string terms, string meta
        await xbr.xbrNetwork.createDomain(domainId, key, license, terms.
            meta, {from: account});
    }


Pairing Nodes
-------------

JavaScript
..........

To pair a node with a XBR Domain in JavaScript:

.. code-block:: javascript

    async function main (account) {

        // derive (deterministically) an ID for our domain
        const domainId = web3.sha3('MyDomain1').substring(0, 34);

        // derive (deterministically) an ID for our node
        const nodeId = web3.sha3('MyNode1').substring(0, 34);

        // pair as master node
        const nodeType = xbr.NodeType.MASTER;
        // const nodeType = xbr.NodeType.EDGE;

        const nodeKey = '';
        const config = '';

        // bytes16 nodeId, bytes16 domainId, NodeType nodeType, bytes32 nodeKey, string config
        await xbr.xbrNetwork.pairNode(nodeId, domainId, nodeType, nodeKey, config, {from: account});
    }
