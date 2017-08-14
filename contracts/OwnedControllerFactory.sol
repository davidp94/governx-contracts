pragma solidity 0.4.15;

import "lib/Proxy.sol";
import "lib/PrivateServiceRegistry.sol";
import "OwnedController.sol";

contract OwnedControllerFactory is PrivateServiceRegistry {
    function createProxy(address _owner) public returns (address) {
      Proxy proxy = new Proxy();
      proxy.transfer(new OwnedController(proxy, _owner));
      register(proxy);
      return address(proxy);
    }

    function createController(address _proxy, address _owner) public returns (address service) {
      service = address(new OwnedController(proxy, _owner));
      register(service);
    }
}
