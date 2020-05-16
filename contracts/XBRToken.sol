///////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2018-2020 Crossbar.io Technologies GmbH and contributors.
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

pragma solidity ^0.5.12;
pragma experimental ABIEncoderV2;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";

import "./XBRTypes.sol";


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
contract XBRToken is ERC20, ERC20Detailed {

    /// EIP712 type data.
    // solhint-disable-next-line
    bytes32 constant EIP712_DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    /// EIP712 type data.
    // solhint-disable-next-line
    bytes32 constant EIP712_APPROVE_TYPEHASH = keccak256("EIP712Approve(address sender,address relayer,address spender,uint256 amount,uint256 expires,uint256 nonce)");

    /// EIP712 type data.
    struct EIP712Domain {
        string name;
        string version;
        uint256 chainId;
        address verifyingContract;
    }

    /// EIP712 type data.
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

    mapping(bytes32 => uint256) burnedSignatures;

    /**
     * Constructor that gives ``msg.sender`` all of existing tokens.
     * The XBR Token uses the symbol "XBR" and 18 decimal digits.
     */
    constructor() public ERC20Detailed("XBRToken", "XBR", 18) {
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    function hash (EIP712Approve memory obj) public view returns (bytes32) {

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

    function verify (address signer, EIP712Approve memory obj, bytes memory signature) public view returns (bool) {

        bytes32 digest = hash(obj);
        (uint8 v, bytes32 r, bytes32 s) = XBRTypes.splitSignature(signature);

        return ecrecover(digest, v, r, s) == signer;
    }

    function approveFor (address sender, address relayer, address spender, uint256 amount, uint256 expires,
        uint256 nonce, bytes memory signature) public returns (bool) {

        EIP712Approve memory approve = EIP712Approve(sender, relayer, spender, amount, expires, nonce);

        // signature must be valid (signed by address in parameter "sender" - not the necessarily
        // the "msg.sender", the submitted of the transaction!)
        require(verify(sender, approve, signature), "INVALID_APPROVE_SIGNATURE");

        // signature must not have been expired
        require(expires < block.number || expires == 0, "SIGNATURE_EXPIRED");

        // signature must not have been expired
        bytes32 digest = hash(approve);
        require(burnedSignatures[digest] == 0x0, "SIGNATURE_REUSED");

        // mark signature as used
        burnedSignatures[digest] = 0x1;

        // now to the actual approval. this code is idential to "contracts/token/ERC20/ERC20.sol#L136"
        // here https://github.com/OpenZeppelin/openzeppelin-contracts
        _approve(_msgSender(), spender, amount);

        return true;
    }
}
