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
        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);

        vm.prank(alice);
        wander = new Wander();

    }

    function testCreatePromotionOneTier() public {
        vm.prank(alice);
        string[] memory hashes = new string[](1);
        hashes[0] = "ipfsipfsipfsipfsipfsipfsipfs";
        uint256[] memory tierAmounts = new uint256[](1);
        tierAmounts[0] = uint256(1 ether);
        wander.createPromotion(hashes, tierAmounts, 1);
    }

    function testCreatePromotionThreeTier() public {
        vm.prank(alice);
        string[] memory hashes = new string[](3);
        hashes[0] = "ipfsipfsipfsipfsipfsipfsipfs";
        hashes[1] = "ipfsipfsipfsipfsipfsipfsipfs";
        hashes[2] = "ipfsipfsipfsipfsipfsipfsipfs";
        uint256[] memory tierAmounts = new uint256[](3);
        tierAmounts[0] = uint256(1 ether);
        tierAmounts[1] = uint256(2 ether);
        tierAmounts[2] = uint256(10 ether);
        wander.createPromotion(hashes, tierAmounts, 1);
    }
    function testOneTierSpend() public {
        vm.prank(alice);
        string[] memory hashes = new string[](1);
        hashes[0] = "ipfsipfsipfsipfsipfsipfsipfs";
        uint256[] memory tierAmounts = new uint256[](1);
        tierAmounts[0] = uint256(1 ether);
        wander.createPromotion(hashes, tierAmounts, 1);
        vm.prank(bob);
        wander.sendEther(alice);
    }

}