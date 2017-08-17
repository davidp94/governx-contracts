pragma solidity ^0.4.15;

import "lib/Proposable.sol";
import "lib/DefaultRules.sol";
import "lib/ProxyBased.sol";


contract Controller is ProxyBased, Proposable, DefaultRules {
    modifier shouldPropose { _; require(canPropose(msg.sender, numProposals - 1)); }
    modifier shouldVote (uint256 _proposalID) { _; require(canVote(msg.sender, _proposalID)); }
    modifier shouldExecute (uint256 _proposalID) { require(canExecute(msg.sender, _proposalID)); _; }
    modifier transferFunds { if (msg.value > 0) { require(proxy.send(msg.value)); } _; }

    function newProposal(string _metadata, bytes32[] _data) public payable transferFunds hasMoment(numProposals) shouldPropose returns (uint proposalID) {
        proposalID = numProposals++;
        proposals[proposalID].metadata = _metadata;
        proposals[proposalID].data = _data;
    }

    function vote(uint256 _proposalID, bytes32[] _data) public payable transferFunds hasMoment(_proposalID) shouldVote(_proposalID) {
        proposals[_proposalID].votes[proposals[_proposalID].moments.length] = _data;
        for(uint256 i = voteOffset(msg.sender, _proposalID); i < _data.length; i++)
            proposals[_proposalID].weights[i] += votingWeightOf(msg.sender, _proposalID, i, uint256(_data[i]));
    }

    function execute(uint256 _proposalID) public payable transferFunds hasMoment(_proposalID) shouldExecute(_proposalID) {
        require(!proposals[_proposalID].executed);
        bytes32[] storage data = proposals[_proposalID].data;
        proposals[_proposalID].executed = true;
        for(uint256 c = executionOffset(msg.sender, _proposalID); c < data.length; c += uint256(data[c + 2]) + 3)
            proxy.forward(address(data[c]), uint256(data[c + 1]), calldata(_proposalID, c + 3, uint256(data[c + 2])));
    }

    function calldata(uint256 _proposalID, uint256 _start, uint256 _length) public constant returns (bytes) {
        bytes32[] storage data = proposals[_proposalID].data;
        bytes memory memoryBytes = new bytes((_length - 1) * 32 + 4);
        assembly {
            mstore(0x0, data_slot)
            let storageKey := sha3(0x0, 0x20)
            mstore(add(memoryBytes, 0x20), sload(add(storageKey, _start)))
            for {let i := 0}  lt(i, sub(_length, 1)) {i := add(i, 1)} {
                mstore(add(add(memoryBytes, 0x24), mul(0x20, i)), sload(add(storageKey, add(add(_start, 1), i))))
            }
        }
        return memoryBytes;
    }

    event Received(address _sender, uint256 _value);
}
