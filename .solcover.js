// https://github.com/sc-forks/solidity-coverage#options

module.exports = {
    norpc: false,
    port: 9545,
    testCommand: "truffle test --network coverage",
    testrpcOptions: '--port 9545 --networkId 5777 --gasLimit 0xfffffffffff --gasPrice 1 --accounts 15 --defaultBalanceEther 100000000 --deterministic --mnemonic "myth like bonus scare over problem client lizard pioneer submit female collect"',
    dir: '.',
    copyPackages: ['openzeppelin-solidity'],
    skipFiles: ['Migrations.sol','XBRMaintained.sol', 'XBRNetwork.sol', 'XBRNetworkProxy.sol', 'XBRPaymentChannel.sol']
};
