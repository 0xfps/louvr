// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import { Tiers, ILouvrWhitelist } from "../contracts/interfaces/ILouvrWhitelist.sol";

import {console} from "forge-std/console.sol";
import { Addresses } from "./utils/Addresses.sol";
import { LouvrWhitelist } from "../contracts/LouvrWhitelist.sol";

contract LouvrWhitelistTest is Addresses {
    LouvrWhitelist internal whitelist;
    ILouvrWhitelist.WhiteListConfig[] internal config;

    constructor() {
        config.push(ILouvrWhitelist.WhiteListConfig(goodGuy1, Tiers.PUBLIC));
        config.push(ILouvrWhitelist.WhiteListConfig(goodGuy2, Tiers.GUARANTEED));
        config.push(ILouvrWhitelist.WhiteListConfig(goodGuy3, Tiers.FIRST_COME_FIRST_SERVE));
        config.push(ILouvrWhitelist.WhiteListConfig(goodGuy4, Tiers.NONE));
        whitelist = new LouvrWhitelist(config, owner);
    }

    function testPrices() public view {
        assert(whitelist.getWhiteListPrice(goodGuy1) == whitelist.PUBLIC_PRICE());
        assert(whitelist.getWhiteListPrice(goodGuy2) == whitelist.GUARANTEED_PRICE());
        assert(whitelist.getWhiteListPrice(goodGuy3) == whitelist.FIRST_COME_FIRST_SERVE_PRICE());
        assert(whitelist.getWhiteListPrice(goodGuy4) == type(uint256).max);
    }

    function testSetNewTierByNonOwner(address badGuy) public {
        assert(whitelist.currentTier() == Tiers.NONE);

        vm.assume(badGuy != owner);
        vm.prank(badGuy);
        vm.expectRevert();
        whitelist.setNewTier(Tiers.GUARANTEED);
        vm.stopPrank();
    }

    function testSetNewTierByOwner() public {
        assert(whitelist.currentTier() == Tiers.NONE);

        vm.prank(owner);
        whitelist.setNewTier(Tiers.GUARANTEED);
        vm.stopPrank();

        assert(whitelist.currentTier() == Tiers.GUARANTEED);
    }

    function testMintLimits() public view {
        assert(whitelist.getTierMintLimit(whitelist.whitelistTiers(goodGuy1)) == whitelist.PUBLIC_MINT_LIMIT());
        assert(whitelist.getTierMintLimit(whitelist.whitelistTiers(goodGuy2)) == whitelist.GUARANTEED_MINT_LIMIT());
        assert(whitelist.getTierMintLimit(whitelist.whitelistTiers(goodGuy3)) == whitelist.FIRST_COME_FIRST_SERVE_MINT_LIMIT());
        assert(whitelist.getTierMintLimit(whitelist.whitelistTiers(goodGuy4)) == 0);
    }

    function testUserCurrentlyMinting() public {
        // When tier == None.
        vm.prank(owner);
        whitelist.setNewTier(Tiers.NONE);
        vm.stopPrank();

        assert(whitelist.usersTierCurrentlyMinting(goodGuy1) == false);
        assert(whitelist.usersTierCurrentlyMinting(goodGuy2) == false);
        assert(whitelist.usersTierCurrentlyMinting(goodGuy3) == false);
        // Wildcard, no one will be none.

        // When tier == GTD.
        vm.prank(owner);
        whitelist.setNewTier(Tiers.GUARANTEED);
        vm.stopPrank();

        assert(whitelist.usersTierCurrentlyMinting(goodGuy1) == false);
        assert(whitelist.usersTierCurrentlyMinting(goodGuy2) == true);
        assert(whitelist.usersTierCurrentlyMinting(goodGuy3) == false);
        assert(whitelist.usersTierCurrentlyMinting(goodGuy4) == false);

        // When tier == FCFS.
        vm.prank(owner);
        whitelist.setNewTier(Tiers.FIRST_COME_FIRST_SERVE);
        vm.stopPrank();

        assert(whitelist.usersTierCurrentlyMinting(goodGuy1) == false);
        assert(whitelist.usersTierCurrentlyMinting(goodGuy2) == false);
        assert(whitelist.usersTierCurrentlyMinting(goodGuy3) == true);
        assert(whitelist.usersTierCurrentlyMinting(goodGuy4) == false);

        // When tier == public.
        vm.prank(owner);
        whitelist.setNewTier(Tiers.PUBLIC);
        vm.stopPrank();

        assert(whitelist.usersTierCurrentlyMinting(goodGuy1) == true);
        assert(whitelist.usersTierCurrentlyMinting(goodGuy2) == true);
        assert(whitelist.usersTierCurrentlyMinting(goodGuy3) == true);
        assert(whitelist.usersTierCurrentlyMinting(goodGuy4) == true);
    }
}