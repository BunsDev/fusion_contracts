// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;
import "./FusionProxy.sol";

interface IProxyCreationCallback {
    function proxyCreated(
        FusionProxy proxy,
        address _singleton,
        bytes calldata initializer
    ) external;
}
