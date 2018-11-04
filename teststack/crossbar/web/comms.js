var wsuri;

if (document.location.origin == "file://") {
   wsuri = "ws://127.0.0.1:8080/ws";

} else {
   wsuri = (document.location.protocol === "http:" ? "ws:" : "wss:") + "//" +
               document.location.host + "/ws";
}

var connection = new autobahn.Connection({
   url: wsuri,
   realm: "realm1"
});

var session = null;

async function test () {
    let a = await web3.eth.getAccounts();
    let acct = a[0];
    console.log('account:', acct);
}


connection.onopen = async function (new_session, details) {
    console.log("Connected", details);
    session = new_session;

    console.log('web3 version:', web3.version);
    await test();

    /*
    web3.eth.getAccounts().then(
        function (accounts) {
            var account = accounts[0];
            console.log(account);
        },
        function (err) {
            console.log(err);
        }
    );
    */
};

connection.onclose = function (reason, details) {
   console.log("Connection lost: " + reason, details);
   session = null;
}

connection.open();