// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

abstract contract LogManager {
    // Invalid Proof Error
    bytes4 internal constant INVALID_PROOF = bytes4(keccak256("Invalid proof"));

    // Invalid Balance Error
    bytes4 internal constant INSUFFICIENT_BALANCE =
        bytes4(keccak256("Insufficient balance"));

    // Unexpected Error
    bytes4 internal constant UNEXPECTED_ERROR =
        bytes4(keccak256("Unexpected error"));

    // Error Transfering
    bytes4 internal constant TRANSFER_FAILED =
        bytes4(keccak256("Gas Transfer failed"));

    // Execution Successful
    bytes4 internal constant EXECUTION_SUCCESSFUL =
        bytes4(keccak256("Execution successful"));

    // Recovery Successful
    bytes4 internal constant RECOVERY_SUCCESSFUL =
        bytes4(keccak256("Recovery successful"));

    // Change Successful
    bytes4 internal constant CHANGE_SUCCESSFUL =
        bytes4(keccak256("Change successful"));
}
