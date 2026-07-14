// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { Ownable } from "@openzeppelin/contracts/access/Ownable2Step.sol";

contract LouvrTreasury is Ownable {
    event Transfer(address indexed token, address indexed to, uint256 indexed amount);

    error TransferFailed(address token, address to, uint256 amount);

    receive() external payable {}

    constructor(address owner) Ownable (owner) {}

    function getBalance() public view returns (uint256 balance) {
        balance = address(this).balance;
    }

    function transfer(address receiver, uint256 amount) public onlyOwner {
        (bool status, ) = receiver.call{ value: amount }("");
        if (!status) revert TransferFailed(address(0), receiver, amount);
        emit Transfer(address(0), receiver, amount);
    }
    
    function transferERC20(address token, address receiver, uint256 amount) public onlyOwner {
        bool status = IERC20(token).transfer(receiver, amount);

        if (!status) revert TransferFailed(token, receiver, amount);
        emit Transfer(token, receiver, amount);
    }
}