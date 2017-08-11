pragma solidity 0.4.15;

import "Controller.sol";
import "Owned.sol";

contract OwnedController is Owned, Controller {
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
