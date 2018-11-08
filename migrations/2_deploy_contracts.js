var XBRToken = artifacts.require("./XbrToken.sol");
var XBRToken = artifacts.require("./XbrPaymentChannel.sol");
var XBRNetwork = artifacts.require("./XbrNetwork.sol");
var XBRNetwork = artifacts.require("./XbrNetworkProxy.sol");

module.exports = function(deployer) {
  deployer.deploy(XbrToken);
  deployer.deploy(XbrPaymentChannel);
  deployer.deploy(XbrNetwork);
  deployer.deploy(XbrNetworkProxy);
};
