pragma solidity ^0.4.15;

import "OpenController.sol";
import "OpenControllerFactory.sol";
import "wafr/Test.sol";


contract OpenControllerTest is Test {
  OpenControllerFactory factory;

  function setup() {
    factory = new OpenControllerFactory();
  }

  function test_something() {
    assertEq(uint(1), uint(1));
  }
}
