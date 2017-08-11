pragma solidity 0.4.15;

import "IProxy.sol";
import "Proposable.sol";
import "DefaultRules.sol";

contract ProxyBased {
    modifier onlyProxy { if (msg.sender == address(proxy)) _; }

    IProxy public proxy;
}

contract Controller is ProxyBased, Proposable, DefaultRules {
    modifier canPropose { _; if (!canPropose(msg.sender, numProposals - 1)) throw; }
    modifier canVote (uint256 _proposalID) { _; if(!canVote(msg.sender, _proposalID)) throw; }
    modifier canExecute (uint256 _proposalID) { if (canExecute(msg.sender, _proposalID)) _; }
    modifier transferFunds { if (msg.value > 0) { if (!proxy.send(msg.value)) throw; } _; }

    function newProposal(string _metadata, bytes32[] _data) public payable transferFunds hasMoment(numProposals) canPropose returns (uint proposalID) {
        proposalID = numProposals++;
        proposals[proposalID].metadata = _metadata;
        proposals[proposalID].data = _data;
    }

    function vote(uint256 _proposalID, bytes32[] _data) public payable transferFunds hasMoment(_proposalID) canVote(_proposalID) {
        proposals[_proposalID].votes[proposals[_proposalID].moments.length] = _data;
        for(uint256 i = voteOffset(msg.sender, _proposalID); i < _data.length; i++)
            proposals[_proposalID].weights[i] += rules.votingWeightOf(msg.sender, msg.value, _proposalID, i, uint256(_data[i]));
    }

    function execute(uint256 _proposalID) public payable transferFunds hasMoment(_proposalID) canExecute(_proposalID) {
        if (proposals[_proposalID].executed) throw;
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
