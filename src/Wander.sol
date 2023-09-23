// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Wander is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct Promotion {
        uint endTimestamp;
        string[] tiers;
        mapping(address => uint256) customerCurrTier;
        mapping(address => uint256) customerTotalSpent;
        uint256[] tierAmountsNeccessary;
        uint256 initialized;
//        address[] admins;
    }
    Promotion[] public promotions;
    mapping(address => Promotion) public vendorToPromotion;

    constructor() ERC721("Wander", "WOW") {}

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://";
    }

    function sendEther(address vendorAddress) public payable {
        uint256 amtSent = msg.value;
	require(vendorToPromotion[vendorAddress].initialized == 1, "VENDOR NOT PART OF ANY PROMOTION");
        sendToVendor(vendorAddress, msg.sender, amtSent);
    } 

    function sendToVendor(address to, address buyer, uint256 amt) private {
        (bool sent,) = to.call{value: amt}("");
        require(sent, "Failed to send Ether");
        uint256 newItemId = _tokenIds.current();
        _mint(buyer, newItemId);
        Promotion storage promotion = vendorToPromotion[to];
        promotion.customerTotalSpent[buyer]+=amt;
        //Not equal 0 check to make sure does not go into infinite loop since later values that are not set I think default to 0 which would be less than
        while(promotion.customerCurrTier[buyer]+1<promotion.customerTotalSpent[buyer] && promotion.customerCurrTier[buyer]+1 != 0) {
            promotion.customerCurrTier[buyer]++;
        }
        _setTokenURI(newItemId, promotion.tiers[promotion.customerCurrTier[buyer]]); //setting tokenURI to corresponding tier URI
        promotion.customerCurrTier[buyer]++;
        _tokenIds.increment();
    }

    
    function createPromotion(string[] memory tiers, uint256[] memory tierAmountsNecessary, uint duration) external {
        Promotion storage promotion = vendorToPromotion[msg.sender];
        
        if (promotion.initialized == 1) {
            require(promotion.endTimestamp < block.timestamp, "ERROR - Promotion has not expired yet!");
        }
        
        promotion.endTimestamp = block.timestamp + duration * 1 days;
        promotion.tiers = tiers;
        // mapping(address => uint256) customerCurrTier;
        promotion.tierAmountsNeccessary = tierAmountsNecessary;
        promotion.initialized = 1;
    }
}

