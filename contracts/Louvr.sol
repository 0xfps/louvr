// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import { Tiers, ILouvrWhitelist } from "./interfaces/ILouvrWhitelist.sol";

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { Ownable2Step, Ownable } from "@openzeppelin/contracts/access/Ownable2Step.sol";

contract Louvr is ERC721, Ownable2Step {
    string internal BASE_URI;

    ILouvrWhitelist public louvrWhitelist;

    uint256 public totalMinted;
    uint256 public maxMintId = 2026;
    address public louvrTreasury;

    mapping(address user => uint256 numberMinted) public mintCount;

    error NFT0Inexistent();
    error MintIdAboveLimit(uint256 id);
    error MintLimitExceeded(uint256 mintLimit);
    error NFTReserved(uint256 id);
    error RefundFailed(address to, uint256 refund);
    error TreasuryFundFailed();

    receive() external payable {}

    constructor(
        string memory name, string memory symbol,
        string memory baseURI, address _louvrTreasury,
        address _louvrWhitelist, address owner
    ) ERC721 (name, symbol)
      Ownable (owner) {
        BASE_URI = baseURI;
        louvrTreasury = _louvrTreasury;
        louvrWhitelist = ILouvrWhitelist(_louvrWhitelist);
    }

    function mint(uint256 id, address receiver) public payable {
        // Verify you're not minting ID 0. It doesn't exist.
        if(id == 0) revert NFT0Inexistent();
        // Verify that the id stays between 1 and 2026.
        if (id > maxMintId) revert MintIdAboveLimit(id);

        // Verify that you're not minting more than your limit.
        // Public 1, FCFS 2, GTD 5.
        Tiers tier = louvrWhitelist.whitelistTiers(msg.sender);
        uint8 limit = louvrWhitelist.getTierMintLimit(tier);
        if (mintCount[msg.sender] >= limit) revert MintLimitExceeded(limit);

        // Some NFTs are reserved. Verify user can mint this one.
        if (!louvrWhitelist.userCanMintThis(msg.sender, id)) revert NFTReserved(id);

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
        _mint(receiver, id);
    }

    function _baseURI() internal view override returns (string memory) {
        return BASE_URI;
    }
}