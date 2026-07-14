// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TransferrableToken is ERC20("TransferrableToken", "TT") {
    constructor(address owner) {
        _mint(owner, 10 ether);
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        super.transfer(to, amount);
        return true;
    }
}