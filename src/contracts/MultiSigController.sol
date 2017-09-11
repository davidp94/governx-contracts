pragma solidity ^0.4.16;

import "utils/ControllerExtended.sol";
import "utils/MembershipRegistry.sol";


contract MultiSigController is ControllerExtended, MembershipRegistry {
    uint256 public required;
    uint256 public dailyLimit;

    string public constant name = "MultiSigController";
    string public constant version = "1.0";

    function MultiSigController(address _proxy, address[] _members, uint256 _required, uint256 _dailyLimit) {
      for (uint256 m = 0; m < _members.length; m++)
        addMember(_members[m]);

      required = _required;
      dailyLimit = _dailyLimit;
      setProxy(_proxy);
    }

    function changeVariables(uint256 _required, uint256 _dailyLimit) onlyProxy {
      required = _required;
      dailyLimit = _dailyLimit;
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

    // extra methods for UI
    function hasWon(address _sender, uint256 _proposalID) public constant returns (bool) {
      for(uint256 c;
          c < numDataOf(_proposalID);
          c += lengthOf(_proposalID, c) + (20 + 32 + 32)) { // addr, uint, uint
        uint256 voteYes = weightOf(_proposalID, 1);
        uint256 value = valueOf(_proposalID, c);
        address destination = destinationOf(_proposalID, c);
        bool safeDestination = isSafeDestination(destination);
        bool isNoBytecode = bool(lengthOf(_proposalID, c) == 0);

        return ((value + valueWithdrawnLast24Hours()) <= dailyLimit && safeDestination && isNoBytecode) || voteYes >= required;
      }
    }

    // is the tx sending to the rules or board contracts
    function isSafeDestination(address _destination) public constant returns (bool) {
      return (_destination != address(this));
    }

    // return the value widthrawn within the last 24 hours
    function valueWithdrawnLast24Hours() public constant returns (uint256 valueWithdrawn) {
      uint256 oneDayAgo = now - 24 hours;
      if (numProposals == 0) return 0;

      for (uint256 i = numProposals - 1; i > 0; i--) {
        for(uint256 c = 0;
            c < numDataOf(i);
            c += lengthOf(i, c) + (20 + 32 + 32)) {
          uint256 executedAt = executionTimeOf(i);

          if (executedAt > oneDayAgo) {
            valueWithdrawn += valueOf(i, c);
          }

          if ((executedAt != 0 && executedAt < oneDayAgo) || i == 0) {
            return valueWithdrawn;
          }
        }
      }
    }
}
