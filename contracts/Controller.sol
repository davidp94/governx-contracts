pragma solidity 0.4.15;

import "IRules.sol";
import "IProxy.sol";

contract Proposable {
    modifier hasMoment (uint256 _proposalID) { recordMoment(_proposalID); _; }

    struct Moment {
        address sender;
        uint256 nonce;
        uint256 time;
        uint256 value;
        uint256 block;
    }

    struct Proposal {
        bool executed;
        mapping(uint256 => uint256) weights;
        mapping(address => uint256) latest;
        mapping(uint256 => bytes32[]) votes;
        string metadata;
        Moment[] moments;
        bytes32[] data;
    }

    function recordMoment(uint256 _proposalID) internal {
        proposals[_proposalID].latest[msg.sender] = proposals[_proposalID].moments.length;
        ProposalMoment(msg.sender, proposals[_proposalID].latest[msg.sender], _proposalID);
        proposals[_proposalID].moments.push(Moment({
            sender: msg.sender,
            value: msg.value,
            time: block.timestamp,
            block: block.number,
            nonce: nonces[msg.sender]++
        }));
    }

    function hasVoted(uint256 _pid, address _sender) public constant returns (bool) {
        return (proposals[_pid].latest[_sender] > 0);
    }
    function numMomentsOf(uint256 _pid) public constant returns (uint256) { return proposals[_pid].moments.length; }
    function momentSenderOf(uint256 _pid, uint256 _mid) public constant returns (address) { return proposals[_pid].moments[_mid].sender; }
    function momentValueOf(uint256 _pid, uint256 _mid) public constant returns (uint256) { return proposals[_pid].moments[_mid].value; }
    function momenTimeOf(uint256 _pid, uint256 _mid) public constant returns (uint256) { return proposals[_pid].moments[_mid].time; }
    function momentBlockOf(uint256 _pid, uint256 _mid) public constant returns (uint256) { return proposals[_pid].moments[_mid].block; }
    function momentNonceOf(uint256 _pid, uint256 _mid) public constant returns (uint256) { return proposals[_pid].moments[_mid].nonce; }
    function weightOf(uint256 _proposalID, uint256 _position) public constant returns (uint256) {
        return proposals[_proposalID].weights[_position];
    }
    function voteOf(uint256 _pid, uint256 _mid, uint256 _index) public constant returns (bytes32) { return proposals[_pid].votes[_mid][_index]; }
    function hasExecuted(uint _proposalID) public constant returns (bool) { return proposals[_proposalID].executed; }
    function metadataOf(uint256 _proposalID) public constant returns (string) { return proposals[_proposalID].metadata; }
    function numDataOf(uint256 _proposalID) public constant returns (uint256) { return proposals[_proposalID].data.length; }
    function dataOf(uint256 _proposalID, uint256 _index) public constant returns (bytes32) {
        return proposals[_proposalID].data[_index];
    }

    event ProposalMoment(address _sender, uint256 _momentID, uint256 _proposalID);
    
    uint256 public numProposals;
    mapping(address => uint256) public nonces;
    mapping(uint256 => Proposal) public proposals;
}

contract Controller is Proposable, Proxy {
    modifier onlySelf { if (msg.sender == address(this)) _; }
    modifier canPropose { _; if (!rules.canPropose(msg.sender, msg.value, numProposals - 1)) throw; }
    modifier canVote (uint256 _proposalID) { _; if(!rules.canVote(msg.sender, msg.value, _proposalID)) throw; }
    modifier canExecute (uint256 _proposalID) { if (rules.canExecute(msg.sender, msg.value, _proposalID)) _; }

    function Controller(address _rules) public { rules = Rules(_rules); }
    function changeRules(address _rules) public onlySelf payable { rules = Rules(_rules); }
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
        for(uint256 i = rules.voteOffset(msg.sender, msg.value, _proposalID); i < _data.length; i++)
            proposals[_proposalID].weights[i] += rules.votingWeightOf(msg.sender, msg.value, _proposalID, i, uint256(_data[i]));
    }

    function execute(uint256 _proposalID) public hasMoment(_proposalID) canExecute(_proposalID) payable {
        if (proposals[_proposalID].executed) throw;
        bytes32[] storage data = proposals[_proposalID].data;
        proposals[_proposalID].executed = true;
        for(uint256 c = rules.executionOffset(msg.sender, msg.value, _proposalID); c < data.length; c += uint256(data[c + 3]) + 4)
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

    Rules public rules;
}
