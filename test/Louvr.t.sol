// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import { Tiers, ILouvrWhitelist } from "../contracts/interfaces/ILouvrWhitelist.sol";

import { Addresses } from "./utils/Addresses.sol";
import { Louvr } from "../contracts/Louvr.sol";
import { LouvrTreasury } from "../contracts/LouvrTreasury.sol";
import { LouvrWhitelist } from "../contracts/LouvrWhitelist.sol";

contract LouvrTest is Addresses {
    Louvr internal louvr;
    LouvrTreasury internal treasury;
    LouvrWhitelist internal whitelist;
    ILouvrWhitelist.WhiteListConfig[] internal config;
    Louvr.PreMintConfig[] internal preMintConfig;
    
    modifier startGtdMint {
        vm.prank(owner);
        whitelist.setNewTier(Tiers.GUARANTEED);
        vm.stopPrank();
        _;
    }

    modifier startPublicMint {
        vm.prank(owner);
        whitelist.setNewTier(Tiers.PUBLIC);
        vm.stopPrank();
        _;
    }

    modifier startSecondaryListing {
        vm.prank(owner);
        louvr.turnOnSecondaryMarket();
        vm.stopPrank();
        _;
    }

    constructor() {
        config.push(ILouvrWhitelist.WhiteListConfig(goodGuy1, Tiers.PUBLIC));
        config.push(ILouvrWhitelist.WhiteListConfig(goodGuy2, Tiers.GUARANTEED));
        config.push(ILouvrWhitelist.WhiteListConfig(goodGuy3, Tiers.FIRST_COME_FIRST_SERVE));

        preMintConfig.push(Louvr.PreMintConfig(goodGuy4, 14));

        treasury = new LouvrTreasury(owner);
        whitelist = new LouvrWhitelist(config, owner);
        louvr = new Louvr("Louvr", "Louvr", address(treasury), address(whitelist), owner, preMintConfig);
    }

    function testDeployments() public view {
        assert(louvr.louvrTreasury() == address(treasury));
        assert(louvr.louvrWhitelist() == whitelist);
        assert(louvr.ownerOf(14) == goodGuy4);
    }

    function testSetBaseUriByNonOwner() public {
        vm.prank(badGuy1);
        vm.expectRevert();
        louvr.setBaseUri("ipfs://cid-here");
        vm.stopPrank();
    }

    function testSetBaseUri(string memory str) public {
        vm.prank(owner);
        louvr.setBaseUri(str);
        vm.stopPrank();
    }

    function testSetBaseUriByOwnerAfterSetting() public {
        vm.prank(owner);
        louvr.setBaseUri("ipfs://cid-here");
        vm.expectRevert();
        louvr.setBaseUri("ipfs://cid-here");
        vm.stopPrank();
    }

    function testTurnOnSecondaryMarketByNonOwner() public {
        assert(louvr.canListOnSecondaryMarket() == false);
        vm.prank(badGuy1);
        vm.expectRevert();
        louvr.turnOnSecondaryMarket();
        vm.stopPrank();
        assert(louvr.canListOnSecondaryMarket() == false);
    }

    function testTurnOnSecondaryMarketByOwner() public {
        assert(louvr.canListOnSecondaryMarket() == false);
        vm.prank(owner);
        louvr.turnOnSecondaryMarket();
        vm.stopPrank();
        assert(louvr.canListOnSecondaryMarket() == true);
    }

    function testMintZero() public {
        vm.prank(goodGuy1);
        vm.expectRevert();
        louvr.mint(0, receiver1);
        vm.stopPrank();
    }

    function testMintOver2026() public {
        vm.prank(goodGuy1);
        vm.expectRevert();
        louvr.mint(2027, receiver1);
        vm.stopPrank();
    }

    function testMintWhenInNone() public {
        vm.prank(goodGuy1);
        vm.expectRevert();
        louvr.mint(1, receiver1);
        vm.stopPrank();
    }

    function testMintOverLimit() public startGtdMint {
        uint256 price = whitelist.getWhiteListPrice(goodGuy2);

        vm.startPrank(goodGuy2);
        louvr.mint{ value: price }(1, receiver1);
        louvr.mint{ value: price }(2, receiver1);
        vm.expectRevert();
        louvr.mint{ value: price }(3, receiver1);
        vm.stopPrank();
    }

    function testMint() public startPublicMint {
        uint256 price = whitelist.getWhiteListPrice(goodGuy1);
        uint256 balanceBefore = goodGuy1.balance;
        uint16 totalMintedBefore = louvr.totalMinted();
        uint16 mintCountBefore = louvr.mintCount(goodGuy1);

        vm.startPrank(goodGuy1);
        louvr.mint{ value: price + 0.3 ether }(1, receiver2);
        vm.stopPrank();

        uint256 balanceAfter = goodGuy1.balance;
        uint16 totalMintedAfter = louvr.totalMinted();
        uint16 mintCountAfter = louvr.mintCount(goodGuy1);

        assert(balanceBefore - balanceAfter == price);
        assert(louvr.ownerOf(1) == receiver2);
        assert(totalMintedAfter - totalMintedBefore == 1);
        assert(mintCountAfter - mintCountBefore == 1);
    }

    function testMintAndTransferBeforePublicListing() public startPublicMint {
        uint256 price = whitelist.getWhiteListPrice(goodGuy1);

        vm.startPrank(goodGuy1);
        louvr.mint{ value: price + 0.3 ether }(1, goodGuy1);
        vm.expectRevert();
        louvr.transferFrom(goodGuy1, receiver1, 1);
        vm.stopPrank();
    }

    function testMintAndTransferAfterPublicListing() public startPublicMint startSecondaryListing {
        uint256 price = whitelist.getWhiteListPrice(goodGuy1);

        vm.startPrank(goodGuy1);
        louvr.mint{ value: price + 0.3 ether }(1, goodGuy1);
        louvr.transferFrom(goodGuy1, receiver1, 1);
        vm.stopPrank();

        assert(louvr.ownerOf(1) == receiver1);
    }
}