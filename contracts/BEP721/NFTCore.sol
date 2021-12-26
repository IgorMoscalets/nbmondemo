//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./BEP721URIStorage.sol";
import "./BEP721Enumerable.sol";

abstract contract NFTCore is BEP721URIStorage, BEP721Enumerable {
    string private baseTokenURI;
    /**
     * @dev Sets the Base URI
     */
    function _baseURI() internal view virtual override returns (string memory) {
         return baseTokenURI;
    }
    
    /**
     * @dev Changes the current Base URI. 
     * Only callable by Admin or CEO of contract.
     */
    function setBaseURI(string memory newBaseURI) public onlyAdminOrCEO {
        baseTokenURI = newBaseURI;
    }

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) public view virtual override(BEP721, BEP721URIStorage) returns (string memory) {
        return BEP721URIStorage.tokenURI(tokenId);
    }

    /**
     * @dev See {BEP721Enumerable-_beforeTokenTransfer}.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(BEP721, BEP721Enumerable) {
        BEP721Enumerable._beforeTokenTransfer(from, to, tokenId);
    }

    /**
     *@dev See {BEP721URIStorage-_burn}.
     */
    function _burn(uint256 tokenId) internal virtual override(BEP721, BEP721URIStorage) {
        BEP721URIStorage._burn(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(BEP721, BEP721Enumerable) returns (bool) {
        return interfaceId == type(BEP721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }
}