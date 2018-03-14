pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SimpleStorage.sol";

contract TestSimpleStorage {

  function test_deployed_initial_value() public {
    SimpleStorage store = SimpleStorage(DeployedAddresses.SimpleStorage());

    uint expected = 1;

    Assert.equal(store.get(), expected, "stored value should be 1 initially");
  }

  function test_new_initial_value() public {
    SimpleStorage store = new SimpleStorage();

    uint expected = 1;

    Assert.equal(store.get(), expected, "stored value should be 1 initially");
  }
}
