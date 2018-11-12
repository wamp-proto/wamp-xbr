const XBRNetwork = artifacts.require("./XBRNetwork.sol");

contract('XBRNetwork', accounts => {

    const owner = accounts[0];
    const alice = accounts[1];
    const bob = accounts[2];

    it('owner account should be initially registered', async () => {
        const network = await XBRNetwork.deployed();

        const level = await network.getMemberLevel(owner);

        assert.equal(level.toNumber(), 2, "wrong member level");
    });

    it('non-owner accounts should be initially unregistered', async () => {
        const network = await XBRNetwork.deployed();

        var level = await network.getMemberLevel(alice);
        assert.equal(level.toNumber(), 0, "wrong member level");

        var level = await network.getMemberLevel(bob);
        assert.equal(level.toNumber(), 0, "wrong member level");
    });

    it('should create new member, and with the correct member level', async () => {
        const network = await XBRNetwork.deployed();

        const eula = "0x0000000000000000000000000000000000000000000000000000000000000000";
        const profile = "0x0000000000000000000000000000000000000000";

        await network.register(eula, profile, {from: alice});

        const level = await network.getMemberLevel(alice);

        assert.equal(level.toNumber(), 1, "wrong member level");
    });
});
