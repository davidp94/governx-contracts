pragma solidity 0.4.15;

import "IController.sol";

contract ControllerUtils {
    function proxyOf(uint256 _proposalID, uint256 _c) constant returns (address) {
        return address(IController(this).dataOf(_proposalID, _c));
    }

    function destinationOf(uint256 _proposalID, uint256 _c) constant returns (address) {
        return address(IController(this).dataOf(_proposalID, _c + 1));
    }
    
    function valueOf(uint256 _proposalID, uint256 _c) constant returns (uint256) {
        return uint256(IController(this).dataOf(_proposalID, _c + 2));
    }
    
    function dataLengthOf(uint256 _proposalID, uint256 _c) constant returns (uint256) {
        return uint256(IController(this).dataOf(_proposalID, _c + 3));
    }
    
    function signatureOf(uint256 _proposalID, uint256 _c) constant returns (bytes4) {
        return bytes4(IController(this).dataOf(_proposalID, _c + 4));
    }
    
    function latestSenderOf(uint256 _proposalID) constant returns (address) {
        return IController(this).momentSenderOf(_proposalID, IController(this).numMomentsOf(_proposalID) - 1);
    }
    
    function executionTimeOf(uint256 _proposalID) constant returns (uint256) {
        if (IController(this).hasExecuted(_proposalID))
            return IController(this).momentTimeOf(_proposalID, IController(this).numMomentsOf(_proposalID) - 1);
    }

    function executionBlockOf(uint256 _proposalID) constant returns (uint256) {
        if (IController(this).hasExecuted(_proposalID))
            return IController(this).momentBlockOf(_proposalID, IController(this).numMomentsOf(_proposalID) - 1);
    }
}
