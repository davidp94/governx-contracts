pragma solidity ^0.4.15;

import "Controller.sol";
import "MembershipRegistry.sol";

contract AuthorityController is Controller, MembershipRegistry {
  modifier onlyAuthority() {
    if (msg.sender != authority) { throw; }

    _;
  }

  function AuthorityController(address[] _members, uint256 _minimumQuorum, uint256 _required, address _authority) {
    for (uint m = 0; m < _members.length; m++) {
      addMember(_members[m]);
    }

    authority = _authority;
    required = _required;
    minimumQuorum = _minimumQuorum;
  }

  function changeVariables(uint256 _required, uint256 _minimumQuorum) onlySelf {
    required = _required;
    minimumQuorum = _minimumQuorum;
  }

  function canPropose(address _sender, uint256 _proposalID) public constant returns (bool) {
      return isMember(_sender);
  }

  function canVote(address _sender, uint256 _proposalID) public constant returns (bool)  {
      return isMember(_sender);
  }

  function canExecute(address _sender, uint256 _proposalID) public constant returns (bool)  {
      return isMember(_sender) && hasWon(_sender, _proposalID);
  }

  function votingWeightOf(address _sender, uint256 _proposalID, uint256 _index, uint256 _data) public constant returns (uint256)  {
    if (isMember(_sender))
      return 1;
  }

  // only authority can submit the votes
  function submitTally(uint256 _proposalID, uint256 _yesVotes, uint256 _totalVotes) onlyAuthority {
    if (yesVotes[_proposalID] == 0 && _yesVotes != 0 && voteSubmitted[_proposalID] == false) {
      voteSubmitted[_proposalID] = true;
      yesVotes[_proposalID] = _yesVotes;
      totalVotes[_proposalID] = _totalVotes;
    }
  }

  // extra methods for UI
  function hasWon(address _sender, uint256 _proposalID) public constant returns (bool) {
    uint256 quorum = totalVotes[_proposalID];
    uint256 totalYesVotes = yesVotes[_proposalID];

    return quorum >= minimumQuorum && totalYesVotes >= required;
  }

  function hasFailed(address _sender, uint256 _proposalID) public constant returns (bool) {
    return false;
  }

  mapping(uint256 => bool) public voteSubmitted;
  mapping(uint256 => uint256) public yesVotes;
  mapping(uint256 => uint256) public totalVotes;

  address public authority;
  uint256 public required;
  uint256 public minimumQuorum;
  string public constant name = "AuthorityController";
  string public constant version = "1.0";
}
