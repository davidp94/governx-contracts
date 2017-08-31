pragma solidity ^0.4.15;

import "lib/IProxy.sol";
import "lib/Proxy.sol";
import "OpenController.sol";
import "wafr/Test.sol";


contract ControllerTest is Test {
  Proxy proxy;
  OpenController controller;
  uint256 testSet;

  function setup() {
    proxy = new Proxy();
    controller = new OpenController(proxy);
  }

  function setVal(uint256 _val) {
    testSet = _val;
  }

  bytes32[] arr;
  bytes32[] voteArr;

  function test_1_newProspoal_oneTx() {
    arr.push(bytes32(address(this)));
    arr.push(bytes32(0));
    arr.push(bytes32(uint256(2)));
    arr.push(bytes32(bytes4(sha3("setVal(uint256)"))));
    arr.push(bytes32(uint256(455)));
    controller.newProposal("Some prop", arr);
    uint256 _proposalID = 0;
    address _sender = msg.sender;
    uint256 _index = 0;
    uint256 _data = 0;
    uint256 _momentID = 0;

    assertEq(controller.hasVoted(_proposalID, _sender), false);
    assertEq(controller.numMomentsOf(_proposalID), uint256(1));
    assertEq(controller.momentSenderOf(_proposalID, _momentID), address(this));
    assertEq(controller.momentValueOf(_proposalID, _momentID), uint256(0));
    assertEq(controller.momentTimeOf(_proposalID, _momentID), uint256(block.timestamp));
    assertEq(controller.momentBlockOf(_proposalID, _momentID), uint256(block.number));
    assertEq(controller.momentNonceOf( _proposalID, _momentID), uint256(0));
    assertEq(controller.weightOf(_proposalID, uint256(0)), uint256(0));
    /* assertEq(controller.voteOf(_proposalID, _momentID, _index), bytes32(0));
*/
    assertEq(controller.hasExecuted(_proposalID), false);
    assertEq(controller.numDataOf(_proposalID), uint256(5));
    assertEq(controller.dataOf(_proposalID, 0), bytes32(address(this)));
    assertEq(controller.dataOf(_proposalID, 1), bytes32(0));
    assertEq(controller.dataOf(_proposalID, 2), bytes32(uint256(2)));
    assertEq(controller.dataOf(_proposalID, 3), bytes32(bytes4(sha3("setVal(uint256)"))));
    assertEq(controller.dataOf(_proposalID, 4), bytes32(uint256(455)));

    assertEq(controller.nonces(_sender), uint256(1));
    assertEq(controller.canPropose(_sender, _proposalID), true);
    assertEq(controller.canVote( _sender, _proposalID), true);
    assertEq(controller.canExecute( _sender, _proposalID), true);
    assertEq(controller.votingWeightOf( _sender, _proposalID, _index, _data), uint256(1));
    assertEq(controller.voteOffset( _sender, _proposalID), 0);
    assertEq(controller.executionOffset( _sender, _proposalID), 0);
  }

  function test_2_vote() {
    voteArr.push(bytes32(1));

    controller.vote(0, voteArr);

    uint256 _proposalID = 0;
    address _sender = msg.sender;
    uint256 _index = 0;
    uint256 _data = 0;
    uint256 _position = 0;
    uint256 _momentID = 1;

    assertEq(controller.hasVoted(_proposalID, _sender), false);
    assertEq(controller.numMomentsOf(_proposalID), uint256(2));
    assertEq(controller.momentSenderOf(_proposalID, _momentID), address(this));
    assertEq(controller.momentValueOf(_proposalID, _momentID), uint256(0));
    assertEq(controller.momentTimeOf(_proposalID, _momentID), uint256(block.timestamp));
    assertEq(controller.momentBlockOf(_proposalID, _momentID), uint256(block.number));
    assertEq(controller.momentNonceOf( _proposalID, _momentID), uint256(1));
    assertEq(controller.weightOf(_proposalID, _position), uint256(1));
    // assertEq(controller.voteOf(_proposalID, _momentID, _index), bytes32(1));
    assertEq(controller.hasExecuted(_proposalID), false);
    assertEq(controller.numDataOf(_proposalID), uint256(5));
    assertEq(controller.dataOf(_proposalID, 0), bytes32(address(this)));
    assertEq(controller.dataOf(_proposalID, 1), bytes32(0));
    assertEq(controller.dataOf(_proposalID, 2), bytes32(uint256(2)));
    assertEq(controller.dataOf(_proposalID, 3), bytes32(bytes4(sha3("setVal(uint256)"))));
    assertEq(controller.dataOf(_proposalID, 4), bytes32(uint256(455)));

    assertEq(controller.nonces(_sender), uint256(1));
    assertEq(controller.canPropose(_sender, _proposalID), true);
    assertEq(controller.canVote( _sender, _proposalID), true);
    assertEq(controller.canExecute( _sender, _proposalID), true);
    assertEq(controller.votingWeightOf( _sender, _proposalID, _index, _data), uint256(1));
    assertEq(controller.voteOffset( _sender, _proposalID), 0);
    assertEq(controller.executionOffset( _sender, _proposalID), 0);
  }

  function test_3_execute() {
  }
}
