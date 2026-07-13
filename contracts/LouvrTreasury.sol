// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import { Ownable2Step, Ownable } from "@openzeppelin/contracts/access/Ownable2Step.sol";

contract LouvrTreasury is Ownable2Step {
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
}