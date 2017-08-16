pragma solidity 0.4.15;

import "lib/Controller.sol";

contract FutarchyOracle {
    function getOutcome() public constant returns (int);
}

contract FutarchyOracleFactory {
  function createFutarchyOracle(
    Token collateralToken,
    Oracle oracle,
    uint8 outcomeCount,
    int lowerBound,
    int upperBound,
    MarketFactory marketFactory,
    MarketMaker marketMaker,
    uint24 fee,
    uint deadline) 
    public
    returns (FutarchyOracle futarchyOracle)
}

contract FutarchyController is Controller, MembershipRegistry {
    string public constant name = "FutarchyController";
    string public constant version = "1.0";
    FutarchyOracleFactory public factory;
    mapping(uint256 => FutarchyOracle) public oracles;
    
    function FutarchyController(address _proxy, address[] _members, FutarchyOracleFactory _factory) {
      setProxy(_proxy);
      factory = _factory;
      for (uint256 m = 0; m < _members.length; m++)
        addMember(_members[m]);
    }
    
    function newProposal(string _metadata, bytes32[] _data) public hasMoment(numProposals) canPropose returns (uint proposalID) {
        proposalID = numProposals++;
        proposals[proposalID].metadata = _metadata;
        proposals[proposalID].data = _data;
        oracles[proposalID] = factory.createFutarchyOracle(
          Token(_data[0]);
          Oracle(_data[1]);
          uint8(_data[2]),
          int(_data[3]),
          int(_data[4]),
          MarketFactory(_data[5]),
          MarketMaker(_data[6]),
          uint24(_data[7]),
          uint(_data[8])
        );
    }

    function canPropose(address _sender, uint256 _proposalID) public constant returns (bool) {
        return isMember(_sender);
    }

    function canExecute(address _sender, uint256 _proposalID) public constant returns (bool)  {
        return isMember(_sender) && oracles[_proposalID].getOutcome() == int(1);
    }
    
    function executionOffset(address _sender, uint256 _proposalID) public constant returns (uint256) {
        return 9;
    }
}
