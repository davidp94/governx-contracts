pragma solidity 0.4.15;

import "Controller.sol";

contract OpenController is Controller {
    function canPropose(address _sender, uint256 _proposalID) public constant returns (bool) {
        return true;
    }

    function canVote(address _sender, uint256 _proposalID) public constant returns (bool)  {
        return true;
    }

    function canExecute(address _sender, uint256 _proposalID) public constant returns (bool)  {
        return true;
    }
 
    function votingWeightOf(address _sender, uint256 _proposalID, uint256 _index, uint256 _data) public constant returns (uint256)  {
        return 1;
    }
}
