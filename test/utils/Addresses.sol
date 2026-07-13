// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

contract Addresses is Test {
    address owner = vm.addr(0x01);

    address badGuy1 = vm.addr(0x02);
    address badGuy2 = vm.addr(0x03);

    address goodGuy1 = vm.addr(0x04);
    address goodGuy2 = vm.addr(0x05);
    address goodGuy3 = vm.addr(0x06);
    address goodGuy4 = vm.addr(0x07);

    address receiver1 = vm.addr(0x08);
    address receiver2 = vm.addr(0x09);

    constructor() {
        vm.deal(owner, 1 ether);
        vm.deal(badGuy1, 1 ether);
        vm.deal(badGuy2, 1 ether);
        vm.deal(goodGuy1, 1 ether);
        vm.deal(goodGuy2, 1 ether);
    }
}