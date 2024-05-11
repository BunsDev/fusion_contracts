// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

import "../../external/Fusion2771Context.sol";

library TargetChecker {
    function _isTrustedByTarget(address target) internal view returns (bool) {
        bytes memory encodedParams = abi.encodeCall(
            Fusion2771Context.isTrustedForwarder,
            (address(this))
        );

        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly {
            success := staticcall(
                gas(),
                target,
                add(encodedParams, 0x20),
                mload(encodedParams),
                0,
                0x20
            )
            returnSize := returndatasize()
            returnValue := mload(0)
        }

        return success && returnSize >= 0x20 && returnValue > 0;
    }

    function _checkForwardedGas(
        uint256 gasLeft,
        uint256 requestGas
    ) internal pure {
        if (gasLeft < requestGas / 63) {
            assembly {
                invalid()
            }
        }
    }
}
