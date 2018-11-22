// https://github.com/sc-forks/solidity-coverage#options

module.exports = {
    norpc: true,
    port: 8545,
    testCommand: "truffle test --network ganache"
    //testrpcOptions: '-p 9545 --gasLimit 0xfffffffffff --gasPrice 1',
};
