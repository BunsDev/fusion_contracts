// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;
import "./Verifier.sol";
import "../libraries/Conversion.sol";

abstract contract ProofManager is Verifier {
    function verify(
        bytes calldata _proof,
        uint256 _nonce,
        bytes32 _hash,
        address _verifier,
        address _addr
    ) internal view returns (bool) {
        bytes32[] memory publicInputs;
        {
            bytes32 message = Conversion.hashMessage(
                Conversion.uintToString(_nonce)
            );
            publicInputs = Conversion.convertToInputs(message, _hash, _addr);
        }
        return verifyProof(_proof, publicInputs, _verifier);
    }

    function verify(
        bytes calldata _proof,
        bytes32 _message,
        bytes32 _hash,
        address _verifier,
        address _addr
    ) internal view returns (bool) {
        bytes32[] memory publicInputs = Conversion.convertToInputs(
            _message,
            _hash,
            _addr
        );
        return verifyProof(_proof, publicInputs, _verifier);
    }
}
