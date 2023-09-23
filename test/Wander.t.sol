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

    function testCreatePromotion() public {
        vm.prank(alice);
        wander.createPromotion();
    }

}
