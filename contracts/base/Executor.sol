// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

abstract contract Executor {
    function execute(
        address to,
        uint256 value,
        bytes memory data,
        uint256 txGas
    ) internal returns (bool success) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            success := call(
                txGas,
                to,
                value,
                add(data, 0x20),
                mload(data),
                0,
                0
            )
        }
    }

    function batchExecute(
        address[] memory tos,
        uint256[] memory values,
        bytes[] memory datas
    ) internal returns (bool success) {
        require(
            tos.length == values.length && tos.length == datas.length,
            "Array lengths must match"
        );

        for (uint i = 0; i < tos.length; i++) {
            success = execute(tos[i], values[i], datas[i], gasleft());

            if (!success) {
                break;
            }
        }
    }
}
