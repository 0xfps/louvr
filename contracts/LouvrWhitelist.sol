// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import { Tiers, ILouvrWhitelist } from "./interfaces/ILouvrWhitelist.sol";

import { Ownable2Step, Ownable } from "@openzeppelin/contracts/access/Ownable2Step.sol";

contract LouvrWhitelist is ILouvrWhitelist, Ownable2Step {
    mapping(address whitelistedUser => Tiers tier) public whitelistTiers;

    uint256 public constant PUBLIC_PRICE = 0.007 ether;
    uint256 public constant FIRST_COME_FIRST_SERVE_PRICE = 0.00588 ether;
    uint256 public constant GUARANTEED_PRICE = 0.0047 ether;

    uint8 public constant PUBLIC_MINT_LIMIT = 1;
    uint8 public constant FIRST_COME_FIRST_SERVE_MINT_LIMIT = 2;
    uint8 public constant GUARANTEED_MINT_LIMIT = 5;

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
        price = whitelistedUserTier == Tiers.GUARANTEED ? GUARANTEED_PRICE
                : whitelistedUserTier == Tiers.FIRST_COME_FIRST_SERVE ? FIRST_COME_FIRST_SERVE_PRICE
                : PUBLIC_PRICE;
    }

    function getTierMintLimit(Tiers tier) public pure returns (uint8 limit) {
        limit = tier == Tiers.PUBLIC ? 1
                : tier == Tiers.FIRST_COME_FIRST_SERVE ? 2
                : 5;
    }

    // @todo This function will be implemented soon.
    // CHECKS IF USER CAN MINT NFT BECAUSE SOME IDS ARE RESERVED.
    function userCanMintThis(address whitelistedUser, uint256 id) public view returns (bool) {
        whitelistedUser; id;
        return uint8(whitelistTiers[whitelistedUser]) >= 0;
    }
}