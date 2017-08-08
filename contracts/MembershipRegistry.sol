pragma solidity 0.4.15;

import "Owned.sol";

contract MembershipRegistry is Owned {
    string public constant version = "MemberRegistry.0.0.1";
    uint256 public numMembers;
    uint256 public numActiveMembers;
    mapping(uint256 => address) public members;
    mapping(address => uint256) public ids;
    
    function add(address _member) public onlyOwner {
        if (isMember(_member)) throw;
        ids[_member] = numMembers++;
        members[ids[_member]] = _member;
        numActiveMembers++;
    }
    
    function remove(address _member) public onlyOwner {
        if (!isMember(_member)) throw;
        members[ids[_member]] = address(0);
        ids[_member] = 0;
        numActiveMembers--;
    }
    
    function isMember(address _member) public constant returns (bool) {
        return (members[ids[_member]] == _member && _member != address(0));
    }
}
