// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";

abstract contract CLFunctionsHandler is FunctionsClient, ConfirmedOwner {
    using FunctionsRequest for FunctionsRequest.Request;

    string public source;
    bytes32 donID;
    uint64 subscriptionId;
    uint32 gasLimit;

    function setupChainlinkFunctions(
        address router,
        address owner,
        bytes32 _donId,
        uint64 _subscriptionId,
        uint32 _gasLimit,
        string memory _source
    ) internal {
        setupConfirmedOwner(owner);
        setRouter(router);
        donID = _donId;
        subscriptionId = _subscriptionId;
        gasLimit = _gasLimit;
        source = _source;
    }

    function sendRequest(
        string[] memory args
    ) internal returns (bytes32 requestId) {
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(source);
        if (args.length > 0) req.setArgs(args);

        // Send the request and store the request ID
        bytes32 s_lastRequestId = _sendRequest(
            req.encodeCBOR(),
            subscriptionId,
            gasLimit,
            donID
        );

        return s_lastRequestId;
    }
}
