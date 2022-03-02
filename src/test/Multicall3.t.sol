// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import {Multicall3} from "../Multicall3.sol";
import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {MockCallee} from "./mocks/MockCallee.sol";

contract Multicall3Test is DSTestPlus {
  Multicall3 multicall;
  MockCallee callee;

  /// @notice Setups up the testing suite
  function setUp() public {
    multicall = new Multicall3();
    callee = new MockCallee();
  }

  /// >>>>>>>>>>>>>>>>>>>>>  AGGREGATE TESTS  <<<<<<<<<<<<<<<<<<<<< ///

  function testAggregation() public {
    // Test successful call
    Multicall3.Call[] memory calls = new Multicall3.Call[](1);
    calls[0] = Multicall3.Call(address(callee), abi.encodeWithSignature("getBlockHash(uint256)", block.number));
    (uint256 blockNumber, bytes[] memory returnData) = multicall.aggregate(calls);
    assertEq(blockNumber, block.number);
    assertEq(keccak256(returnData[0]), keccak256(abi.encodePacked(blockhash(block.number))));
  }

  function testUnsuccessulAggregation() public {
    // Test unexpected revert
    Multicall3.Call[] memory calls = new Multicall3.Call[](2);
    calls[0] = Multicall3.Call(address(callee), abi.encodeWithSignature("getBlockHash(uint256)", block.number));
    calls[1] = Multicall3.Call(address(callee), abi.encodeWithSignature("thisMethodReverts()"));
    vm.expectRevert(bytes("Multicall3: aggregate failed"));
    multicall.aggregate(calls);
  }

  /// >>>>>>>>>>>>>>>>>>>  TRY AGGREGATE TESTS  <<<<<<<<<<<<<<<<<<< ///

  function testTryAggregate() public {
    Multicall3.Call[] memory calls = new Multicall3.Call[](2);
    calls[0] = Multicall3.Call(address(callee), abi.encodeWithSignature("getBlockHash(uint256)", block.number));
    calls[1] = Multicall3.Call(address(callee), abi.encodeWithSignature("thisMethodReverts()"));
    (Multicall3.Result[] memory returnData) = multicall.tryAggregate(false, calls);
    assertTrue(returnData[0].success);
    assertEq(keccak256(returnData[0].returnData), keccak256(abi.encodePacked(blockhash(block.number))));
    assertTrue(!returnData[1].success);
  }

  function testTryAggregateUnsuccessful() public {
    Multicall3.Call[] memory calls = new Multicall3.Call[](2);
    calls[0] = Multicall3.Call(address(callee), abi.encodeWithSignature("getBlockHash(uint256)", block.number));
    calls[1] = Multicall3.Call(address(callee), abi.encodeWithSignature("thisMethodReverts()"));
    vm.expectRevert(bytes("Multicall3: tryAggregate failed"));
    multicall.tryAggregate(true, calls);
  }

  /// >>>>>>>>>>>>>>  TRY BLOCK AND AGGREGATE TESTS  <<<<<<<<<<<<<< ///

  function testTryBlockAndAggregate() public {
    Multicall3.Call[] memory calls = new Multicall3.Call[](2);
    calls[0] = Multicall3.Call(address(callee), abi.encodeWithSignature("getBlockHash(uint256)", block.number));
    calls[1] = Multicall3.Call(address(callee), abi.encodeWithSignature("thisMethodReverts()"));
    (uint256 blockNumber, bytes32 blockHash, Multicall3.Result[] memory returnData) = multicall.tryBlockAndAggregate(false, calls);
    assertEq(blockNumber, block.number);
    assertEq(blockHash, blockhash(block.number));
    assertTrue(returnData[0].success);
    assertEq(keccak256(returnData[0].returnData), keccak256(abi.encodePacked(blockhash(block.number))));
    assertTrue(!returnData[1].success);
  }

  function testTryBlockAndAggregateUnsuccessful() public {
    Multicall3.Call[] memory calls = new Multicall3.Call[](2);
    calls[0] = Multicall3.Call(address(callee), abi.encodeWithSignature("getBlockHash(uint256)", block.number));
    calls[1] = Multicall3.Call(address(callee), abi.encodeWithSignature("thisMethodReverts()"));
    vm.expectRevert(bytes("Multicall3: tryAggregate failed"));
    multicall.tryBlockAndAggregate(true, calls);
  }

  function testBlockAndAggregateUnsuccessful() public {
    Multicall3.Call[] memory calls = new Multicall3.Call[](2);
    calls[0] = Multicall3.Call(address(callee), abi.encodeWithSignature("getBlockHash(uint256)", block.number));
    calls[1] = Multicall3.Call(address(callee), abi.encodeWithSignature("thisMethodReverts()"));
    vm.expectRevert(bytes("Multicall3: tryAggregate failed"));
    multicall.blockAndAggregate(calls);
  }

  /// >>>>>>>>>>>>>>>>>>>  AGGREGATE3 TESTS  <<<<<<<<<<<<<<<<<<<<<< ///

  function testAggregate3() public {
    Multicall3.Call3[] memory calls = new Multicall3.Call3[](2);
    calls[0] = Multicall3.Call3(address(callee), false, abi.encodeWithSignature("getBlockHash(uint256)", block.number));
    calls[1] = Multicall3.Call3(address(callee), true, abi.encodeWithSignature("thisMethodReverts()"));
    (uint256 blockNumber, bytes32 blockHash, Multicall3.Result[] memory returnData) = multicall.aggregate3(calls);
    assertEq(blockNumber, block.number);
    assertEq(blockHash, blockhash(block.number));
    assertTrue(returnData[0].success);
    assertEq(keccak256(returnData[0].returnData), keccak256(abi.encodePacked(blockhash(block.number))));
    assertTrue(!returnData[1].success);
  }

  function testAggregate3Unsuccessful() public {
    Multicall3.Call3[] memory calls = new Multicall3.Call3[](2);
    calls[0] = Multicall3.Call3(address(callee), false, abi.encodeWithSignature("getBlockHash(uint256)", block.number));
    calls[1] = Multicall3.Call3(address(callee), false, abi.encodeWithSignature("thisMethodReverts()"));
    vm.expectRevert(bytes("Multicall3: aggregate3 failed"));
    multicall.aggregate3(calls);
  }

  /// >>>>>>>>>>>>>>>>>>>>>>  HELPER TESTS  <<<<<<<<<<<<<<<<<<<<<<< ///

  function testGetBlockHash(uint256 blockNumber) public {
    assertEq(blockhash(blockNumber), multicall.getBlockHash(blockNumber));
  }

  function testGetBlockNumber() public {
    assertEq(block.number, multicall.getBlockNumber());
  }

  function testGetCurrentBlockCoinbase() public {
    assertEq(block.coinbase, multicall.getCurrentBlockCoinbase());
  }

  function testGetCurrentBlockDifficulty() public {
    assertEq(block.difficulty, multicall.getCurrentBlockDifficulty());
  }

  function testGetCurrentBlockGasLimit() public {
    assertEq(block.gaslimit, multicall.getCurrentBlockGasLimit());
  }

  function testGetCurrentBlockTimestamp() public {
    assertEq(block.timestamp, multicall.getCurrentBlockTimestamp());
  }

  function testGetEthBalance(address addr) public {
    assertEq(addr.balance, multicall.getEthBalance(addr));
  }

  function testGetLastBlockHash() public {
    // Prevent arithmetic underflow on the genesis block
    if (block.number == 0) return;
    assertEq(blockhash(block.number - 1), multicall.getLastBlockHash());
  }
}
