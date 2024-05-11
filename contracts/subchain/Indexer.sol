// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

import "../common/StorageAccessible.sol";
import "../common/Singleton.sol";

contract Indexer is Singleton, StorageAccessible {
    address private GENESIS_ADDRESS;

    uint256 public chainId;

    bytes32 internal constant SENTINEL_TX = bytes32(uint256(1));

    mapping(bytes32 => bytes32) internal txs;

    function setupIndexer(uint256 _chainId, address _genesis) external {
        require(chainId == 0, "Indexer : Already initialized");
        txs[SENTINEL_TX] = SENTINEL_TX;
        GENESIS_ADDRESS = _genesis;
        chainId = _chainId;
    }

    modifier Initialized() {
        require(chainId != 0, "Indexer : Not initialized");
        _;
    }

    modifier onlyGenesis() {
        require(msg.sender == GENESIS_ADDRESS, "Indexer : Not genesis");
        _;
    }

    function addTx(bytes32 _tx) external Initialized onlyGenesis {
        require(txs[_tx] == bytes32(uint256(0)), "Indexer : Invalid TxHash");

        require(_tx != SENTINEL_TX, "Indexer : Invalid TxHash");

        txs[_tx] = txs[SENTINEL_TX];
        txs[SENTINEL_TX] = _tx;
    }

    function isTxDuplicate(bytes32 _tx) external view returns (bool) {
        return SENTINEL_TX != _tx && txs[_tx] != bytes32(uint256(0));
    }
}
