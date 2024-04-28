// contracts/MyNFT.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFT is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    uint256 private _nextTokenId;

    constructor(
        address initialOwner
    ) ERC721("MyNFT", "MNFT") Ownable(initialOwner) {}

    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // The following functions are overrides required by Solidity.

    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override(ERC721, ERC721Enumerable) returns (address) {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(
        address account,
        uint128 value
    ) internal override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, value);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
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
