pragma solidity 0.4.15;

import "lib/Controller.sol";
import "lib/Owned.sol";

contract OwnedController is Owned, Controller {
    string public constant name = "OwnedController";
    string public constant version = "1.0";

    function OwnedController(address _proxy, address _owner) {
      setProxy(_proxy);
      owner = _owner;
    }

    function canPropose(address _sender, uint256 _proposalID) public constant returns (bool) {
        return isOwner(_sender);
    }

    function canVote(address _sender, uint256 _proposalID) public constant returns (bool)  {
        return isOwner(_sender);
    }

    function canExecute(address _sender, uint256 _proposalID) public constant returns (bool)  {
        return isOwner(_sender);
    }

    function votingWeightOf(address _sender, uint256 _proposalID, uint256 _index, uint256 _data) public constant returns (uint256)  {
        return uint256(isOwner(_sender));
    }
}
