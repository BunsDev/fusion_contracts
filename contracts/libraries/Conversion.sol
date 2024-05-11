// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

library Conversion {
    function convertToPaddedByte32(
        bytes32 value
    ) internal pure returns (bytes32) {
        bytes32 paddedValue;
        paddedValue = bytes32(uint256(value) >> (31 * 8));
        return paddedValue;
    }

    function convertToInputs(
        bytes32 _message,
        bytes32 _hash,
        address _addr
    ) internal pure returns (bytes32[] memory) {
        bytes32[] memory byte32Inputs = new bytes32[](34);
        for (uint256 i = 0; i < 32; i++) {
            byte32Inputs[i] = convertToPaddedByte32(_message[i]);
        }
        byte32Inputs[32] = _hash;
        byte32Inputs[33] = bytes32(uint256(uint160(_addr)));

        return byte32Inputs;
    }

    function uintToString(uint256 v) internal pure returns (string memory) {
        if (v == 0) {
            return "0";
        }

        uint256 maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint256 i = 0;
        while (v != 0) {
            uint256 remainder = v % 10;
            v = v / 10;
            reversed[i++] = bytes1(uint8(48 + remainder));
        }
        bytes memory s = new bytes(i);
        for (uint256 j = 0; j < i; j++) {
            s[j] = reversed[i - 1 - j];
        }
        return string(s);
    }

    function bytesToString(
        bytes memory data
    ) internal pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(2 * data.length);
        for (uint256 i = 0; i < data.length; i++) {
            str[2 * i] = alphabet[uint8(data[i] >> 4)];
            str[2 * i + 1] = alphabet[uint8(data[i] & 0x0f)];
        }
        return string(str);
    }

    function hashMessage(
        string memory message
    ) internal pure returns (bytes32) {
        string memory messagePrefix = "\x19Ethereum Signed Message:\n";
        string memory lengthString = uintToString(bytes(message).length);
        string memory concatenatedMessage = string(
            abi.encodePacked(messagePrefix, lengthString, message)
        );
        return keccak256(bytes(concatenatedMessage));
    }
}
