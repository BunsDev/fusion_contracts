// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

interface IIndexer {
    function addTx(bytes32 _tx) external;
}

contract BalanceHandler {
    mapping(bytes32 => uint256) public balances;

    mapping(uint256 => address) public indexers;

    address public GENESIS_ADDRESS;

    constructor(address _genesis) {
        GENESIS_ADDRESS = _genesis;
    }

    modifier onlyGenesis() {
        require(msg.sender == GENESIS_ADDRESS, "BalanceHandler: Not genesis");
        _;
    }

    function addIndexer(
        uint256 _chainId,
        address _indexer
    ) external onlyGenesis {
        require(
            indexers[_chainId] == address(0),
            "BalanceHandler: Indexer already exists"
        );
        indexers[_chainId] = _indexer;
    }

    function DepositAndIndex(
        string memory domain,
        uint256 chainId,
        bytes32 txHash
    ) external payable onlyGenesis {
        require(
            indexers[chainId] != address(0),
            "BalanceHandler: Indexer not found"
        );

        IIndexer(indexers[chainId]).addTx(txHash);
        balances[keccak256(abi.encodePacked(domain))] += msg.value;
    }

    function WithdrawFees(
        string memory domain,
        uint256 estimatedFees
    ) external payable onlyGenesis {
        require(
            balances[keccak256(abi.encodePacked(domain))] >= estimatedFees,
            "BalanceHandler: insufficient balance"
        );

        payable(GENESIS_ADDRESS).transfer(estimatedFees);
        balances[keccak256(abi.encodePacked(domain))] -= estimatedFees;
    }

    function checkBalance(
        string memory domain
    ) external view returns (uint256) {
        return balances[keccak256(abi.encodePacked(domain))];
    }

    function transferGenesis(address newGenesis) external onlyGenesis {
        GENESIS_ADDRESS = newGenesis;
    }
}
