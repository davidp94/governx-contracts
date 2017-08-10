pragma solidity 0.4.15;

contract ControllerUtils is Controller {
    function proxyOf(uint256 _proposalID, uint256 _c) constant returns (address) {
        return address(dataOf(_proposalID, _c));
    }

    function destinationOf(uint256 _proposalID, uint256 _c) constant returns (address) {
        return address(dataOf(_proposalID, _c + 1));
    }
    
    function valueOf(uint256 _proposalID, uint256 _c) constant returns (uint256) {
        return uint256(dataOf(_proposalID, _c + 2));
    }
    
    function dataLengthOf(uint256 _proposalID, uint256 _c) constant returns (uint256) {
        return uint256(dataOf(_proposalID, _c + 3));
    }
    
    function signatureOf(uint256 _proposalID, uint256 _c) constant returns (bytes4) {
        return bytes4(dataOf(_proposalID, _c + 4));
    }
    
    function latestSenderOf(uint256 _proposalID) constant returns (address) {
        return momentSenderOf(_proposalID, numMomentsOf(_proposalID) - 1);
    }
    
    function executionTimeOf(uint256 _proposalID) constant returns (uint256) {
        if (hasExecuted(_proposalID)) return momentTimeOf(_proposalID, numMomentsOf(_proposalID) - 1);
    }

    function executionBlockOf(uint256 _proposalID) constant returns (uint256) {
        if (hasExecuted(_proposalID)) return momentBlockOf(_proposalID, numMomentsOf(_proposalID) - 1);
    }
}
