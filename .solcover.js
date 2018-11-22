// https://github.com/sc-forks/solidity-coverage#options

module.exports = {
    norpc: false,
    port: 9545,
    testCommand: "truffle test --network coverage",
    testrpcOptions: '--port 9545 --gasLimit 0xfffffffffff --gasPrice 1',
};
