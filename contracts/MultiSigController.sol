pragma solidity 0.4.15;

import "Controller.sol";
import "MembershipRegistry.sol";
import "ControllerUtils.sol";

contract MultiSigController is Controller, ControllerUtils, MembershipRegistry {
    uint256 public required;
    uint256 public dailyLimit;
    string public constant name = "MultiSigController";
    string public constant version = "1.0";

    function changeVariables(uint256 _required, uint256 _dailyLimit) onlySelf {
      required = _required;
      dailyLimit = _dailyLimit;
    }

    function MultiSigController(address[] _members, uint256 _required, uint256 _dailyLimit) {
      for (uint256 m = 0; m < _members.length; m++) {
        addMember(_members[m]);
      }

      required = _required;
      dailyLimit = _dailyLimit;
      owner = msg.sender;
    }

    function canPropose(address _sender, uint256 _value, uint256 _proposalID) public constant returns (bool) {
        return isMember(_sender);
    }

    function canVote(address _sender, uint256 _value, uint256 _proposalID) public constant returns (bool)  {
        return isMember(_sender);
    }

    function canExecute(address _sender, uint256 _value, uint256 _proposalID) public constant returns (bool)  {
        return isMember(_sender) && hasWon(_sender, _value, _proposalID);
    }
 
    function votingWeightOf(address _sender, uint256 _value, uint256 _proposalID, uint256 _index, uint256 _data) public constant returns (uint256)  {
        return uint256(isMember(_sender));
    }
 
    // extra methods for UI
    function hasWon(address _sender, uint256 _value, uint256 _proposalID) public constant returns (bool) {
      for(uint256 c = executionOffset(msg.sender, 0, i);
          c < numDataOf(i);
          c += dataLengthOf(i, c) + 4) {
        uint256 voteYes = weightOf(_proposalID, 1);
        uint256 value = valueOf(_proposalID, c);
        address destination = destinationOf(_proposalID, c);
        bool safeDestination = isSafeDestination(destination);
        bool isNoBytecode = bool(signatureOf(_proposalID, c) == bytes4(0));

        return ((value + valueWithdrawnLast24Hours()) <= dailyLimit && safeDestination && isNoBytecode) || voteYes >= required;
      }
    }

    // is the tx sending to the rules or board contracts
    function isSafeDestination(address _destination) public constant returns (bool) {
      return (_destination != address(this) && _destination != address(board));
    }

    // return the value widthrawn within the last 24 hours
    function valueWithdrawnLast24Hours() public constant returns (uint256 valueWithdrawn) {
      uint256 numProposals = numProposals();
      uint256 oneDayAgo = now - 24 hours;
      if (numProposals == 0) return 0;

      for (uint256 i = numProposals - 1; i > 0; i--) {
        for(uint256 c = executionOffset(msg.sender, 0, i);
            c < numDataOf(i);
            c += dataLengthOf(i, c) + 4) {
          uint256 executedAt = executionTimeOf(i);

          if (executedAt > oneDayAgo) {
            valueWithdrawn += valueOf(i);
          }

          if ((executedAt != 0 && executedAt < oneDayAgo) || i == 0) {
            return valueWithdrawn;
          }
        }
      }
    }
}
