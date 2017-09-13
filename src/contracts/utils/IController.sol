pragma solidity 0.4.16;

// the interface for our default controller design
contract IController {
    function newProposal(string _metadata, bytes _data) public payable returns (uint proposalID);
    function vote(uint256 _proposalID, bytes32[] _data) public payable;
    function execute(uint256 _proposalID) public payable;
}
