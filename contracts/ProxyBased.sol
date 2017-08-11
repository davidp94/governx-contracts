pragma solidity 0.4.15;

import "IProxy.sol";


contract ProxyBased {
    modifier onlyProxy { if (msg.sender == address(proxy)) _; }

    IProxy public proxy;
}
