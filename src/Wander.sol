//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

// Useful for debugging. Remove when deploying to a live network.
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Use openzeppelin to inherit battle-tested implementations (ERC20, ERC721, etc)
// import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * A smart contract that allows changing a state variable of the contract and tracking the changes
 * It also allows the owner to withdraw the Ether in the contract
 * @author BuidlGuidl
 */
contract Wander is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct Promotion {
        uint endTimestamp;
        string[] tiers;
        mapping(address => uint256) customerCurrTier;
        mapping(address => uint256) customerTotalSpent;
        uint256[] tierAmountsNeccessary; // Just FYI, 'necessary' is misspelled (should have only one c).
        uint256 initialized;
        address donationAddress;
        uint256 donationAmount; // amount to be donated as a decimal (i.e., 0.5% donated would be '0.0005').
    }
    mapping(address => Promotion) public vendorToPromotion;

    constructor() ERC721("Wander", "WOW") {}

    function getTiers() public view onlyOwner returns (string[] memory) {
        return vendorToPromotion[msg.sender].tiers;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://";
    }

    function setDonationAddress public (address _charityAddress) {
        require(vendorToPromotion[msg.sender].exists, "The sender has no promotion");
        // fromZach: for now, this function allows any merchant who is part of a promotion to call this function.
        // I think that's fine... assuming that merchants who are already cooperating are collegial is not airtight, but it's not critically breaking.
        vendorToPromotion[msg.sender].donationAddress = _charityAddress;
    }

    function setDonationAmount public (uint256 _amount) {
        require(vendorToPromotion[msg.sender].exists, "The sender has no promotion");
        // This line checks that the donation amount isn't super high.
        // Intention is to avoid user error where donation eclipses merchant savings from taking crypto.
        require(_amount <= 0.03, "You're attempting to set a very high donation amount. Please input the donation amount as a decimal. For example, if you want to donate 1% of the payment, set the value to 0.01. If you are sure you're inputting correctly, use setDonationAmountBig().");
        vendorToPromotion[msg.sender].donationAmount = _amount;
    }

    function setDonationAmountBig public (uint256 _amount) {
        // This does the same thing as setDonationAmount but doesn't include a check for a reasonable donation amount.
        require(vendorToPromotion[msg.sender].exists, "The sender has no promotion");
        vendorToPromotion[msg.sender].donationAmount = _amount;
    }

    function sendEther(address vendorAddress) public payable {
        require(
            vendorToPromotion[vendorAddress].initialized == 1,
            "VENDOR NOT PART OF ANY PROMOTION"
        );
        address buyer = msg.sender;
        // These lines split the ETH received into two streams: one to the merchant and one to the charity.
        uint256 merchantAmt = msg.value * (1-vendorToPromotion[vendorAddress].donationAmount);
        uint256 charityAmt = msg.value * vendorToPromotion[vendorAddress].donationAmount;
        payable(vendorAddress).transfer(merchantAmt);
        payable(vendorToPromotion[vendorAddress].donationAddress).transfer(charityAmt);
        uint256 newItemId = _tokenIds.current();
        Promotion storage promotion = vendorToPromotion[vendorAddress];
        if (promotion.customerTotalSpent[buyer] == 0) _mint(buyer, newItemId);
        promotion.customerTotalSpent[buyer] += amt;
        //Not equal 0 check to make sure does not go into infinite loop since later values that are not set I think default to 0 which would be less than
        while (
            promotion.customerCurrTier[buyer] + 1 <
            promotion.customerTotalSpent[buyer] &&
            promotion.customerCurrTier[buyer] + 1 != 0
        ) {
            promotion.customerCurrTier[buyer]++;
        }
        _setTokenURI(
            newItemId,
            promotion.tiers[promotion.customerCurrTier[buyer]]
        ); //setting tokenURI to corresponding tier URI
        promotion.customerCurrTier[buyer]++;
        _tokenIds.increment();
    }

    function createPromotion(
        string[] memory tiers,
        uint256[] memory tierAmountsNecessary,
        uint duration
    ) external {
        Promotion storage promotion = vendorToPromotion[msg.sender];

        if (promotion.initialized == 1) {
            require(
                promotion.endTimestamp < block.timestamp,
                "ERROR - Promotion has not expired yet!"
            );
        }

        promotion.endTimestamp = block.timestamp + duration * 1 days;
        promotion.tiers = tiers;
        console.log(promotion.tiers[0]);
        // mapping(address => uint256) customerCurrTier;
        promotion.tierAmountsNeccessary = tierAmountsNecessary;
        promotion.initialized = 1;
    }
}
