// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

abstract contract FactoryLogManager {
    bytes4 internal constant MISMATCH_VALUE =
        bytes4(keccak256("Fusion: mismatched value"));
    bytes4 internal constant EXPIRED_REQUEST =
        bytes4(keccak256("Fusion: expired request"));
    bytes4 internal constant UNTRUSTFUL_TARGET =
        bytes4(keccak256("Fusion: untrustful target"));
    bytes4 internal constant INVALID_SIGNER =
        bytes4(keccak256("Fusion: invalid signer"));
    bytes4 internal constant DEPLOYMENT_FAILED =
        bytes4(keccak256("Fusion: deployment failed"));
    bytes4 internal constant INSUFFICIENT_BALANCE =
        bytes4(keccak256("Fusion: insufficient balance"));

    bytes4 internal constant DEPLOYMENT_SUCCESSFUL =
        bytes4(keccak256("Fusion: deployment successful"));
}
