pragma solidity 0.4.15;

contract Rules {
    function canPropose(address _sender, uint256 _value, uint256 _proposalID) public constant returns (bool);
    function canVote(address _sender, uint256 _value, uint256 _proposalID) public constant returns (bool);
    function canExecute(address _sender, uint256 _value, uint256 _proposalID) public constant returns (bool);
    function votingWeightOf(address _sender, uint256 _value, uint256 _proposalID, uint256 _index, uint256 _data) public constant returns (uint256);
    function voteOffset(address _sender, uint256 _value, uint256 _proposalID) public constant returns (uint256);
    function executionOffset(address _sender, uint256 _value, uint256 _proposalID) public constant returns (uint256);
}
