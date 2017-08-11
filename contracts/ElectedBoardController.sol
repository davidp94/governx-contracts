pragma solidity 0.4.15;

import "MultiSigController.sol";
import "ControllerUtils.sol";

contract ElectedBoardController is MultiSigController, ControllerUtils {
  string public constant name = "ElectedBoardController";
  string public constant version = "1.0";

  modifier onlyElectorate { if (msg.sender == _electorate) _; }

  function ElectedBoardController(address[] _members, uint256 _required, uint256 _dailyLimit, address _electorate) {
    for (uint256 m = 0; m < _members.length; m++) {
      addMember(_members[m]);
    }

    electorate = _electorate;
    required = _required;
    dailyLimit = _dailyLimit;
  }
  
  function changeVariables(uint256 _required, uint256 _dailyLimit) onlyElectorate {
    parent.changeVariables(_required, _dailyLimit);
  }

  function changeElectorate(address _electorate) onlyElectorate {
    electorate = _electorate;
  }
  
  function add(address _member) public onlyElectorate {
    super.add(_member);
  }
  
  function remove(address _member) public onlyElectorate {
    super.remove(_member);
  }
 
  address public electorate;
}
