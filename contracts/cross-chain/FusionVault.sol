// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

import "./TeamManager.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FusionVault is TeamManager {
    event DepositReceived(
        address indexed token,
        address indexed sender,
        uint256 amount
    );
    event GenesisWithdrawal(address indexed token, uint256 amount);
    event MemberWithdrawal(
        address indexed token,
        address indexed member,
        uint256 amount
    );
    event WithdrawAllGenesis(address indexed token);

    address private GenesisAddress;

    uint256 private maxWithdrawAmount = 0;

    uint256 public snapshotTime;

    constructor(uint256 _maxWithdrawAmount) {
        GenesisAddress = msg.sender;
        maxWithdrawAmount = _maxWithdrawAmount;
        snapshotTime = block.timestamp;
    }

    function deposit(address token, uint256 _amount) external payable {
        if (token == address(0)) {
            require(msg.value == _amount, "Invalid amount");
        } else {
            require(
                IERC20(token).transferFrom(msg.sender, address(this), _amount),
                "Transfer failed"
            );
        }

        emit DepositReceived(token, msg.sender, _amount);
    }

    function withdraw(address token, uint256 _amount) external {
        require(msg.sender == GenesisAddress, "Unauthorized access");
        if (token == address(0)) {
            payable(msg.sender).transfer(_amount);
        } else {
            require(
                IERC20(token).transfer(msg.sender, _amount),
                "Transfer failed"
            );
        }
        emit GenesisWithdrawal(token, _amount);
    }

    function withdrawAll(address token) external {
        require(msg.sender == GenesisAddress, "Unauthorized access");
        if (token == address(0)) {
            payable(msg.sender).transfer(address(this).balance);
        } else {
            IERC20(token).transfer(
                msg.sender,
                IERC20(token).balanceOf(address(this))
            );
        }
        emit WithdrawAllGenesis(token);
    }

    function addTeamMember(address member) external {
        require(msg.sender == GenesisAddress, "Unauthorized access");
        addMember(member);
    }

    function removeTeamMember(address prevMember, address member) external {
        require(msg.sender == GenesisAddress, "Unauthorized access");
        removeMember(prevMember, member);
    }

    function memberWithdrawal(address token, uint256 _amount) external {
        require(isMember(msg.sender), "Unauthorized access");

        require(_amount <= maxWithdrawAmount, "Invalid amount");

        if (token == address(0)) {
            require(_amount <= address(this).balance, "Insufficient balance");
            payable(msg.sender).transfer(_amount);
        } else {
            IERC20(token).transfer(msg.sender, _amount);
        }

        emit MemberWithdrawal(token, msg.sender, _amount);
    }

    function updateSnapshotTime() external {
        require(
            msg.sender == GenesisAddress || isMember(msg.sender),
            "Unauthorized access"
        );
        snapshotTime = block.timestamp;
    }

    function transferGenesis(address newGenesis) external {
        require(msg.sender == GenesisAddress, "Unauthorized access");
        GenesisAddress = newGenesis;
    }

    function changeMaxWithdrawAmount(uint256 _maxWithdrawAmount) external {
        require(msg.sender == GenesisAddress, "Unauthorized access");
        maxWithdrawAmount = _maxWithdrawAmount;
    }
}
