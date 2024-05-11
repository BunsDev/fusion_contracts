// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

interface UltraVerifierInterface {
    function verify(
        bytes calldata _proof,
        bytes32[] calldata _publicInputs
    ) external view returns (bool);
}

abstract contract Verifier {
    function verifyProof(
        bytes calldata _proof,
        bytes32[] memory _publicInputs,
        address _verifier
    ) internal view returns (bool) {
        return UltraVerifierInterface(_verifier).verify(_proof, _publicInputs);
    }
}
