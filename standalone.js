//
// https://truffleframework.com/docs/truffle/getting-started/package-management-via-npm#within-javascript-code
//
var contract = require("truffle-contract");

var XBRToken_json = require("./build/contracts/XBRToken.json");
var XBRNetwork_json = require("./build/contracts/XBRNetwork.json");
var XBRPaymentChannel_json = require("./build/contracts/XBRPaymentChannel.json");

var XBRToken = contract(XBRToken_json);
var XBRNetwork = contract(XBRNetwork_json);
var XBRPaymentChannel = contract(XBRPaymentChannel_json);

global.window.XBRToken = XBRToken;
global.window.XBRNetwork = XBRNetwork;
global.window.XBRPaymentChannel = XBRPaymentChannel;

//global.window.XBRToken = XBRTokenContract.at('0x405fc0ee23c7fcd0a41a864505fe8c969ca3ef6a');
//global.window.XBRNetwork = XBRNetworkContract.at('0x4a1d2a5060c782049ef966d9412f1239e95183b7');
