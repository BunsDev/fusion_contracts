// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

import "./lib/ExecuteHandler.sol";

contract FusionForwarder is ExecuteHandler {
    constructor(
        string memory name,
        string memory version
    ) ExecuteHandler(name, version) {}

    event ForwarderResult(bytes4 result);

    function execute(
        ForwardExecuteData calldata request,
        address token,
        uint256 gasPrice,
        uint256 baseGas,
        uint256 estimatedFees
    ) public payable virtual returns (bytes4 magicValue) {
        magicValue = _execute(
            request,
            token,
            gasPrice,
            baseGas,
            estimatedFees,
            true
        );
        emit ForwarderResult(magicValue);
    }

    function executeBatch(
        ForwardExecuteBatchData calldata request,
        address token,
        uint256 gasPrice,
        uint256 baseGas,
        uint256 estimatedFees
    ) public payable virtual returns (bytes4 magicValue) {
        magicValue = _executeBatch(
            request,
            token,
            gasPrice,
            baseGas,
            estimatedFees,
            true
        );
        emit ForwarderResult(magicValue);
    }

    function executeRecovery(
        ForwardExecuteRecoveryData calldata request,
        address token,
        uint256 gasPrice,
        uint256 baseGas,
        uint256 estimatedFees
    ) public payable virtual returns (bytes4 magicValue) {
        magicValue = _executeRecovery(
            request,
            token,
            gasPrice,
            baseGas,
            estimatedFees,
            true
        );
        emit ForwarderResult(magicValue);
    }

    function changeRecovery(
        ForwardChangeRecoveryData calldata request,
        address token,
        uint256 gasPrice,
        uint256 baseGas,
        uint256 estimatedFees
    ) public payable virtual returns (bytes4 magicValue) {
        magicValue = _changeRecovery(
            request,
            token,
            gasPrice,
            baseGas,
            estimatedFees,
            true
        );
        emit ForwarderResult(magicValue);
    }
}
