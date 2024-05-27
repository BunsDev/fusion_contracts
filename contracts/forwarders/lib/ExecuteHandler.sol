// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/utils/Nonces.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "../../external/Fusion2771Context.sol";
import "./ForwarderLogManager.sol";
import "./TargetChecker.sol";
import "../interfaces/IFusion.sol";
import "./DataManager.sol";

abstract contract ExecuteHandler is EIP712, Nonces, DataManager {
    using ECDSA for bytes32;

    // Initializing the EIP712 Domain Separator
    constructor(
        string memory name,
        string memory version
    ) EIP712(name, version) {}

    function _execute(
        ForwardExecuteData calldata request,
        address token,
        uint256 gasPrice,
        uint256 baseGas,
        uint256 estimatedFees,
        bool requireValidRequest
    ) internal virtual returns (bytes4 macicValue) {
        {
            (
                bool isTrustedForwarder,
                bool active,
                bool signerMatch,
                address signer
            ) = _validate(request);

            if (requireValidRequest) {
                if (!isTrustedForwarder) {
                    return ForwarderLogManager.UNTRUSTFUL_TARGET;
                }

                if (!active) {
                    return ForwarderLogManager.EXPIRED_REQUEST;
                }

                if (!signerMatch) {
                    return ForwarderLogManager.INVALID_SIGNER;
                }
            }

            if (!isTrustedForwarder || !active || !signerMatch) {
                return ForwarderLogManager.EXECUTION_FAILED;
            }

            _useNonce(signer);
        }

        // Encode the parameters for optimized gas usage
        bytes memory encodedParams = encodeExecuteParams(
            request,
            token,
            gasPrice,
            baseGas,
            estimatedFees
        );

        (bool success, bytes memory result) = request.recipient.call{
            gas: request.gas
        }(encodedParams);

        TargetChecker._checkForwardedGas(gasleft(), request.gas);

        if (!success) {
            return ForwarderLogManager.EXECUTION_FAILED;
        }

        return abi.decode(result, (bytes4));
    }

    function _executeBatch(
        ForwardExecuteBatchData calldata request,
        address token,
        uint256 gasPrice,
        uint256 baseGas,
        uint256 estimatedFees,
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
                return ForwarderLogManager.UNTRUSTFUL_TARGET;
            }

            if (!active) {
                return ForwarderLogManager.EXPIRED_REQUEST;
            }

            if (!signerMatch) {
                return ForwarderLogManager.INVALID_SIGNER;
            }
        }

        if (!isTrustedForwarder || !active || !signerMatch) {
            return ForwarderLogManager.EXECUTION_FAILED;
        }

        _useNonce(signer);

        bytes memory encodedParams = encodeExecuteBatchParams(
            request,
            token,
            gasPrice,
            baseGas,
            estimatedFees
        );

        (bool success, bytes memory result) = request.recipient.call{
            gas: request.gas
        }(encodedParams);

        TargetChecker._checkForwardedGas(gasleft(), request.gas);

        if (!success) {
            return ForwarderLogManager.EXECUTION_FAILED;
        }

        return abi.decode(result, (bytes4));
    }

    function _executeRecovery(
        ForwardExecuteRecoveryData calldata request,
        address token,
        uint256 gasPrice,
        uint256 baseGas,
        uint256 estimatedFees,
        bool requireValidRequest
    ) internal virtual returns (bytes4 magicValue) {
        {
            (
                bool isTrustedForwarder,
                bool active,
                bool signerMatch,
                address signer
            ) = _validate(request);

            if (requireValidRequest) {
                if (!isTrustedForwarder) {
                    return ForwarderLogManager.UNTRUSTFUL_TARGET;
                }

                if (!active) {
                    return ForwarderLogManager.EXPIRED_REQUEST;
                }

                if (!signerMatch) {
                    return ForwarderLogManager.INVALID_SIGNER;
                }
            }

            if (!isTrustedForwarder || !active || !signerMatch) {
                return ForwarderLogManager.EXECUTION_FAILED;
            }

            _useNonce(signer);
        }

        bytes memory encodedParams = encodeExecuteRecoveryParams(
            request,
            token,
            gasPrice,
            baseGas,
            estimatedFees
        );

        (bool success, bytes memory result) = request.recipient.call{
            gas: request.gas
        }(encodedParams);

        TargetChecker._checkForwardedGas(gasleft(), request.gas);

        if (!success) {
            return ForwarderLogManager.EXECUTION_FAILED;
        }

        return abi.decode(result, (bytes4));
    }

    function _changeRecovery(
        ForwardChangeRecoveryData calldata request,
        address token,
        uint256 gasPrice,
        uint256 baseGas,
        uint256 estimatedFees,
        bool requireValidRequest
    ) internal virtual returns (bytes4 magicValue) {
        {
            (
                bool isTrustedForwarder,
                bool active,
                bool signerMatch,
                address signer
            ) = _validate(request);

            if (requireValidRequest) {
                if (!isTrustedForwarder) {
                    return ForwarderLogManager.UNTRUSTFUL_TARGET;
                }

                if (!active) {
                    return ForwarderLogManager.EXPIRED_REQUEST;
                }

                if (!signerMatch) {
                    return ForwarderLogManager.INVALID_SIGNER;
                }
            }

            if (!isTrustedForwarder || !active || !signerMatch) {
                return ForwarderLogManager.EXECUTION_FAILED;
            }

            _useNonce(signer);
        }

        bytes memory encodedParams = encodeChangeRecoveryParams(
            request,
            token,
            gasPrice,
            baseGas,
            estimatedFees
        );

        (bool success, bytes memory result) = request.recipient.call{
            gas: request.gas
        }(encodedParams);

        TargetChecker._checkForwardedGas(gasleft(), request.gas);

        if (!success) {
            return ForwarderLogManager.EXECUTION_FAILED;
        }

        return abi.decode(result, (bytes4));
    }

    function encodeExecuteParams(
        ForwardExecuteData calldata request,
        address token,
        uint256 gasPrice,
        uint256 baseGas,
        uint256 estimatedFees
    ) internal pure returns (bytes memory) {
        bytes4 functionSignature = IFusion.executeTxWithForwarder.selector;
        return
            abi.encodeWithSelector(
                functionSignature,
                request.proof,
                request.from,
                request.to,
                request.value,
                request.data,
                token,
                gasPrice,
                baseGas,
                estimatedFees
            );
    }

    function _validate(
        ForwardExecuteData calldata request
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
        ForwardExecuteData calldata request
    ) internal view virtual returns (bool, address) {
        (address recovered, ECDSA.RecoverError err, ) = _hashTypedDataV4(
            hashEncodedRequest(request)
        ).tryRecover(request.signature);

        return (err == ECDSA.RecoverError.NoError, recovered);
    }

    function hashEncodedRequest(
        ForwardExecuteData calldata request
    ) internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    FORWARD_EXECUTE_TYPEHASH,
                    request.from,
                    request.recipient,
                    request.deadline,
                    nonces(request.from),
                    request.gas,
                    keccak256(request.proof),
                    request.to,
                    request.value,
                    keccak256(request.data)
                )
            );
    }

    function encodeExecuteBatchParams(
        ForwardExecuteBatchData calldata request,
        address token,
        uint256 gasPrice,
        uint256 baseGas,
        uint256 estimatedFees
    ) internal virtual returns (bytes memory encodedParams) {
        bytes4 functionSelector = IFusion.executeBatchTxWithForwarder.selector;

        encodedParams = abi.encodeWithSelector(
            functionSelector,
            request.proof,
            request.from,
            request.to,
            request.value,
            request.data,
            token,
            gasPrice,
            baseGas,
            estimatedFees
        );
    }

    function _validate(
        ForwardExecuteBatchData calldata request
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
        ForwardExecuteBatchData calldata request
    ) internal view virtual returns (bool, address) {
        require(
            request.to.length == request.data.length &&
                (request.value.length == 0 ||
                    request.value.length == request.data.length),
            "Mismatched input arrays"
        );

        (address recovered, ECDSA.RecoverError err, ) = _hashTypedDataV4(
            hashEncodedRequest(request)
        ).tryRecover(request.signature);

        return (err == ECDSA.RecoverError.NoError, recovered);
    }

    function hashEncodedRequest(
        ForwardExecuteBatchData calldata request
    ) internal view virtual returns (bytes32) {
        bytes32 dataHash;
        for (uint i = 0; i < request.data.length; i++) {
            dataHash = keccak256(
                abi.encodePacked(dataHash, keccak256(request.data[i]))
            );
        }
        bytes32 addressHash;
        for (uint i = 0; i < request.to.length; i++) {
            addressHash = keccak256(
                abi.encodePacked(addressHash, request.to[i])
            );
        }
        bytes32 valueHash;
        for (uint i = 0; i < request.value.length; i++) {
            valueHash = keccak256(
                abi.encodePacked(valueHash, abi.encodePacked(request.value[i]))
            );
        }
        return
            keccak256(
                abi.encode(
                    FORWARD_EXECUTE_BATCH_TYPEHASH,
                    request.from,
                    request.recipient,
                    request.deadline,
                    nonces(request.from),
                    request.gas,
                    keccak256(request.proof),
                    addressHash,
                    valueHash,
                    dataHash
                )
            );
    }

    function encodeExecuteRecoveryParams(
        ForwardExecuteRecoveryData calldata request,
        address token,
        uint256 gasPrice,
        uint256 baseGas,
        uint256 estimatedFees
    ) internal pure returns (bytes memory) {
        bytes4 functionSignature = IFusion
            .executeRecoveryWithForwarder
            .selector;
        return
            abi.encodeWithSelector(
                functionSignature,
                request.proof,
                request.from,
                request.newTxHash,
                request.newTxVerifier,
                request.publicStorage,
                token,
                gasPrice,
                baseGas,
                estimatedFees
            );
    }

    function _validate(
        ForwardExecuteRecoveryData calldata request
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
        ForwardExecuteRecoveryData calldata request
    ) internal view virtual returns (bool, address) {
        (address recovered, ECDSA.RecoverError err, ) = _hashTypedDataV4(
            hashEncodedRequest(request)
        ).tryRecover(request.signature);

        return (err == ECDSA.RecoverError.NoError, recovered);
    }

    function hashEncodedRequest(
        ForwardExecuteRecoveryData calldata request
    ) internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    FORWARD_EXECUTE_RECOVERY_TYPEHASH,
                    request.from,
                    request.recipient,
                    request.deadline,
                    nonces(request.from),
                    request.gas,
                    keccak256(request.proof),
                    request.newTxHash,
                    request.newTxVerifier,
                    keccak256(request.publicStorage)
                )
            );
    }

    function encodeChangeRecoveryParams(
        ForwardChangeRecoveryData calldata request,
        address token,
        uint256 gasPrice,
        uint256 baseGas,
        uint256 estimatedFees
    ) internal pure returns (bytes memory) {
        bytes4 functionSignature = IFusion.changeRecoveryWithForwarder.selector;
        return
            abi.encodeWithSelector(
                functionSignature,
                request.proof,
                request.from,
                request.newRecoveryHash,
                request.newRecoveryVerifier,
                request.publicStorage,
                token,
                gasPrice,
                baseGas,
                estimatedFees
            );
    }

    function _validate(
        ForwardChangeRecoveryData calldata request
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
        ForwardChangeRecoveryData calldata request
    ) internal view virtual returns (bool, address) {
        (address recovered, ECDSA.RecoverError err, ) = _hashTypedDataV4(
            hashEncodedRequest(request)
        ).tryRecover(request.signature);

        return (err == ECDSA.RecoverError.NoError, recovered);
    }

    function hashEncodedRequest(
        ForwardChangeRecoveryData calldata request
    ) internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    FORWARD_CHANGE_RECOVERY_TYPEHASH,
                    request.from,
                    request.recipient,
                    request.deadline,
                    nonces(request.from),
                    request.gas,
                    keccak256(request.proof),
                    request.newRecoveryHash,
                    request.newRecoveryVerifier,
                    keccak256(request.publicStorage)
                )
            );
    }
}
