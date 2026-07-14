// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import { Addresses} from "./utils/Addresses.sol";
import { console } from "forge-std/console.sol";
import { LouvrTreasury } from "../contracts/LouvrTreasury.sol";
import { NonReceivingContract } from "./utils/NonReceivingContract.sol";
import { NonTransferrableToken } from "./utils/NonTransferrableToken.sol";
import { TransferrableToken } from "./utils/TransferrableToken.sol";

contract LouvrTreasuryTest is Addresses {
    LouvrTreasury internal treasury;
    NonReceivingContract internal nrc;
    NonTransferrableToken internal ntt;
    TransferrableToken internal tt;

    modifier fund() {
        vm.prank(goodGuy2);
        (bool sent,) = address(treasury).call{value: 0.9 ether}(""); sent;
        vm.stopPrank();

        _;
    }
    
    constructor() {
        treasury = new LouvrTreasury(owner);
        nrc = new NonReceivingContract();
        ntt = new NonTransferrableToken(address(treasury));
        tt = new TransferrableToken(address(treasury));
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

    function testTransferER20ByNonOwner() public {
        uint256 balance = tt.balanceOf(address(treasury));

        vm.startPrank(badGuy2);
        vm.expectRevert();
        treasury.transferERC20(address(tt), receiver1, balance);
        vm.stopPrank();
    }

    function testTransferER20ByOwnerToFalseReturningContract() public {
        uint256 balance = tt.balanceOf(address(treasury));

        vm.startPrank(owner);
        vm.expectRevert();
        treasury.transferERC20(address(ntt), receiver1, balance);
        vm.stopPrank();
    }

    function testTransferER20ByOwnerToTrueReturningContract() public {
        uint256 balance = tt.balanceOf(address(treasury));

        vm.startPrank(owner);
        treasury.transferERC20(address(tt), receiver1, balance);
        vm.stopPrank();
    }
}