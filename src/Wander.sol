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
        uint256[] tierAmountsNeccessary;
        int256 initialized;
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

        sendToVendor(vendorAddress, msg.sender, amtSent);
    } 

    function sendToVendor(address to, address buyer, uint256 amt) private {
        (bool sent,) = to.call{value: amt}("");
        require(sent, "Failed to send Ether");
        uint256 newItemId = _tokenIds.current();
        _mint(buyer, newItemId);
        Promotion storage promotion = vendorToPromotion[to];
        _setTokenURI(newItemId, promotion.tiers[promotion.customerCurrTier[buyer]]); //setting tokenURI to corresponding tier URI
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

