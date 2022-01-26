// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract mintNFT is ERC721URIStorage {

    uint256 public _tokensIds = 1;

    constructor() ERC721("Marketplace", "TST") {}

    function createNewToken
    (
        string memory tokenURI
    )
    public
    returns (uint256)
    {
        uint256 newTokenId = _tokensIds++;

        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        return newTokenId;
    }
}