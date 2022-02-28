// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

/// @title MockCallee
/// @notice Receives calls from the Multicaller
/// @author andreas@nascent.xyz
contract MockCallee {

  /// @notice Failure
  error Unsuccessful();

  /// @notice Returns the block hash for the given block number
  /// @param blockNumber The block number
  /// @return blockHash The 32 byte block hash
  function getBlockHash(uint256 blockNumber) public view returns (bytes32 blockHash) {
    blockHash = blockhash(blockNumber);
  }

  /// @notice Returns if successful
  function thisMethodReverts() public view returns (bool success) {
    revert Unsuccessful();
    success = true;
  }
}