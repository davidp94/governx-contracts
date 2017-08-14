pragma solidity 0.4.15;

import "lib/Proxy.sol";
import "lib/PrivateServiceRegistry.sol";
import "OpenController.sol";

contract OpenControllerFactory is PrivateServiceRegistry {
    function createProxy() public returns (address) {
      Proxy proxy = new Proxy();
      proxy.transfer(new OpenController(proxy));
      register(proxy);
      return address(proxy);
    }

    function createController(address _proxy) public returns (address service) {
      service = address(new OpenController(_proxy));
      register(service);
    }
}
