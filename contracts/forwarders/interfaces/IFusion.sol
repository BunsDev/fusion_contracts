// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

interface IFusion {
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
    ) external payable returns (bytes4 magicValue);

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
    ) external payable returns (bytes4 magicValue);

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
    ) external payable returns (bytes4 magicValue);

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
    ) external payable returns (bytes4 magicValue);
}
