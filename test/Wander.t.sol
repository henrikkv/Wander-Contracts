// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Wander.sol";

contract WanderTest is Test {
    Wander public wander;

    address alice;
    address bob;
    address charlie;

    function setUp() public {
        alice = vm.addr(1);
        bob = vm.addr(2);
        charlie = vm.addr(3);
        vm.deal(alice, 100 ether);
        vm.deal(bob, 100 ether);
        vm.deal(charlie, 100 ether);

        vm.prank(alice);
        wander = new Wander();

    }

    function testCreatePromotionOneTier() public {
        string[] memory hashes = new string[](1);
        hashes[0] = "ipfsipfsipfsipfsipfsipfsipfs";
        uint256[] memory tierAmounts = new uint256[](1);
        tierAmounts[0] = uint256(1 ether);
        vm.prank(alice);
        wander.createPromotion(hashes, tierAmounts, 1, alice, 10);
    }

    function testCreatePromotionThreeTier() public {
        string[] memory hashes = new string[](3);
        hashes[0] = "ipfsipfsipfsipfsipfsipfsipfs";
        hashes[1] = "ipfsipfsipfsipfsipfsipfsipfs";
        hashes[2] = "ipfsipfsipfsipfsipfsipfsipfs";
        uint256[] memory tierAmounts = new uint256[](3);
        tierAmounts[0] = uint256(1 ether);
        tierAmounts[1] = uint256(2 ether);
        tierAmounts[2] = uint256(10 ether);
        vm.prank(alice);
        wander.createPromotion(hashes, tierAmounts, 3, alice, 10);
    }
    function testOneTierSpend() public {
        string[] memory hashes = new string[](1);
        hashes[0] = "ipfsipfsipfsipfsipfsipfsipfs";
        uint256[] memory tierAmounts = new uint256[](1);
        tierAmounts[0] = uint256(1 ether);
        vm.prank(alice);
        wander.createPromotion(hashes, tierAmounts, 1, alice, 30);
        vm.prank(bob);
        wander.sendEther{value: 1 ether}(alice);
    }
    function testAddAndRemove() public {
        string[] memory hashes = new string[](2);
        hashes[0] = "ipfsipfsipfsipfsipfsipfsipfs";
        hashes[1] = "ipfsipfsipfsipfsipfsipfsipfs";
        uint256[] memory tierAmounts = new uint256[](2);
        tierAmounts[0] = uint256(1 ether);
        tierAmounts[1] = uint256(3 ether);
        vm.prank(alice);
        wander.createPromotion(hashes, tierAmounts, 2, alice, 1);
        vm.prank(alice);
        wander.addVendor(bob);
        vm.prank(charlie);
        wander.sendEther{value: 2 ether}(bob);
        require(wander.balanceOf(charlie) == 1);
        
        vm.prank(charlie);
        wander.sendEther{value: 2 ether}(bob);
        require(wander.balanceOf(charlie) == 1);

        vm.prank(charlie);
        wander.sendEther{value: 2 ether}(alice);
        require(wander.balanceOf(charlie) == 1);

        vm.prank(charlie);
        wander.sendEther{value: 2 ether}(alice);
        require(wander.balanceOf(charlie) == 1);
    }

}