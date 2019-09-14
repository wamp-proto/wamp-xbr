///////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2018-2019 Crossbar.io Technologies GmbH and contributors.
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

pragma solidity ^0.5.2;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";


/**
 * The XBR Token is a `ERC20` compatible token using (with no modifications)
 * the OpenZeppelin (https://openzeppelin.org/) reference implementation.
 *
 * For API, please see
 *
 *   * https://docs.openzeppelin.com/contracts/2.x/api/token/erc20
 *   * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol
 */
contract XBRToken is ERC20, ERC20Detailed {

    /**
     * The XBR Token has a fixed supply of 1 billion and uses 18 decimal digits.
     */
    uint256 public constant INITIAL_SUPPLY = 10**9 * 10**18;

    /**
     * Constructor that gives ``msg.sender`` all of existing tokens.
     * The XBR Token uses the symbol "XBR" and 18 decimal digits.
     */
    constructor() public ERC20Detailed("XBRToken", "XBR", 18) {
        _mint(msg.sender, INITIAL_SUPPLY);
    }
}
