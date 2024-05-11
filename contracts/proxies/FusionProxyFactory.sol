// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

import "./FusionProxy.sol";
import "./IProxyCreationCallback.sol";
import "../external/Fusion2771Context.sol";
import "../cross-chain/ProofHandler.sol";
import "../base/Verifier.sol";
import "./CLFunctionsHandler.sol";
import "../libraries/Conversion.sol";

contract FusionProxyFactory is
    Fusion2771Context,
    ProofHandler,
    Verifier,
    CLFunctionsHandler
{
    event ProxyCreation(FusionProxy indexed proxy, address singleton);
    event ProxyCreationWithRequest(
        FusionProxy indexed proxy,
        address singleton,
        bytes32 requestId,
        bytes error
    );
    event SingletonUpdated(address singleton);

    address private GenesisAddress;

    address private CurrentSingleton;

    bool immutable IsBaseChain;

    constructor(address CurrentSingleton_, bool _isBaseChain) {
        CurrentSingleton = CurrentSingleton_;
        GenesisAddress = msg.sender;
        IsBaseChain = _isBaseChain;
    }

    struct request {
        string domain;
        bytes initializer;
    }

    mapping(bytes32 => request) public requests;

    modifier checkBase() {
        if (!IsBaseChain) {
            require(
                msg.sender == trustedForwarder(),
                "Only the trusted forwarder can call this function"
            );
        }
        _;
    }

    function proxyCreationCode() public pure returns (bytes memory) {
        return type(FusionProxy).creationCode;
    }

    function setupFunctions(
        address router,
        address owner,
        bytes32 _donId,
        uint64 _subscriptionId,
        uint32 _gasLimit
    ) external {
        require(
            msg.sender == GenesisAddress,
            "Only the Genesis Address can transfer ownership"
        );
        setupChainlinkFunctions(
            router,
            owner,
            _donId,
            _subscriptionId,
            _gasLimit
        );
    }

    function deployProxy(
        bytes memory initializer,
        bytes32 salt
    ) internal returns (FusionProxy proxy) {
        require(
            isContract(CurrentSingleton),
            "Singleton contract not deployed"
        );

        bytes memory deploymentData = abi.encodePacked(
            type(FusionProxy).creationCode,
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

    function updateSingleton(address _singleton) external {
        require(
            msg.sender == GenesisAddress,
            "Only the Genesis Address can update the Singleton"
        );
        CurrentSingleton = _singleton;
        emit SingletonUpdated(_singleton);
    }

    function createProxyWithDomain(
        string memory domain,
        bytes memory initializer
    ) public checkBase returns (FusionProxy proxy) {
        // If the domain changes the proxy address should change too.
        bytes32 salt = keccak256(
            abi.encodePacked(keccak256(abi.encodePacked(domain)))
        );
        proxy = deployProxy(initializer, salt);

        emit ProxyCreation(proxy, CurrentSingleton);
    }

    function createProxyWithCallback(
        string memory domain,
        bytes memory initializer,
        IProxyCreationCallback callback
    ) public checkBase returns (FusionProxy proxy) {
        proxy = createProxyWithDomain(domain, initializer);
        if (address(callback) != address(0))
            callback.proxyCreated(proxy, CurrentSingleton, initializer);
    }

    function createProxyWithRequest(
        bytes memory baseProof,
        string memory domain,
        bytes memory initializer
    ) public returns (bytes32 requestId) {
        require(!IsBaseChain, "Cannot create proxy with request on base chain");
        require(!domainExists(domain), "Domain already exists");
        require(initializer.length > 0, "Initializer cannot be empty");

        string[] memory args = new string[](3);

        args[0] = Conversion.bytesToString(baseProof);
        args[1] = domain;
        args[2] = Conversion.bytesToString(initializer);

        requestId = sendRequest(args);
        requests[requestId] = request(domain, initializer);
    }

    function fulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory err
    ) internal override {
        require(!IsBaseChain, "Cannot fulfill request on base chain");
        request memory req = requests[requestId];
        uint256 _response = abi.decode(response, (uint256));
        require(_response == 1, "Request failed");

        FusionProxy proxy = createProxyWithDomain(req.domain, req.initializer);

        emit ProxyCreationWithRequest(proxy, CurrentSingleton, requestId, err);

        delete requests[requestId];
    }

    function getFusionProxy(
        string memory domain
    ) public view returns (address fusionProxy) {
        bytes32 salt = keccak256(
            abi.encodePacked(keccak256(abi.encodePacked(domain)))
        );
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
        address fusion = address(uint160(uint256(hash)));

        if (isContract(fusion)) {
            return fusion;
        } else {
            return address(0);
        }
    }

    function domainExists(
        string memory domain
    ) public view returns (bool exists) {
        return getFusionProxy(domain) != address(0);
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function setupForwarder(address forwarder) public {
        require(
            msg.sender == GenesisAddress,
            "Only the Genesis Address can setup the forwarder"
        );
        setupTrustedForwarder(forwarder);
    }

    function transferGenesis(address newGenesis) external {
        require(
            msg.sender == GenesisAddress,
            "Only the Genesis Address can transfer ownership"
        );
        GenesisAddress = newGenesis;
    }
}
