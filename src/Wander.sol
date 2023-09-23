// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Wander is ERC721 {
    struct Promotion {
        uint endTimestamp;
        string[] tiers;
        uint256[] tierAmountsNeccessary;
//        address[] admins;
    }
    Promotion[] public promotions;
    mapping(address => uint256) public vendorToPromotion;

    constructor() ERC721("Wander", "WOW") {}

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://";
    }

    function createPromotion(string[] memory tiers, uint duration) external {
        if (vendorToPromotion[msg.sender]) {
            require(vendorToPromotion[msg.sender].endTimestamp < block.timestamp);
        }
        Promotion memory promotion = new Promotion();
        promotion.endTimestamp = block.timestamp + duration * 1 days; 
//        promotions[]

    }
}

