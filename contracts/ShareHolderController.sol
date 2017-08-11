pragma solidity 0.4.15;

import "IProxy.sol";
import "Controller.sol";
import "ControllerUtils.sol";

contract ShareHolderController is Controller, ControllerUtils {
  string public constant name = "ShareHolderController";
  string public constant version = "1.0";

  function ShareHolderController(address[] _tokens,
    uint256[] _ratios,
    address _electedBoard,
    address _proxy,
    uint256 _baseQuorum,
    uint256 _quorum,
    uint256 _debatePeriod,
    uint256 _votingPeriod,
    uint256 _gracePeriod,
    uint256 _executionPeriod) {
    tokens = _tokens;
    ratios = _ratios;
    electedBoard = _electedBoard;
    proxy = IProxy(_proxy);
    baseQuorum = _baseQuorum;
    quorum = _quorum;
    debatePeriod = _debatePeriod;
    votingPeriod = _votingPeriod;
    gracePeriod = _gracePeriod;
    executionPeriod = _executionPeriod;
  }

  function changeVariables(address[] _tokens,
    uint256[] _ratios,
    address _electedBoard,
    address _proxy,
    uint256 _baseQuorum,
    uint256 _quorum,
    uint256 _debatePeriod,
    uint256 _votingPeriod,
    uint256 _gracePeriod,
    uint256 _executionPeriod) public onlyProxy {
    tokens = _tokens;
    ratios = _ratios;
    electedBoard = _electedBoard;
    proxy = IProxy(_proxy);
    baseQuorum = _baseQuorum;
    quorum = _quorum;
    debatePeriod = _debatePeriod;
    votingPeriod = _votingPeriod;
    gracePeriod = _gracePeriod;
    executionPeriod = _executionPeriod;
  }
  
  function shareHolderBalanceOfAtTime(address _sender, uint256 _time) public constant returns (uint256 balance) {
    for (uint256 i = 0; i < tokens.length; i++)
      balance += IMiniMeToken(tokens[i]).balanceOf(_sender, _time) / ratios[i];
  }
  
  function totalTokenSupply() public constant returns (uint256 totalSupply) {
    for (uint256 i = 0; i < tokens.length; i++)
      totalSupply += IMiniMeToken(tokens[i]).totalSupply();
  }

  function minimumQuorum() public constant returns (uint256) {
    return totalTokenSupply() / baseQuorum;
  }

  function canPropose(address _sender, uint256 _proposalID) public constant returns (bool) {
    return shareHolderBalanceOfAtTime(_sender, block.timestamp) > 0;
  }

  function canVote(address _sender, uint256 _proposalID) public constant returns (bool)  {
    return (shareHolderBalanceOfAtTime(_sender, voteTime(_proposalID)) > 0 && !delegated[_sender][_proposalID]);
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
    uint256 balanceAtVoteTime = shareHolderBalanceOfAtTime(_sender, voteTime(_proposalID));
    
    if(balanceAtVoteTime > 0 && !hasVoted(_proposalID, _sender) && !delegated[_sender][_proposalID])
      return balanceAtVoteTime + delegationWeight[_sender, _proposalID];
  }

  function hasWon(address _sender, uint256 _value, uint256 _proposalID) public constant returns (bool)  {
    return (weightOf(_proposalID, 0) > minimumQuorum()) && !hasVoted(_proposalID, _curator);
  }
  
  // delegation happens once and during the vote period
  function delegate(address _to, uint256 _proposalID) public {
    if (hasVoted(_proposalID, msg.sender) && !delegated[msg.sender][_proposalID]) throw;
    delegated[msg.sender][_proposalID] = true;
    delegationWeight[_to][_proposalID] += shareHolderBalanceOfAtTime(msg.sender, voteTime(_proposalID)) + delegationWeight[msg.sender][_proposalID];
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

  address public electedBoard;
  uint256[] public ratios;
  address[] public tokens;
}
