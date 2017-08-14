pragma solidity 0.4.15;

import "lib/ProxyBased.sol";


contract MembershipRegistry is ProxyBased {
    uint256 public numMembers;
    uint256 public numActiveMembers;
    mapping(uint256 => address) public members;
    mapping(address => uint256) public ids;

    function add(address _member) public onlyProxy {
        if (isMember(_member)) throw;
        ids[_member] = numMembers++;
        members[ids[_member]] = _member;
        numActiveMembers++;
    }

    function remove(address _member) public onlyProxy {
        if (!isMember(_member)) throw;
        members[ids[_member]] = address(0);
        ids[_member] = 0;
        numActiveMembers--;
    }

    function transferAddress(address _addr) public {
        if (!isMember(msg.sender)) throw;
        members[ids[msg.sender]] == _addr;
        ids[_addr] = ids[msg.sender];
        ids[msg.sender] = 0;
    }

    function isMember(address _member) public constant returns (bool) {
        return (members[ids[_member]] == _member && _member != address(0));
    }
}
