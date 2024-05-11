// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

import "../../cross-chain/ProofHandler.sol";
import "../../base/Verifier.sol";

abstract contract ServerHandler is ProofHandler, Verifier {
    address private GenesisAddress;

    address internal ServerVerifier;

    bytes32 internal serverHash;

    constructor() {
        GenesisAddress = msg.sender;
    }

    modifier onlyGenesis() {
        require(
            msg.sender == GenesisAddress,
            "Only genesis can call this function"
        );
        _;
    }

    function transferGenesis(address _newGenesis) external onlyGenesis {
        GenesisAddress = _newGenesis;
    }

    function setupServer(
        address _serverVerifier,
        bytes32 _serverHash
    ) external onlyGenesis {
        ServerVerifier = _serverVerifier;
        serverHash = _serverHash;
    }

    function verify(
        bytes calldata _proof,
        bytes32 _serverHash,
        address _verifier,
        bytes4 _domain,
        address _addr
    ) internal returns (bool) {
        bytes32[] memory publicInputs;

        require(isProofDuplicate(_proof) == false, "Proof already exists");

        // Add the proof to prevent reuse
        addProof(_proof);

        // Use scope here to limit variable lifetime and prevent `stack too deep` errors
        {
            publicInputs = new bytes32[](4);
            publicInputs[0] = _serverHash;
            publicInputs[1] = bytes32(uint256(uint32(_domain)));
            publicInputs[2] = bytes32(getChainId());
            publicInputs[3] = bytes32(uint256(uint160(_addr)));
        }

        return verifyProof(_proof, publicInputs, _verifier);
    }

    function getChainId() public view returns (uint256) {
        uint256 id;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            id := chainid()
        }
        return id;
    }
}
