// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

abstract contract ProofHandler {
    bytes32 internal constant SENTINEL_PROOF = bytes32(uint256(1));

    mapping(bytes32 => bytes32) internal proofs;

    constructor() {
        proofs[SENTINEL_PROOF] = SENTINEL_PROOF;
    }

    function addProof(bytes calldata proof) internal {
        bytes32 proofHash = keccak256(proof);

        require(
            proofs[proofHash] == bytes32(uint256(0)),
            "Proof already exists"
        );

        require(proofHash != SENTINEL_PROOF, "Invalid proof");

        proofs[proofHash] = proofs[SENTINEL_PROOF];
        proofs[SENTINEL_PROOF] = proofHash;
    }

    function isProofDuplicate(
        bytes calldata proof
    ) internal view returns (bool) {
        return
            SENTINEL_PROOF != keccak256(proof) &&
            proofs[keccak256(proof)] != bytes32(uint256(0));
    }
}
