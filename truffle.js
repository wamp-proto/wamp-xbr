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

    networks: {
        /*
        development: {
            host: "localhost",
            port: 7545,
            network_id: "*"
        },
        */

        ganache: {
            host: "localhost",
	        // port: 8545,
	        port: 1545,
            network_id: "5777",
            // gas: 0xfffffffffff,
            gas: 100000000,
            gasPrice: 0x01
        },

        // https://www.npmjs.com/package/solidity-coverage#network-configuration
        // https://github.com/sc-forks/solidity-coverage#network-configuration
        coverage: {
            host: "localhost",
            network_id: "*",
            port: 8555,
            gas: 0xfffffffffff,
            gasPrice: 0x01
        },
    },

    compilers: {
        solc: {
            version: "0.5.2"
        }
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
