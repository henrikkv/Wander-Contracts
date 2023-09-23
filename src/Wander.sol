//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

// Useful for debugging. Remove when deploying to a live network.
//import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "forge-std/console2.sol";

// Use openzeppelin to inherit battle-tested implementations (ERC20, ERC721, etc)
// import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * A smart contract that allows changing a state variable of the contract and tracking the changes
 * It also allows the owner to withdraw the Ether in the contract
 * @author BuidlGuidl
 */
contract Wander is ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _promotionIds;

    struct Promotion {
        uint endTimestamp;
        string[] tiers;
        mapping(address => uint256) customerCurrTier;
        mapping(address => uint256) customerTotalSpent;
        uint256[] tierAmountsNeccessary;
        uint256 initialized;
    }
    mapping(uint256 => Promotion)public promotions;
    mapping(address => uint256) public vendorToPromotionId;
    mapping(uint256 => uint256) public tokenIdToPromotionId;

    constructor() ERC721("Wander", "WOW") {}

    function getTiers(uint256 promotionId) public view onlyOwner returns (string[] memory) {
        return promotions[promotionId].tiers;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://";
    }

    function sendEther(address vendorAddress) public payable {
        uint256 promotionId = vendorToPromotionId[vendorAddress];
        Promotion storage promotion = promotions[promotionId];
        require(
            promotion.initialized == 1,
            "VENDOR NOT PART OF ANY PROMOTION"
        );
        address buyer = msg.sender;
        uint256 amt = msg.value;
        uint256 newItemId = _tokenIds.current();
        if (promotion.customerTotalSpent[buyer] == 0) {
            _mint(buyer, newItemId);
            tokenIdToPromotionId[newItemId] = promotionId;
        }
        promotion.customerTotalSpent[buyer] += amt;

        while (promotion.customerCurrTier[buyer] < promotion.tiers.length -1) {
            if (promotion.customerTotalSpent[buyer] > promotion.tierAmountsNeccessary[promotion.customerCurrTier[buyer]+1]) {
                promotion.customerCurrTier[buyer]++;
            }
            else {break;}
        }
        
        promotion.customerCurrTier[buyer]++;
        _tokenIds.increment();

        payable(vendorAddress).transfer(msg.value);
    }

    function createPromotion(
        string[] memory tiers,
        uint256[] memory tierAmountsNecessary,
        uint duration
    ) external {
        require(block.timestamp > promotions[vendorToPromotionId[msg.sender]].endTimestamp, "ERROR - Promotion is still active!");

        

        promotions[_promotionIds.current()].endTimestamp = block.timestamp + duration * 1 days;
        promotions[_promotionIds.current()].tiers = tiers;
        promotions[_promotionIds.current()].tierAmountsNeccessary = tierAmountsNecessary;
        promotions[_promotionIds.current()].initialized = 1;
        _promotionIds.increment();
    }
}
