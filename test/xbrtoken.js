var XBRToken = artifacts.require("./XBRToken.sol");

contract('XBRToken', function (accounts) {
    XBR_TOTAL_SUPPLY = 10**9 * 10**18;

    it("should have produced the right initial supply of XBRToken", function () {
        return XBRToken.deployed().then(function (instance) {
            return instance.totalSupply.call();
        }).then(function (supply) {
            assert.equal(supply.valueOf(), XBR_TOTAL_SUPPLY, "Wront initial supply for token");
        });
    });

    it("should initially put all XBRToken in the first account", function () {
        return XBRToken.deployed().then(function (instance) {
            return instance.balanceOf.call(accounts[0]);
        }).then(function (balance) {
            assert.equal(balance.valueOf(), XBR_TOTAL_SUPPLY, "Initial supply wasn't allocated to the first account");
        });
    });
});
