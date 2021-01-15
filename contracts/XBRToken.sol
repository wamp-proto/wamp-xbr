// SPDX-License-Identifier: Apache-2.0

///////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2018-2021 Crossbar.io Technologies GmbH and contributors.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
///////////////////////////////////////////////////////////////////////////////

pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

// import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
// import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.3.0/contracts/token/ERC20/IERC20.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.3.0/contracts/token/ERC20/ERC20.sol";

import "./XBRTypes.sol";


interface IXBRTokenRelayInterface {
    function getRelayAuthority() external view returns (address);
}


/**
 * The `XBR Token <https://github.com/crossbario/xbr-protocol/blob/master/contracts/XBRToken.sol>`__
 * is a `ERC20 standard token <https://eips.ethereum.org/EIPS/eip-20>`__ defined by:
 *
 * * "XBR" as symbol
 * * fixed total supply of 10**9 ("one billion") XBR
 * * 18 decimals
 * * address (mainnet): tbd
 *
 * The XBR Token is using the (unmodified) `OpenZeppelin <https://openzeppelin.org/>`__
 * `reference implementation <https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol>`__
 * of the ERC20 token standard.
 *
 * For API documentation, please see `here <https://docs.openzeppelin.com/contracts/2.x/api/token/erc20>`__.
 */
contract XBRToken is ERC20 {

    /// EIP712 type data.
    // solhint-disable-next-line
    bytes32 constant EIP712_DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    /// EIP712 type data.
    // solhint-disable-next-line
    bytes32 constant EIP712_APPROVE_TYPEHASH = keccak256("EIP712Approve(address sender,address relayer,address spender,uint256 amount,uint256 expires,uint256 nonce)");

    /// EIP712 Domain type data.
    struct EIP712Domain {
        string name;
        string version;
        uint256 chainId;
        address verifyingContract;
    }

    /// EIP712 Approve type data.
    struct EIP712Approve {
        address sender;
        address relayer;
        address spender;
        uint256 amount;
        uint256 expires;
        uint256 nonce;
    }

    /**
     * The XBR Token has a fixed supply of 1 billion and uses 18 decimal digits.
     */
    uint256 private constant INITIAL_SUPPLY = 10**9 * 10**18;

    /// For pre-signed transactions ("approveFor"), track signatures already used.
    mapping(bytes32 => uint256) private burnedSignatures;

    /**
     * Constructor that gives ``msg.sender`` all of existing tokens.
     * The XBR Token uses the symbol "XBR" and 18 decimal digits.
     */
    constructor() public ERC20("XBRToken", "XBR") {
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    function hash (EIP712Approve memory obj) private view returns (bytes32) {

        bytes32 digestDomain = keccak256(abi.encode(
            EIP712_DOMAIN_TYPEHASH,
            keccak256(bytes("XBRToken")),
            keccak256(bytes("1")),
            1,  // FIXME: read chain_id at run-time
            address(this)
        ));

        bytes32 digestApprove = keccak256(abi.encode(
            EIP712_APPROVE_TYPEHASH,
            obj.sender,
            obj.relayer,
            obj.spender,
            obj.amount,
            obj.expires,
            obj.nonce
        ));

        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            digestDomain,
            digestApprove
        ));

        return digest;
    }

    function verify (address signer, EIP712Approve memory obj, bytes memory signature) private view returns (bool) {

        bytes32 digest = hash(obj);
        (uint8 v, bytes32 r, bytes32 s) = XBRTypes.splitSignature(signature);

        return ecrecover(digest, v, r, s) == signer;
    }

    /**
     * This method provides an extension to the standard ERC20 interface that allows to approve tokens
     * to be spent by another party or contract, similar to the standard `IERC20.approve` method.
     *
     * The difference is, that by using this method, the sender can pre-sign the approval off-chain, and
     * then let another party (the relayer) submit the transaction to the blockchain. Only the relayer
     * needs to have ETH to pay for gas, the off-chain sender does _not_ need any ETH.
     *
     * @param sender    The (off-chain) sender of tokens.
     * @param relayer   If given, the metatransaction can only be relayed from this address.
     * @param spender   The spender that will spend the tokens approved.
     * @param amount    Token amount to approve for the spender to spend.
     * @param expires   If given, the signature will expire at this block number.
     * @param nonce     Random nonce for metatransaction.
     * @param signature Signature over EIP712 data, signed by sender.
     */
    function approveFor (address sender, address relayer, address spender, uint256 amount, uint256 expires,
        uint256 nonce, bytes memory signature) public returns (bool) {

        EIP712Approve memory approve = EIP712Approve(sender, relayer, spender, amount, expires, nonce);

        // signature must be valid (signed by address in parameter "sender" - not the necessarily
        // the "msg.sender", the submitted of the transaction!)
        require(verify(sender, approve, signature), "INVALID_SIGNATURE");

        // relayer rules:
        //  1. always allow relaying if the specified "relayer" is 0
        //  2. if the authority address is not a contract, allow it to relay
        //  3. if the authority address is a contract, allow its defined 'getAuthority()' delegate to relay
        require(
            (relayer == address(0x0)) ||
            (!XBRTypes.isContract(relayer) && msg.sender == relayer) ||
            (XBRTypes.isContract(relayer) && msg.sender == IXBRTokenRelayInterface(relayer).getRelayAuthority()),
            "INVALID_RELAYER"
        );

        // signature must not have been expired
        require(block.number < expires || expires == 0, "SIGNATURE_EXPIRED");

        // signature must not have been used
        bytes32 digest = hash(approve);
        require(burnedSignatures[digest] == 0x0, "SIGNATURE_REUSED");

        // mark signature as "consumed"
        burnedSignatures[digest] = 0x1;

        // now to the actual approval. also see "contracts/token/ERC20/ERC20.sol#L136"
        // here https://github.com/OpenZeppelin/openzeppelin-contracts
        _approve(sender, spender, amount);

        return true;
    }

    /**
     * This method allows a sender that approved tokens via `approveFor` to burn the metatransaction
     * that was sent to the relayer - but only if the transaction has not yet been submitted by the relay.
     */
    function burnSignature (address sender, address relayer, address spender, uint256 amount, uint256 expires,
        uint256 nonce, bytes memory signature) public returns (bool success) {

        EIP712Approve memory approve = EIP712Approve(sender, relayer, spender, amount, expires, nonce);

        // signature must be valid (signed by address in parameter "sender" - not the necessarily
        // the "msg.sender", the submitted of the transaction!)
        require(verify(sender, approve, signature), "INVALID_SIGNATURE");

        // only the original signature creator can burn signature, not a relay
        require(sender == msg.sender);

        // signature must not have been used
        bytes32 digest = hash(approve);
        require(burnedSignatures[digest] == 0x0, "SIGNATURE_REUSED");

        // mark signature as "burned"
        burnedSignatures[digest] = 0x2;

        return true;
    }
}
