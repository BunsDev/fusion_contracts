// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

contract DataManager {
    struct ForwardExecuteData {
        address from;
        address recipient;
        uint48 deadline;
        uint256 gas;
        bytes proof;
        address to;
        uint256 value;
        bytes data;
        bytes signature;
    }

    bytes32 internal constant FORWARD_EXECUTE_TYPEHASH =
        keccak256(
            "ForwardExecute(address from,address recipient,uint256 deadline,uint256 nonce,uint256 gas,bytes proof,address to,uint256 value,bytes data)"
        );

    struct ForwardExecuteBatchData {
        address from;
        address recipient;
        uint48 deadline;
        uint256 gas;
        bytes proof;
        address[] to;
        uint256[] value;
        bytes[] data;
        bytes signature;
    }

    bytes32 internal constant FORWARD_EXECUTE_BATCH_TYPEHASH =
        keccak256(
            "ForwardExecuteBatch(address from,address recipient,uint256 deadline,uint256 nonce,uint256 gas,bytes proof,bytes32 to,bytes32 value,bytes32 data)"
        );

    struct ForwardExecuteRecoveryData {
        address from;
        address recipient;
        uint48 deadline;
        uint256 gas;
        bytes proof;
        bytes32 newTxHash;
        address newTxVerifier;
        bytes publicStorage;
        bytes signature;
    }

    bytes32 internal constant FORWARD_EXECUTE_RECOVERY_TYPEHASH =
        keccak256(
            "ForwardExecuteRecovery(address from,address recipient,uint256 deadline,uint256 nonce,uint256 gas,bytes proof,bytes32 newTxHash,address newTxVerifier,bytes publicStorage)"
        );

    struct ForwardChangeRecoveryData {
        address from;
        address recipient;
        uint48 deadline;
        uint256 gas;
        bytes proof;
        bytes32 newRecoveryHash;
        address newRecoveryVerifier;
        bytes publicStorage;
        bytes signature;
    }

    bytes32 internal constant FORWARD_CHANGE_RECOVERY_TYPEHASH =
        keccak256(
            "ForwardChangeRecovery(address from,address recipient,uint256 deadline,uint256 nonce,uint256 gas,bytes proof,bytes32 newRecoveryHash,address newRecoveryVerifier,bytes publicStorage)"
        );
}
