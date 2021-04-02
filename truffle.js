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

const web3 = require("web3");

const XBR_HDWALLET_SEED = process.env.XBR_HDWALLET_SEED;

var HDWalletProvider = require("truffle-hdwallet-provider");

module.exports = {
    // See <http://truffleframework.com/docs/advanced/configuration>
    // to customize your Truffle configuration!

    networks: {
        geth: {
            host: "localhost",
            port: 1545,
            network_id: "5777"
        },

        ganache: {
            // provider: function() {
            //     return new HDWalletProvider(XBR_HDWALLET_SEED, "http://localhost:1545")
            // },
            host: "localhost",
	        port: 1545,
            network_id: "5777",
            gas: 10000000,
            gasPrice: web3.utils.toWei("8", "gwei")
        },

        // https://medium.com/coinmonks/5-minute-guide-to-deploying-smart-contracts-with-truffle-and-ropsten-b3e30d5ee1e
        ropsten: {
            provider: function() {
                const XBR_INFURA_ENDPOINT= "https://ropsten.infura.io/v3/40c6959767364c2cb961bd389c738d98";

                return new HDWalletProvider(XBR_HDWALLET_SEED, XBR_INFURA_ENDPOINT)
            },
            network_id: 3,
            gas: 10000000,
            gasPrice: web3.utils.toWei("50", "gwei")
        },

        // https://ethereum.stackexchange.com/a/17101/17806
        rinkeby: {
            provider: function() {
                const XBR_INFURA_ENDPOINT= "https://rinkeby.infura.io/v3/40c6959767364c2cb961bd389c738d98";

                return new HDWalletProvider(XBR_HDWALLET_SEED, XBR_INFURA_ENDPOINT)
            },
            network_id: 4,
            // https://www.rinkeby.io/#stats
            gas: 10000000,
            gasPrice: web3.utils.toWei("50", "gwei")
        }
    },

    // https://www.trufflesuite.com/docs/truffle/reference/configuration#solc
    // https://github.com/trufflesuite/truffle-compile/issues/7#issuecomment-449629758
    compilers: {
        solc: {
            // https://github.com/ethereum/solidity/tags
            version: "0.6.12",
            settings: {
                optimizer: {
                    enabled: true,
                    runs: 200
                }
                // Can be homestead, tangerineWhistle, spuriousDragon, byzantium, constantinople, petersburg, istanbul or berlin
                // evmVersion: "constantinople"
            }
        }
    },

    mocha: {
        useColors: true
    },

    plugins: [
        'truffle-plugin-verify',
        'verify-on-etherscan',
        'solidity-coverage'
    ],
    api_keys: {
        etherscan: process.env.ETHERSCAN_API_KEY
    }
};
