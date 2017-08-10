pragma solidity 0.4.15;

import "Controller.sol";
import "IMiniMeToken.sol";

contract CuratedLiquidDemocracyController is Controller {
  function CuratedLiquidDemocracyController(address _token,
    address _curator,
    uint256 _baseQourum,
    uint256 _qourum,
    uint256 _debatePeriod,
    uint256 _votingPeriod,
    uint256 _gracePeriod,
    uint256 _executionPeriod) {
    token = IMiniMeToken(_token);
    curator = _curator;
    changeRules(_baseQourum, _qourum, _debatePeriod, _votingPeriod, _gracePeriod, _executionPeriod);
  }

  function minimumQuorum() public constant returns (uint256) {
    // minimum of 12% and maximum of 24%
    return token.totalSupply() / baseQourum;
  }

  function changeRules(
    uint256 _baseQourum,
    uint256 _qourum,
    uint256 _debatePeriod,
    uint256 _votingPeriod,
    uint256 _gracePeriod,
    uint256 _executionPeriod) public onlySelf {
    baseQourum = _baseQourum;
    qourum = _qourum;
    debatePeriod = _debatePeriod;
    votingPeriod = _votingPeriod;
    gracePeriod = _gracePeriod;
    executionPeriod = _executionPeriod;
  }

  function canPropose(address _sender, uint256 _value, uint256 _proposalID) public constant returns (bool) {
    return balanceOf(_sender) > 0;
  }

  function canVote(address _sender, uint256 _value, uint256 _proposalID) public constant returns (bool)  {
    return balanceOfAtTime(_sender, voteTime(_proposalID)) > 0 && !delegated[_sender][_proposalID];
  }

  function canExecute(address _sender, uint256 _value, uint256 _proposalID) public constant returns (bool)  {
    return hasWon(_sender, _value, _proposalID)
      && (block.timestamp < (momentTimeOf(_proposalID, 0) + debatePeriod + votingPeriod + gracePeriod + executionPeriod))
      && (block.timestamp > (momentTimeOf(_proposalID, 0) + debatePeriod + votingPeriod + gracePeriod)));
  }
  
  function voteTime(uint256 _proposalID) public constant returns (uint256) {
    return momentTimeOf(_proposalID, 0) + debatePeriod + votingPeriod;
  }

  function votingWeightOf(address _sender, uint256 _value, uint256 _proposalID, uint256 _index, uint256 _data) public constant returns (uint256)  {
    uint256 balanceAtVoteTime = balanceOfAtTime(_sender, voteTime(_proposalID));
    
    if(balanceAtVoteTime > 0 && !hasVoted(_proposalID, _sender) && !delegated[_sender][_proposalID])
      return balanceAtVoteTime + delegationWeight[_sender, _proposalID];
  }

  function hasWon(address _sender, uint256 _value, uint256 _proposalID) public constant returns (bool)  {
    return (weightOf(_proposalID, 1) > minimumQuorum()) && !hasVoted(_proposalID, _curator);
  }
  
  // delegation happens during the vote period
  function delegate(address _to, uint256 _proposalID) public {
    if (hasVoted(_proposalID, msg.sender)) throw;
    delegated[msg.sender][_proposalID] = true;
    delegationWeight[_to][_proposalID] += balanceOfAtTime(_sender, voteTime(_proposalID));
  }

  uint256 public majority;
  uint256 public baseQourum;
  uint256 public qourum;
  uint256 public debatePeriod;
  uint256 public votingPeriod;
  uint256 public gracePeriod;
  uint256 public executionPeriod;
  
  mapping(address => mapping(uint256 => bool)) public delegated;
  mapping(address => mapping(uint256 => uint256)) public delegationWeight;
  
  address public curator;
  IMiniMeToken public token;
}
