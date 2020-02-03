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

pragma solidity ^0.5.0;

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
function coverage_0x51328d66(bytes32 c__0x51328d66) public pure {}


    /**
     * The XBR Token has a fixed supply of 1 billion and uses 18 decimal digits.
     */
    uint256 public constant INITIAL_SUPPLY = 10**9 * 10**18;

    /**
     * Constructor that gives ``msg.sender`` all of existing tokens.
     * The XBR Token uses the symbol "XBR" and 18 decimal digits.
     */
    constructor() public ERC20Detailed("XBRToken", "XBR", 18) {coverage_0x51328d66(0xee50cc9c4feb3770a06df446f0c16f29a45c075056907be60edc0b91f67e42c2); /* function */ 

coverage_0x51328d66(0x6154f26adea747dbe2b115a14cc6b766ff70a4155c45c98b18577c5d042c3b47); /* line */ 
        coverage_0x51328d66(0x78708d46fa8e6796bac7f0e9ed4493dcd55f1bee361cdd11fef434346330e40b); /* statement */ 
_mint(msg.sender, INITIAL_SUPPLY);
    }
}
