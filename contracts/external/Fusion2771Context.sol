// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import {Context} from "./Context.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../base/LogManager.sol";

abstract contract Fusion2771Context is Context, LogManager {
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable
    address private _trustedForwarder;

    function setupTrustedForwarder(address forwarder) internal {
        require(
            _trustedForwarder == address(0),
            "ERC2771Context: forwarder already set"
        );
        require(
            forwarder != address(0),
            "ERC2771Context: invalid trusted forwarder"
        );
        _trustedForwarder = forwarder;
    }

    function chargeFees(
        uint256 startGas,
        uint256 gasPrice,
        uint256 baseGas,
        address GasTank,
        address token,
        bytes4 defaultReturn
    ) internal returns (bytes4) {
        uint256 gasUsed = startGas - gasleft();
        uint256 gasFee = (gasUsed + baseGas) * gasPrice;

        if (token != address(0)) {
            uint8 decimals = IERC20(token).decimals();
            try
                IERC20(token).transfer(GasTank, gasFee / 10 ** (18 - decimals))
            {} catch {
                return TRANSFER_FAILED;
            }
        } else {
            (bool success, ) = GasTank.call{value: gasFee}("");
            if (!success) {
                return TRANSFER_FAILED;
            }
        }

        return defaultReturn;
    }

    function trustedForwarder() public view virtual returns (address) {
        return _trustedForwarder;
    }

    function isTrustedForwarder(
        address forwarder
    ) public view virtual returns (bool) {
        return forwarder == trustedForwarder();
    }

    modifier onlyTrustedForwarder() {
        require(
            isTrustedForwarder(msg.sender),
            "ERC2771Context: caller is not the trusted forwarder"
        );
        _;
    }

    modifier notTrustedForwarder() {
        require(
            !isTrustedForwarder(msg.sender),
            "ERC2771Context: caller is the trusted forwarder"
        );
        _;
    }

    function _msgSender() internal view virtual override returns (address) {
        uint256 calldataLength = msg.data.length;
        uint256 contextSuffixLength = _contextSuffixLength();
        if (
            isTrustedForwarder(msg.sender) &&
            calldataLength >= contextSuffixLength
        ) {
            return
                address(
                    bytes20(msg.data[calldataLength - contextSuffixLength:])
                );
        } else {
            return super._msgSender();
        }
    }

    function _msgData()
        internal
        view
        virtual
        override
        returns (bytes calldata)
    {
        uint256 calldataLength = msg.data.length;
        uint256 contextSuffixLength = _contextSuffixLength();
        if (
            isTrustedForwarder(msg.sender) &&
            calldataLength >= contextSuffixLength
        ) {
            return msg.data[:calldataLength - contextSuffixLength];
        } else {
            return super._msgData();
        }
    }

    function _contextSuffixLength()
        internal
        view
        virtual
        override
        returns (uint256)
    {
        return 20;
    }
}
