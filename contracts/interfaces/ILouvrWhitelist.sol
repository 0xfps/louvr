// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

enum Tiers {
    PUBLIC,
    FIRST_COME_FIRST_SERVE,
    GUARANTEED,
    NONE
}

interface ILouvrWhitelist {
    struct WhiteListConfig {
        address user;
        Tiers tier;
    }

    function getTierMintLimit(Tiers tier) external view returns (uint16 limit);
    
    function whitelistTiers(address whitelistedUser) external view returns (Tiers tiers);
    function getWhiteListPrice(address whitelistedUser) external view returns (uint256 price);
    function usersTierCurrentlyMinting(address whitelistedUser) external view returns (bool);
}