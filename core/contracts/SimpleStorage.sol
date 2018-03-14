pragma solidity ^0.4.0;

contract SimpleStorage {
    uint storedData;

    function SimpleStorage() public {
        storedData = 1;
    }

    function set(uint x) public {
        storedData = x;
    }

    function get() public constant returns (uint) {
        return storedData;
    }
}
