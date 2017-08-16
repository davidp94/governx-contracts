pragma solidity 0.4.15;

import "lib/Proxy.sol";
import "lib/PrivateServiceRegistry.sol";
import "lib/MiniMeToken.sol";
import "LiquidDemocracyController.sol";

contract LiquidDemocracyController is PrivateServiceRegistry {
    function createProxy(
      address _token,
      address _curator,
      uint256 _baseQuorum,
      uint256 _debatePeriod,
      uint256 _votingPeriod,
      uint256 _gracePeriod,
      uint256 _executionPeriod,
      address _tokenFactory,
      address _parent,
      uint256 _snapShotBlock,
      string _tokenName,
      uint8 _decimalUnits,
      string _tokenSymbol,
      bool _transfersEnabled
      ) public returns (address) {
      Proxy proxy = new Proxy();

      // create token
      address token = _token;
      if (_token == address(0)) {
        token = address(new MiniMeToken(
            _tokenFactory,
            _parent,
            _snapShotBlock,
            _tokenName,
            _decimalUnits,
            _tokenSymbol,
            _transfersEnabled));
      }

      // create controller
      proxy.transfer(new LiquidDemocracyController(
        proxy,
        token,
        _curator,
        _baseQuorum,
        _debatePeriod,
        _votingPeriod,
        _gracePeriod,
        _executionPeriod));
      register(proxy);
      return address(proxy);
    }

    function createController(
      address _proxy,
      address _token,
      address _curator,
      uint256 _baseQuorum,
      uint256 _debatePeriod,
      uint256 _votingPeriod,
      uint256 _gracePeriod,
      uint256 _executionPeriod) public returns (address service) {
      service = address(new LiquidDemocracyController(
        proxy,
        _token,
        _curator,
        _baseQuorum,
        _debatePeriod,
        _votingPeriod,
        _gracePeriod,
        _executionPeriod));
      register(service);
    }
}
