// contracts/MyNFT.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFT is ERC721, ERC721Enumerable, Ownable {
    constructor() ERC721("MyNFT", "MNFT") {}

    function mint(address to, uint256 tokenId) public onlyOwner {
        _mint(to, tokenId);
    }
}

contract MyNFTMarket is Ownable {
    struct Sale {
        uint256 tokenId;
        address seller;
        uint256 price;
        bool active;
    }

    mapping(uint256 => Sale) public tokenIdToSale;

    MyNFT private nft;

    event SaleCreated(
        uint256 indexed tokenId,
        address indexed seller,
        uint256 price
    );
    event SaleCancelled(uint256 indexed tokenId);
    event SaleCompleted(
        uint256 indexed tokenId,
        address indexed buyer,
        uint256 price
    );

    constructor(address _nftAddress) {
        nft = MyNFT(_nftAddress);
    }

    function createSale(uint256 tokenId, uint256 price) external {
        require(
            nft.ownerOf(tokenId) == msg.sender,
            "Not the owner of the token"
        );
        require(
            nft.getApproved(tokenId) == address(this),
            "Not approved for sale"
        );

        tokenIdToSale[tokenId] = Sale(tokenId, msg.sender, price, true);
        emit SaleCreated(tokenId, msg.sender, price);
    }

    function cancelSale(uint256 tokenId) external {
        require(
            tokenIdToSale[tokenId].seller == msg.sender,
            "Not the seller of the token"
        );
        delete tokenIdToSale[tokenId];
        emit SaleCancelled(tokenId);
    }

    function buy(uint256 tokenId) external payable {
        Sale memory sale = tokenIdToSale[tokenId];
        require(sale.active, "Sale not active");
        require(msg.value >= sale.price, "Insufficient funds");

        address seller = sale.seller;
        delete tokenIdToSale[tokenId];
        payable(seller).transfer(msg.value);
        nft.safeTransferFrom(seller, msg.sender, tokenId);
        emit SaleCompleted(tokenId, msg.sender, sale.price);
    }
}
