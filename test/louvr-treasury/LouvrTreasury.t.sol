// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import { Addresses} from "../utils/Addresses.sol";
import { LouvrTreasury } from "../../contracts/LouvrTreasury.sol";
import { NonReceivingContract} from "../utils/NonReceivingContract.sol";

contract LouvrTreasuryTest is Addresses {
    LouvrTreasury internal treasury;
    NonReceivingContract internal nrc;

    modifier fund() {
        vm.prank(goodGuy2);
        (bool sent,) = address(treasury).call{value: 0.9 ether}(""); sent;
        vm.stopPrank();

        _;
    }
    
    constructor() {
        treasury = new LouvrTreasury(owner);
        nrc = new NonReceivingContract();
    }

    function testInitialBalance() public view {
        assert(treasury.getBalance() == 0);
    }

    function testBalanceAfterFunding(uint256 amount) public {
        vm.assume(amount >= 0.1 ether);
        vm.assume(amount <= 1 ether);

        vm.prank(goodGuy1);
        (bool sent,) = address(treasury).call{value: amount}(""); sent;
        vm.stopPrank();

        assert(treasury.getBalance() == amount);
    }

    function testTransferByNonOwner() public {
        vm.prank(badGuy1);
        vm.expectRevert();
        treasury.transfer(receiver1, address(treasury).balance);
        vm.stopPrank();
    }

    function testTransferByOwnerToNRC() public {
        vm.prank(owner);
        vm.expectRevert();
        treasury.transfer(address(nrc), address(treasury).balance);
        vm.stopPrank();
    }

    function testTransferByOwnerToReceiver() public {
        assert(address(receiver1).balance == 0);

        vm.prank(owner);
        treasury.transfer(receiver1, address(treasury).balance);
        vm.stopPrank();

        assert(address(receiver1).balance == address(treasury).balance);
    }
}