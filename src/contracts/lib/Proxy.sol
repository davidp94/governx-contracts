pragma solidity ^0.4.15;

import "lib/IProxy.sol";
import "lib/Owned.sol";


contract Proxy is IProxy, Owned {
    function () public payable { Received(msg.sender, msg.value); }

    function forward(address destination, uint value, bytes data) public onlyOwner {
        require(destination.call.value(value)(data));
        Forwarded(destination, value, data);
    }

    function transfer(address _owner) public {
      require(msg.sender == address(this) || msg.sender == _owner);
      owner = _owner;
    }
}
