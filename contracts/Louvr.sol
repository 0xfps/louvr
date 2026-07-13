// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import { Tiers, ILouvrWhitelist } from "./interfaces/ILouvrWhitelist.sol";

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { Ownable2Step, Ownable } from "@openzeppelin/contracts/access/Ownable2Step.sol";

contract Louvr is ERC721, Ownable2Step {
    ILouvrWhitelist public louvrWhitelist;

    uint16 public totalMinted;
    uint16 public maxMintId = 2026;
    address public louvrTreasury;
    bool public canListOnSecondaryMarket;

    string internal BASE_URI;

    mapping(address user => uint16 numberMinted) public mintCount;

    error BaseURIAlreadySet();
    error CannotListOnSecondaryMarketYet();
    error CurrentTierNotMinting();
    error MintIdAboveLimit(uint256 id);
    error MintLimitReached(uint256 mintLimit);
    error NFT0Inexistent();
    error RefundFailed(address to, uint256 refund);
    error TreasuryFundFailed();

    receive() external payable {}

    constructor(
        string memory name, string memory symbol,
        address _louvrTreasury, address _louvrWhitelist,
        address owner
    ) ERC721 (name, symbol)
      Ownable (owner) {
        louvrTreasury = _louvrTreasury;
        louvrWhitelist = ILouvrWhitelist(_louvrWhitelist);
    }

    function mint(uint256 id, address receiver) public payable {
        // Verify you're not minting ID 0. It doesn't exist.
        if(id == 0) revert NFT0Inexistent();
        // Verify that the id stays between 1 and 2026.
        if (id > maxMintId) revert MintIdAboveLimit(id);

        // Verify if user's tier are the ones currently minting.
        if (!louvrWhitelist.usersTierCurrentlyMinting(msg.sender)) revert CurrentTierNotMinting();

        // Get minter whitelist tier.
        Tiers tier = louvrWhitelist.whitelistTiers(msg.sender);
        // Verify that you're not minting more than your limit.
        // Public 2,026, FCFS 2, GTD 2.
        uint16 limit = louvrWhitelist.getTierMintLimit(tier);
        if (mintCount[msg.sender] >= limit) revert MintLimitReached(limit);

        // Get NFT mint price to pay in ETH.
        uint256 mintPriceETH = louvrWhitelist.getWhiteListPrice(msg.sender);

        // Calculate balance.
        uint256 balance = msg.value - louvrWhitelist.getWhiteListPrice(msg.sender);

        // Send mint price to treasury.
        (bool fundStatus,) = louvrTreasury.call{value: mintPriceETH}("");
        if(!fundStatus) revert TreasuryFundFailed();

        // Back to sender the balance.
        (bool refundStatus,) = msg.sender.call{ value: balance }("");
        if (!refundStatus) revert RefundFailed(msg.sender, balance);

        // Increase total minted and user's mint count.
        ++totalMinted;
        ++mintCount[msg.sender];

        // Mint NFT.
        _safeMint(receiver, id);
    }

    function transferFrom(address from, address to, uint256 tokenId) public override {
        if (!canListOnSecondaryMarket) revert CannotListOnSecondaryMarketYet();
        super.transferFrom(from, to, tokenId);
    }

    function turnOnSecondaryMarket() public onlyOwner {
        canListOnSecondaryMarket = true;
    }

    function setBaseUri(string memory baseURI) public onlyOwner {
        if (bytes(BASE_URI).length != 0) revert BaseURIAlreadySet();
        BASE_URI = baseURI;
    }

    function _baseURI() internal view override returns (string memory) {
        return BASE_URI;
    }
}