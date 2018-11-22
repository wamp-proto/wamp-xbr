/*
 * NB: since truffle-hdwallet-provider 0.0.5 you must wrap HDWallet providers in a
 * function when declaring them. Failure to do so will cause commands to hang. ex:
 * ```
 * mainnet: {
 *     provider: function() {
 *       return new HDWalletProvider(mnemonic, 'https://mainnet.infura.io/<infura-key>')
 *     },
 *     network_id: '1',
 *     gas: 4500000,
 *     gasPrice: 10000000000,
 *   },
 */

module.exports = {
    // See <http://truffleframework.com/docs/advanced/configuration>
    // to customize your Truffle configuration!

    // use with: truffle migrate --network development
    networks: {
        development: {
            host: "localhost",
            port: 7545,
            network_id: "*"
        },

        ganache: {
            host: "localhost",
            port: 8545,
            network_id: "*",
            //gas: 0xfffffffffff,
            //gasPrice: 1
            //gas: 6721975,
            //gasPrice: 1
            //gas: 4698712,
            //gasPrice: 20000000000
        },
/*
        // https://github.com/sc-forks/solidity-coverage#network-configuration
        coverage: {
            host: "localhost",
            network_id: "*",
            port: 8545,         // <-- If you change this, also set the port option in .solcover.js.
            //gas: 0xfffffffffff, // <-- Use this high gas value
            //gasPrice: 0x01      // <-- Use this low gas price
        }
*/
    },

    solc: {
        optimizer: {
            enabled: true,
            runs: 200
        }
    },

    mocha: {
        useColors: true
    }
};
