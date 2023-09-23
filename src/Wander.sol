// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Wander is ERC721 {
    constructor() ERC721("Wander", "WOW") {}

    function _baseURI() internal pure override returns (string memory) {
        return "https://";
    }
}

