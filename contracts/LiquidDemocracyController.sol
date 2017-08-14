pragma solidity 0.4.15;

import "Controller.sol";
import "IMiniMeToken.sol";

contract LiquidDemocracyController is Controller {
  function LiquidDemocracyController(address _proxy,
    address _token,
    address _curator,
    uint256 _baseQuorum,
    uint256 _quorum,
    uint256 _debatePeriod,
    uint256 _votingPeriod,
    uint256 _gracePeriod,
    uint256 _executionPeriod) {
    token = IMiniMeToken(_token);
    curator = _curator;
    baseQuorum = _baseQuorum;
    quorum = _quorum;
    debatePeriod = _debatePeriod;
    votingPeriod = _votingPeriod;
    gracePeriod = _gracePeriod;
    executionPeriod = _executionPeriod;
    setProxy(_proxy);
  }

  function changeRules(
    uint256 _baseQuorum,
    uint256 _quorum,
    uint256 _debatePeriod,
    uint256 _votingPeriod,
    uint256 _gracePeriod,
    uint256 _executionPeriod) public onlyProxy {
    baseQuorum = _baseQuorum;
    quorum = _quorum;
    debatePeriod = _debatePeriod;
    votingPeriod = _votingPeriod;
    gracePeriod = _gracePeriod;
    executionPeriod = _executionPeriod;
  }

  function minimumQuorum() public constant returns (uint256) {
    return token.totalSupply() / baseQuorum;
  }

  function canPropose(address _sender, uint256 _proposalID) public constant returns (bool) {
    return balanceOf(_sender) > 0;
  }

  function canVote(address _sender, uint256 _proposalID) public constant returns (bool)  {
    return (balanceOfAtTime(_sender, voteTime(_proposalID)) > 0 && !delegated[_sender][_proposalID]) || _sender == curator;
  }

  function canExecute(address _sender, uint256 _proposalID) public constant returns (bool)  {
    return hasWon(_sender, _value, _proposalID)
      && (block.timestamp < (momentTimeOf(_proposalID, 0) + debatePeriod + votingPeriod + gracePeriod + executionPeriod))
      && (block.timestamp > (momentTimeOf(_proposalID, 0) + debatePeriod + votingPeriod + gracePeriod)));
  }
  
  function voteTime(uint256 _proposalID) public constant returns (uint256) {
    return momentTimeOf(_proposalID, 0) + debatePeriod + votingPeriod;
  }

  function votingWeightOf(address _sender, uint256 _proposalID, uint256 _index, uint256 _data) public constant returns (uint256)  {
    uint256 balanceAtVoteTime = balanceOfAtTime(_sender, voteTime(_proposalID));
    
    if(balanceAtVoteTime > 0 && !hasVoted(_proposalID, _sender) && !delegated[_sender][_proposalID])
      return balanceAtVoteTime + delegationWeight[_sender, _proposalID];
  }

  function hasWon(address _sender, uint256 _value, uint256 _proposalID) public constant returns (bool)  {
    return (weightOf(_proposalID, 1) > minimumQuorum()) && !hasVoted(_proposalID, _curator);
  }
  
  // delegation happens once and during the vote period
  function delegate(address _to, uint256 _proposalID) public {
    if (hasVoted(_proposalID, msg.sender) && !delegated[msg.sender][_proposalID]) throw;
    delegated[msg.sender][_proposalID] = true;
    delegationWeight[_to][_proposalID] += balanceOfAtTime(msg.sender, voteTime(_proposalID)) + delegationWeight[msg.sender][_proposalID];
  }

  uint256 public majority;
  uint256 public baseQourum;
  uint256 public quorum;
  uint256 public debatePeriod;
  uint256 public votingPeriod;
  uint256 public gracePeriod;
  uint256 public executionPeriod;
  
  mapping(address => mapping(uint256 => bool)) public delegated;
  mapping(address => mapping(uint256 => uint256)) public delegationWeight;
  mapping(uint256 => bool) public notAllowed;
  
  address public curator;
  IMiniMeToken public token;
}
