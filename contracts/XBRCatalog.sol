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


contract XBRCatalog {

    /// Address of XBRNetwork instance that created this catalog.
    address public network;

    address public owner;

    string public terms;

    string public meta;

/*
    constructor (address network_, address owner_, string memory terms_, string memory meta_) public {
        network = network_;
        owner = owner_;
        terms = terms_;
        meta = meta_;
    }
*/
/*
    function initialize (address network_, address owner_, string memory terms_, string memory meta_) {
        network = network_;
        owner = owner_;
        terms = terms_;
        meta = meta_;
    }
*/
}
