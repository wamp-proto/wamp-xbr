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

var XBR_HDWALLET_SEED = process.env.XBR_HDWALLET_SEED;
var XBR_INFURA_ENDPOINT= "https://ropsten.infura.io/v3/40c6959767364c2cb961bd389c738d98";

var HDWalletProvider = require("truffle-hdwallet-provider");

module.exports = {
    // See <http://truffleframework.com/docs/advanced/configuration>
    // to customize your Truffle configuration!

    networks: {
        geth: {
            host: "localhost",
            port: 1545,
            network_id: "5777",
            //from: "0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1"
            //from: "0x4c5E35F5bC1D26d7a6Bb7Ff343CDaB110bC87B5E"
        },

        ganache: {
            host: "localhost",
	        // port: 8545,
	        port: 1545,
            network_id: "5777",
            gas: 0xfffffffffff,
            // gas: 100000000,
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

        // https://medium.com/coinmonks/5-minute-guide-to-deploying-smart-contracts-with-truffle-and-ropsten-b3e30d5ee1e
        ropsten: {
            provider: function() {
                return new HDWalletProvider(XBR_HDWALLET_SEED, XBR_INFURA_ENDPOINT)
            },
            network_id: 3,
            gas: 2900000
        }
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
