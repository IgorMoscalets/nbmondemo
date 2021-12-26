//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "../BEP721/BEP721.sol";
import "./MarketplaceCore.sol";
import "../security/Pausable.sol";
import "../security/Ownable.sol";

/// @title Clock auction for non-fungible tokens.
abstract contract Marketplace is Pausable, Ownable, MarketplaceCore {
    constructor(address _nftContract, uint256 _fee) {
        require(_fee <= 10000, "Marketplace: Fee specified does not meet requirements");
        auctionFee = _fee;
        BEP721 candidateContract = BEP721(_nftContract);
        nftContract = candidateContract;
    }

    function createAuction(
        uint256 _tokenId,
        uint128 _startingPrice,
        uint128 _endingPrice,
        uint64 _duration,
        address _seller
    ) public whenNotPaused {
        _seller = _msgSender();
        require(_owns(_seller, _tokenId), "Marketplace: Seller specified does not own the NFT");
        _escrow(_seller, _tokenId);
        Auction memory _auction = Auction(
            _seller,
            _startingPrice,
            _endingPrice,
            _duration,
            block.timestamp
        );
        _addAuction(_tokenId, _auction, _seller);
    }

    function bid(uint256 _tokenId) public payable whenNotPaused {
        _bid(_tokenId, msg.value);
        _transfer(_msgSender(), _tokenId);
    }

    function cancelAuction(uint256 _tokenId) public {
        Auction storage auction = auctions[_tokenId];
        require(_isOnAuction(auction), "Marketplace: Specified token ID is not on auction");
        address seller = auction.seller;
        require(_msgSender() == seller, "Marketplace: Specified seller is not msg.sender");
        _cancelAuction(_tokenId, seller);
    }

    function cancelAuctionWhenPaused(uint256 _tokenId) public whenPaused onlyOwner  {
        Auction storage auction = auctions[_tokenId];
        require(_isOnAuction(auction), "Marketplace: Specified token ID is not on auction");
        _cancelAuction(_tokenId, auction.seller);
    }

    function getAuction(uint256 _tokenId) public view returns (
        address _seller,
        uint128 _startingPrice,
        uint128 _endingPrice,
        uint64 _duration,
        uint256 _startedAt
    ) {
        Auction storage _auction = auctions[_tokenId];
        require(_isOnAuction(_auction), "Marketplace: Specified token ID is not on auction");
        return (
            _auction.seller,
            _auction.startingPrice,
            _auction.endingPrice,
            _auction.duration,
            _auction.startedAt
        );
    }
    
    function getCurrentPrice(uint256 _tokenId) public view returns (uint256) {
        Auction storage _auction = auctions[_tokenId];
        require(_isOnAuction(_auction), "Marketplace: Specified token ID is not on auction");
        return _currentPrice(_auction);
    }

    



} 