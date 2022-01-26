// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Marketplace {
    uint public _itemIds = 0;
    uint public _itemsSold = 0;

    struct marketItem{
        uint itemId;
        address nftAddress;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
    }

    event marketItemCreated (
        uint indexed itemId,
        address indexed nftAddress,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price
    );

    mapping(uint256 => marketItem) public marketItemsList;

    function createMarketItem (address nftAddress, uint256 tokenId, uint256 price) public payable {
        require(price > 0, "Price value must be greater than 0");

        uint256 currentItemId = _itemIds++;

        marketItemsList[currentItemId] =  marketItem(
            currentItemId,
            nftAddress,
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            price
        );

        IERC721(nftAddress).transferFrom(msg.sender, address(this), tokenId);

        emit marketItemCreated(
            currentItemId,
            nftAddress,
            tokenId,
            msg.sender,
            address(0),
            price
        );
    }

    function saleMarketItem (address nftAddress, uint256 itemId) public payable {
        uint price = marketItemsList[itemId].price;
        uint currentTokenId = marketItemsList[itemId].tokenId;

        require(msg.value == price, "Your price does not match");

        marketItemsList[itemId].seller.transfer(msg.value);

        IERC721(nftAddress).transferFrom(address(this), msg.sender, currentTokenId);

        marketItemsList[itemId].owner = payable(msg.sender);
        _itemsSold++;
    }

    function removeMarketItem(address nftAddress, uint256 itemId) public payable {
        require(msg.sender == marketItemsList[itemId].seller, "You must be the owner of the token");

        uint currentTokenId = marketItemsList[itemId].tokenId;

        IERC721(nftAddress).transferFrom(address(this), msg.sender, currentTokenId);

        _itemIds -= 1;
        delete marketItemsList[itemId];
    }

    function getAllUnsoldMarketItems() public view returns (marketItem[] memory) {
        uint itemCount = _itemIds;
        uint unsoldItemCount = _itemIds - _itemsSold;
        uint currentIndex = 0;

        marketItem[] memory items = new marketItem[](unsoldItemCount);

        for (uint i = 0; i < itemCount; i++) {
            if (marketItemsList[i].owner == address(0)) {
                marketItem storage currentItem = marketItemsList[i];
                items[currentIndex] = currentItem;
                currentIndex++;
            }
        }
        return items;
    }

}