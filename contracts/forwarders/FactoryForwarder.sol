// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "../external/Fusion2771Context.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/utils/Nonces.sol";
import "./FactoryLogManager.sol";
import "./lib/ServerHandler.sol";
import "./lib/TargetChecker.sol";

interface IFusionProxyFactory {
    function createProxyWithDomain(
        string memory domain,
        bytes memory initializer
    ) external;
}

contract FactoryForwarder is EIP712, Nonces, FactoryLogManager, ServerHandler {
    using ECDSA for bytes32;

    event DeploymentResult(bytes4 result);

    // isBase is used to check if the contract is in base chain
    bool immutable isBase;

    // Initializing the EIP712 Domain Separator
    constructor(
        string memory name,
        string memory version,
        bool _isBase
    ) EIP712(name, version) {
        isBase = _isBase;
    }

    modifier checkBase(
        bytes calldata serverProof,
        bytes4 domain,
        address from
    ) {
        if (!isBase) {
            require(
                verify(serverProof, serverHash, ServerVerifier, domain, from),
                "FusionForwarder: invalid serverProof"
            );
        }
        _;
    }

    struct ForwardDeployData {
        address from;
        address recipient;
        uint48 deadline;
        uint256 gas;
        string domain;
        bytes initializer;
        bytes signature;
    }

    bytes32 internal constant FORWARD_DEPLOY_TYPEHASH =
        keccak256(
            "ForwardDeploy(address from,address recipient,uint48 deadline,uint256 nonce,uint256 gas,string domain,bytes initializer)"
        );

    function execute(
        bytes calldata serverProof,
        ForwardDeployData calldata request
    )
        public
        payable
        virtual
        checkBase(
            serverProof,
            bytes4(keccak256(abi.encodePacked(request.domain))),
            request.from
        )
        returns (bytes4 magicValue)
    {
        magicValue = _deploy(request, true);
        emit DeploymentResult(magicValue);
    }

    function _deploy(
        ForwardDeployData calldata request,
        bool requireValidRequest
    ) internal virtual returns (bytes4 magicValue) {
        (
            bool isTrustedForwarder,
            bool active,
            bool signerMatch,
            address signer
        ) = _validate(request);

        if (requireValidRequest) {
            if (!isTrustedForwarder) {
                return UNTRUSTFUL_TARGET;
            }

            if (!active) {
                return EXPIRED_REQUEST;
            }

            if (!signerMatch) {
                return INVALID_SIGNER;
            }
        }

        // Ignore an invalid request because requireValidRequest = false
        if (isTrustedForwarder && signerMatch && active) {
            // Nonce should be used before the call to prevent reusing by reentrancy
            _useNonce(signer);

            (bool success, ) = address(request.recipient).call{
                gas: request.gas
            }(
                abi.encodeWithSelector(
                    IFusionProxyFactory.createProxyWithDomain.selector,
                    request.domain,
                    request.initializer
                )
            );

            _checkForwardedGas(gasleft(), request.gas);

            if (!success) {
                return DEPLOYMENT_FAILED;
            }

            return DEPLOYMENT_SUCCESSFUL;
        }
    }

    function _validate(
        ForwardDeployData calldata request
    )
        internal
        view
        virtual
        returns (
            bool isTrustedForwarder,
            bool active,
            bool signerMatch,
            address signer
        )
    {
        (bool isValid, address recovered) = _recoverForwardSigner(request);

        return (
            TargetChecker._isTrustedByTarget(request.recipient),
            request.deadline >= block.timestamp,
            isValid && recovered == request.from,
            recovered
        );
    }

    function _recoverForwardSigner(
        ForwardDeployData calldata request
    ) internal view virtual returns (bool, address) {
        (address recovered, ECDSA.RecoverError err, ) = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    FORWARD_DEPLOY_TYPEHASH,
                    request.from,
                    request.recipient,
                    request.deadline,
                    nonces(request.from),
                    request.gas,
                    keccak256(bytes(request.domain)),
                    keccak256(request.initializer)
                )
            )
        ).tryRecover(request.signature);

        return (err == ECDSA.RecoverError.NoError, recovered);
    }

    function _checkForwardedGas(
        uint256 gasLeft,
        uint256 requestGas
    ) private pure {
        if (gasLeft < requestGas / 63) {
            assembly {
                invalid()
            }
        }
    }
}
