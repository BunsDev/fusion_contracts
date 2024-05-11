// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

import "./common/Singleton.sol";
import "./common/StorageAccessible.sol";
import "./base/Executor.sol";
import "./base/ProofManager.sol";
import "./handler/TokenCallbackHandler.sol";
import "./external/Fusion2771Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./base/LogManager.sol";

contract Fusion is
    Singleton,
    StorageAccessible,
    Executor,
    ProofManager,
    TokenCallbackHandler,
    Fusion2771Context
{
    string public constant VERSION = "1.0.0";

    bytes32 public DOMAIN;

    address public TxVerifier;
    address public RecoveryVerifier;

    bytes32 public TxHash;
    bytes32 public RecoveryHash;

    address public GasTank;

    bytes public PublicStorage;

    uint256 private nonce;

    event SetupFusion(
        bytes32 domain,
        address txVerifier,
        address recoveryVerifier,
        address forwarder,
        address gasTank,
        bytes32 txHash,
        bytes32 recoveryHash,
        bytes publicStorage
    );

    event ExecutionResult(bytes4 magicValue);

    function setupFusion(
        bytes32 _domain,
        address _txVerifier,
        address _recoveryVerifier,
        address _forwarder,
        address _gasTank,
        bytes32 _txHash,
        bytes32 _recoveryHash,
        bytes memory _publicStorage
    ) external {
        require(DOMAIN == bytes32(0), "Fusion: already initialized");
        require(TxVerifier == address(0), "Fusion: already initialized");
        require(RecoveryVerifier == address(0), "Fusion: already initialized");
        require(GasTank == address(0), "Fusion: already initialized");

        setupTrustedForwarder(_forwarder);
        DOMAIN = _domain;
        TxVerifier = _txVerifier;
        RecoveryVerifier = _recoveryVerifier;
        GasTank = _gasTank;
        TxHash = _txHash;
        RecoveryHash = _recoveryHash;
        PublicStorage = _publicStorage;

        emit SetupFusion(
            _domain,
            _txVerifier,
            _recoveryVerifier,
            _forwarder,
            _gasTank,
            _txHash,
            _recoveryHash,
            _publicStorage
        );
    }

    function executeTx(
        bytes calldata _proof,
        address to,
        uint256 value,
        bytes calldata data
    ) public payable notTrustedForwarder returns (bytes4) {
        if (!verify(_proof, _useNonce(), TxHash, TxVerifier, msg.sender)) {
            emit ExecutionResult(INVALID_PROOF);
            return INVALID_PROOF;
        }
        if (!execute(to, value, data, gasleft())) {
            emit ExecutionResult(UNEXPECTED_ERROR);
            return UNEXPECTED_ERROR;
        }
        emit ExecutionResult(EXECUTION_SUCCESSFUL);
        return EXECUTION_SUCCESSFUL;
    }

    function executeBatchTx(
        bytes calldata _proof,
        address[] calldata to,
        uint256[] calldata value,
        bytes[] calldata data
    ) public payable notTrustedForwarder returns (bytes4) {
        if (!verify(_proof, _useNonce(), TxHash, TxVerifier, msg.sender)) {
            emit ExecutionResult(INVALID_PROOF);
            return INVALID_PROOF;
        }
        if (!batchExecute(to, value, data)) {
            emit ExecutionResult(UNEXPECTED_ERROR);
            return UNEXPECTED_ERROR;
        }
        emit ExecutionResult(EXECUTION_SUCCESSFUL);
        return EXECUTION_SUCCESSFUL;
    }

    function executeRecovery(
        bytes calldata _proof,
        bytes32 _newTxHash,
        address _newTxVerifier,
        bytes calldata _publicStorage
    ) public payable notTrustedForwarder returns (bytes4) {
        if (
            !verify(
                _proof,
                _useNonce(),
                RecoveryHash,
                RecoveryVerifier,
                msg.sender
            )
        ) {
            emit ExecutionResult(INVALID_PROOF);
            return INVALID_PROOF;
        }
        TxHash = _newTxHash;
        TxVerifier = _newTxVerifier;
        PublicStorage = _publicStorage;

        emit ExecutionResult(RECOVERY_SUCCESSFUL);
        return RECOVERY_SUCCESSFUL;
    }

    function changeRecovery(
        bytes calldata _proof,
        bytes32 _newRecoveryHash,
        address _newRecoveryVerifier,
        bytes calldata _publicStorage
    ) public payable notTrustedForwarder returns (bytes4) {
        if (
            !verify(
                _proof,
                _useNonce(),
                RecoveryHash,
                RecoveryVerifier,
                msg.sender
            )
        ) {
            emit ExecutionResult(INVALID_PROOF);
            return INVALID_PROOF;
        }
        RecoveryHash = _newRecoveryHash;
        RecoveryVerifier = _newRecoveryVerifier;
        PublicStorage = _publicStorage;

        emit ExecutionResult(CHANGE_SUCCESSFUL);
        return CHANGE_SUCCESSFUL;
    }

    function executeTxWithForwarder(
        bytes calldata _proof,
        address from,
        address to,
        uint256 value,
        bytes calldata data,
        address token,
        uint256 gasPrice,
        uint256 baseGas,
        uint256 estimatedFees
    ) public payable onlyTrustedForwarder returns (bytes4 magicValue) {
        if (!verify(_proof, _useNonce(), TxHash, TxVerifier, from)) {
            emit ExecutionResult(INVALID_PROOF);
            return INVALID_PROOF;
        }

        if (!checkBalance(token, estimatedFees)) {
            emit ExecutionResult(INSUFFICIENT_BALANCE);
            return INSUFFICIENT_BALANCE;
        }

        uint256 startGas = gasleft();

        magicValue = EXECUTION_SUCCESSFUL;

        if (!execute(to, value, data, gasleft())) {
            magicValue = UNEXPECTED_ERROR;
        }

        magicValue = chargeFees(
            startGas,
            gasPrice,
            baseGas,
            GasTank,
            token,
            magicValue
        );
        emit ExecutionResult(magicValue);
    }

    function executeBatchTxWithForwarder(
        bytes calldata _proof,
        address from,
        address[] calldata to,
        uint256[] calldata value,
        bytes[] calldata data,
        address token,
        uint256 gasPrice,
        uint256 baseGas,
        uint256 estimatedFees
    ) public payable onlyTrustedForwarder returns (bytes4 magicValue) {
        if (!verify(_proof, _useNonce(), TxHash, TxVerifier, from)) {
            emit ExecutionResult(INVALID_PROOF);
            return INVALID_PROOF;
        }

        if (checkBalance(token, estimatedFees) == false) {
            emit ExecutionResult(INSUFFICIENT_BALANCE);
            return INSUFFICIENT_BALANCE;
        }

        uint256 startGas = gasleft();

        magicValue = EXECUTION_SUCCESSFUL;

        if (batchExecute(to, value, data)) {
            magicValue = UNEXPECTED_ERROR;
        }

        magicValue = chargeFees(
            startGas,
            gasPrice,
            baseGas,
            GasTank,
            token,
            magicValue
        );
        emit ExecutionResult(magicValue);
    }

    function executeRecoveryWithForwarder(
        bytes calldata _proof,
        address from,
        bytes32 _newTxHash,
        address _newTxVerifier,
        bytes calldata _publicStorage,
        address token,
        uint256 gasPrice,
        uint256 baseGas,
        uint256 estimatedFees
    ) public payable onlyTrustedForwarder returns (bytes4 magicValue) {
        if (
            !verify(_proof, _useNonce(), RecoveryHash, RecoveryVerifier, from)
        ) {
            emit ExecutionResult(INVALID_PROOF);
            return INVALID_PROOF;
        }

        if (!checkBalance(token, estimatedFees)) {
            emit ExecutionResult(INSUFFICIENT_BALANCE);
            return INSUFFICIENT_BALANCE;
        }

        uint256 startGas = gasleft();

        TxHash = _newTxHash;
        TxVerifier = _newTxVerifier;
        PublicStorage = _publicStorage;

        magicValue = chargeFees(
            startGas,
            gasPrice,
            baseGas,
            GasTank,
            token,
            RECOVERY_SUCCESSFUL
        );
        emit ExecutionResult(magicValue);
    }

    function changeRecoveryWithForwarder(
        bytes calldata _proof,
        address from,
        bytes32 _newRecoveryHash,
        address _newRecoveryVerifier,
        bytes calldata _publicStorage,
        address token,
        uint256 gasPrice,
        uint256 baseGas,
        uint256 estimatedFees
    ) public payable onlyTrustedForwarder returns (bytes4 magicValue) {
        if (
            !verify(_proof, _useNonce(), RecoveryHash, RecoveryVerifier, from)
        ) {
            emit ExecutionResult(INVALID_PROOF);
            return INVALID_PROOF;
        }

        if (!checkBalance(token, estimatedFees)) {
            emit ExecutionResult(INSUFFICIENT_BALANCE);
            return INSUFFICIENT_BALANCE;
        }

        uint256 startGas = gasleft();

        RecoveryHash = _newRecoveryHash;
        RecoveryVerifier = _newRecoveryVerifier;
        PublicStorage = _publicStorage;

        magicValue = chargeFees(
            startGas,
            gasPrice,
            baseGas,
            GasTank,
            token,
            CHANGE_SUCCESSFUL
        );
        emit ExecutionResult(magicValue);
    }

    function checkBalance(
        address token,
        uint256 estimatedFees
    ) internal view returns (bool) {
        if (token != address(0)) {
            uint8 decimals = IERC20(token).decimals();
            if (
                IERC20(token).balanceOf(address(this)) <
                estimatedFees / 10 ** (18 - decimals)
            ) {
                return false;
            }
        } else {
            if (address(this).balance < estimatedFees) {
                return false;
            }
        }

        return true;
    }

    function isValidSignature(
        bytes32 _hash,
        bytes calldata _signature
    ) public view returns (bytes4 magicValue) {
        if (verify(_signature, _hash, TxHash, TxVerifier, address(this))) {
            return 0x1626ba7e;
        } else {
            return 0xffffffff;
        }
    }

    function getNonce() public view returns (uint256) {
        return nonce;
    }

    function _useNonce() internal returns (uint256) {
        unchecked {
            return nonce++;
        }
    }

    receive() external payable {}

    fallback() external payable {}
}
