// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

import "./Proxy.sol";

contract IndexerProxyFactory {
    event ProxyCreation(Proxy indexed proxy, address singleton);
    event SingletonUpdated(address singleton);

    address private GenesisAddress;

    address private CurrentSingleton;

    constructor(address CurrentSingleton_) {
        CurrentSingleton = CurrentSingleton_;
        GenesisAddress = msg.sender;
    }

    function proxyCreationCode() public pure returns (bytes memory) {
        return type(Proxy).creationCode;
    }

    function deployProxy(
        bytes memory initializer,
        bytes32 salt
    ) internal returns (Proxy proxy) {
        require(
            isContract(CurrentSingleton),
            "Singleton contract not deployed"
        );

        bytes memory deploymentData = abi.encodePacked(
            type(Proxy).creationCode,
            uint256(uint160(CurrentSingleton))
        );
        // solhint-disable-next-line no-inline-assembly
        assembly {
            proxy := create2(
                0x0,
                add(0x20, deploymentData),
                mload(deploymentData),
                salt
            )
        }
        require(address(proxy) != address(0), "Create2 call failed");

        if (initializer.length > 0) {
            // solhint-disable-next-line no-inline-assembly
            assembly {
                if eq(
                    call(
                        gas(),
                        proxy,
                        0,
                        add(initializer, 0x20),
                        mload(initializer),
                        0,
                        0
                    ),
                    0
                ) {
                    revert(0, 0)
                }
            }
        }
    }

    function createIndexerWithChain(
        uint256 chainId,
        bytes memory initializer
    ) public returns (Proxy proxy) {
        bytes32 salt = keccak256(abi.encodePacked(chainId, msg.sender));
        proxy = deployProxy(initializer, salt);

        emit ProxyCreation(proxy, CurrentSingleton);
    }

    function getIndexerProxy(
        uint256 chainId,
        address deployer
    ) public view returns (address indexerProxy) {
        bytes32 salt = keccak256(abi.encodePacked(chainId, deployer));
        bytes memory deploymentData = abi.encodePacked(
            proxyCreationCode(),
            uint256(uint160(CurrentSingleton))
        );

        // Calculate the address of the proxy contract using CREATE2
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                salt,
                keccak256(deploymentData)
            )
        );

        // Cast the hash to an address
        address indexer = address(uint160(uint256(hash)));

        if (isContract(indexer)) {
            return indexer;
        } else {
            return address(0);
        }
    }

    function updateSingleton(address _singleton) external {
        require(
            msg.sender == GenesisAddress,
            "Only the Genesis Address can update the Singleton"
        );
        CurrentSingleton = _singleton;
        emit SingletonUpdated(_singleton);
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function transferGenesis(address newGenesis) external {
        require(
            msg.sender == GenesisAddress,
            "Only the Genesis Address can transfer ownership"
        );
        GenesisAddress = newGenesis;
    }
}
