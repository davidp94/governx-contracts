pragma solidity 0.4.15;

import "IRules.sol";
import "IProxy.sol";
import "Proposable.sol";
import "DefaultRules.sol";

contract Controller is Proposable, Proxy, DefaultRules {
    modifier onlySelf { if (msg.sender == address(this)) _; }
    modifier canPropose { _; if (!canPropose(msg.sender, msg.value, numProposals - 1)) throw; }
    modifier canVote (uint256 _proposalID) { _; if(!canVote(msg.sender, msg.value, _proposalID)) throw; }
    modifier canExecute (uint256 _proposalID) { if (canExecute(msg.sender, msg.value, _proposalID)) _; }

    function () public payable { Received(msg.sender, msg.value); }

    function forward(address _destination, uint _value, bytes _data) public onlySelf {
        if (!_destination.call.value(_value)(_data)) throw;
        Forwarded(_destination, _value, _data);
    }

    function newProposal(string _metadata, bytes32[] _data) public hasMoment(numProposals) canPropose payable returns (uint proposalID) {
        proposalID = numProposals++;
        proposals[proposalID].metadata = _metadata;
        proposals[proposalID].data = _data;
    }

    function vote(uint256 _proposalID, bytes32[] _data) public hasMoment(_proposalID) canVote(_proposalID) payable {
        proposals[_proposalID].votes[proposals[_proposalID].moments.length] = _data;
        for(uint256 i = voteOffset(msg.sender, msg.value, _proposalID); i < _data.length; i++)
            proposals[_proposalID].weights[i] += rules.votingWeightOf(msg.sender, msg.value, _proposalID, i, uint256(_data[i]));
    }

    function execute(uint256 _proposalID) public hasMoment(_proposalID) canExecute(_proposalID) payable {
        if (proposals[_proposalID].executed) throw;
        bytes32[] storage data = proposals[_proposalID].data;
        proposals[_proposalID].executed = true;
        for(uint256 c = executionOffset(msg.sender, msg.value, _proposalID); c < data.length; c += uint256(data[c + 3]) + 4)
            Proxy(address(data[c])).forward(address(data[c + 1]), uint256(data[c + 2]), calldata(_proposalID, c + 4, uint256(data[c + 3])));
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
}
