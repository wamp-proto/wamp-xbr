// https://github.com/sc-forks/solidity-coverage#options

module.exports = {
    norpc: false,
    port: 8555,
    //testCommand: "truffle test --network coverage",
    testrpcOptions: '--port 8555 --gasLimit 0xfffffffffff --gasPrice 1 --accounts 15',
    //testrpcOptions: '-p 8555 -l 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF -g 0x1',
    dir: '.',
    copyPackages: ['openzeppelin-solidity'],
    skipFiles: ['Migrations.sol','XBRMaintained.sol', 'XBRNetwork.sol', 'XBRNetworkProxy.sol', 'XBRPaymentChannel.sol']
};
