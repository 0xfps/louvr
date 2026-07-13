// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import { Tiers, ILouvrWhitelist } from "./interfaces/ILouvrWhitelist.sol";

import { Ownable2Step, Ownable } from "@openzeppelin/contracts/access/Ownable2Step.sol";

contract LouvrWhitelist is ILouvrWhitelist, Ownable2Step {
    mapping(address whitelistedUser => Tiers tier) public whitelistTiers;

    uint256 public constant PUBLIC_PRICE = 0.007 ether;
    uint256 public constant FIRST_COME_FIRST_SERVE_PRICE = 0.00588 ether;
    uint256 public constant GUARANTEED_PRICE = 0.0047 ether;

    uint16 public constant PUBLIC_MINT_LIMIT = 2026;
    uint16 public constant FIRST_COME_FIRST_SERVE_MINT_LIMIT = 2;
    uint16 public constant GUARANTEED_MINT_LIMIT = 2;

    Tiers public currentTier = Tiers.NONE;

    constructor(WhiteListConfig[] memory config, address owner) Ownable (owner) {
        whitelist(config);
    }

    function whitelist(WhiteListConfig[] memory config) public onlyOwner {
        uint256 length = config.length;

        for (uint256 i; i < length; ++i) {
            address user = config[i].user;
            Tiers tier = config[i].tier;

            if (whitelistTiers[user] == Tiers.PUBLIC)
                whitelistTiers[user] = tier;
        }
    }

    function getWhiteListPrice(address whitelistedUser) public view returns (uint256 price) {
        Tiers whitelistedUserTier = whitelistTiers[whitelistedUser];

        if (whitelistedUserTier == Tiers.PUBLIC) price = PUBLIC_PRICE;
        if (whitelistedUserTier == Tiers.FIRST_COME_FIRST_SERVE) price = FIRST_COME_FIRST_SERVE_PRICE;
        if (whitelistedUserTier == Tiers.GUARANTEED) price = GUARANTEED_PRICE;
        price = type(uint256).max;
    }

    function setNewTier(Tiers tier) public onlyOwner {
        currentTier = tier;
    }

    function getTierMintLimit(Tiers tier) public view returns (uint16 limit) {
        // If public mint is on, return max limit, if not, check for category limit.
        if (currentTier == Tiers.PUBLIC) limit = PUBLIC_MINT_LIMIT;

        if (tier == Tiers.PUBLIC) limit = PUBLIC_MINT_LIMIT;
        if (tier == Tiers.FIRST_COME_FIRST_SERVE) limit = FIRST_COME_FIRST_SERVE_MINT_LIMIT;
        if (tier == Tiers.GUARANTEED) limit = GUARANTEED_MINT_LIMIT;
        else limit = 0;
    }

    function usersTierCurrentlyMinting(address whitelistedUser) public view returns (bool) {
        // If public mint is on, all can mint, if not, check for eligibility.
        return (currentTier == Tiers.PUBLIC) || whitelistTiers[whitelistedUser] == currentTier;
    }
}