// https://github.com/sc-forks/solidity-coverage#options
// https://ethereum.stackexchange.com/a/47938/17806

module.exports = {
    dir: '.',
    port: 8555,
    copyPackages: [
        'openzeppelin-solidity'
    ],
    skipFiles: [
        'contracts/Migrations.sol',
    ],
    rules: {
        'no-unused-vars': 'off'
    },
    providerOptions: {
        seed: "myth like bonus scare over problem client lizard pioneer submit female collect"
    }
};
