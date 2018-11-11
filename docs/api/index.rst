XBR API
=======

.. toctree::
    :maxdepth: 1

    contracts
    market
    provider
    consumer

Add XBR to your project:

.. code-block:: console

    npm install --save xbr

Call a method on XBR:

.. code-block:: javascript

    var xbr = require('xbr');

    // xbr.network is a web3.eth.Contract

    // call a method on the XBRNetwork contract
    xbr.network.methods.register([eula, profile]).call()
        .then(function (result) {
            console.log('result:', result);
        })

Subscribe to events from XBR:

.. code-block:: javascript

    // subscribe to an event emitted by the XBRNetwork contract
    xbr.network.events.OnMemberRegistered()
        .on('data', function (event) {
            // Fires on each incoming event with the event object as argument.
            console.log(event);
        })
        .on('changed', function (event){
            // Fires on each event which was removed from the blockchain.
            // The event will have the additional property "removed: true"
            console.log(event);
        })
        .on('error', console.error); // Fires when an error in the subscription occurs.
