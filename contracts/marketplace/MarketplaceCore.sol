//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "../BEP721/BEP721.sol";
import "../security/Context.sol";
import "../BEP721/IBEP721Receiver.sol";

/**
 * @dev Base contract for any contracts inheriting it to perform similar marketplace mechanisms
 */
abstract contract MarketplaceCore is Context {
    struct Auction {
        // address of the current owner of the NFT to be sold (the seller)
        address seller;
        // starting price (in wei) of the NFT to be sold
        uint128 startingPrice;
        // ending price (in wei) of the NFT to be sold
        uint128 endingPrice;
        // duration (in seconds) of the auction
        uint64 duration;
        // time when auction is started
        // Note: 0 when auction is concluded
        uint256 startedAt;
    }

    // contract of the NFT to be sold (e.g. NBMon contract)
    BEP721 public nftContract;

    // fee for each auction, measured in basis points (1/100th of a percent)
    // Values 0 - 10000 map to 0 -100%
    uint256 public auctionFee;

    // mapping from a token id to the corresponding auction
    mapping (uint256 => Auction) public auctions;

    event AuctionCreated(
        address indexed _nftContract,
        uint256 indexed _tokenId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        address _seller
    );

    event AuctionSuccessful(
        address indexed _nftContract,
        uint256 indexed _tokenId,
        uint256 _endingPrice,
        address _winner
    );

    event AuctionCancelled(
        address _nftContract,
        uint256 _tokenId
    );


    /// @dev Returns true if the claimant owns the token.   
    /// @param _claimant - Address claiming to own the token.
    /// @param _tokenId - ID of token whose ownership to verify.    
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return (nftContract.ownerOf(_tokenId) == _claimant);
    }

    /// @dev Escrows the NFT, assigning ownership to this contract.
    /// Throws if the escrow fails.
    /// @param _owner - Current owner address of token to escrow.
    /// @param _tokenId - ID of token whose approval to verify.
    function _escrow(address _owner, uint256 _tokenId) internal {
        nftContract.safeTransferFrom(_owner, address(this), _tokenId);
    }

    /// @dev Transfers an NFT owned by this contract to another address.
    /// Returns true if the transfer succeeds.
    /// @param _to - Address to transfer NFT to.
    /// @param _tokenId - ID of token to transfer.
    function _transfer(address _to, uint256 _tokenId) internal {
        nftContract.safeTransfer(address(this), _to, _tokenId,"");
    }

    function _addAuction(uint256 _tokenId, Auction memory _auction, address _seller) internal {
        require(_auction.duration >= 1 minutes, "MarketplaceCore: Auction duration must be at least 1 minute");
        auctions[_tokenId] = _auction;
        emit AuctionCreated(
            address(nftContract),
            _tokenId,
            _auction.startingPrice,
            _auction.endingPrice,
            _auction.duration,
            _seller
        );
    } 

    function _cancelAuction(uint256 _tokenId, address _seller) internal {
        _removeAuction(_tokenId);
        _transfer(_seller, _tokenId);
        emit AuctionCancelled(
            address(nftContract),
            _tokenId
        );
    }

    function _computeFee(uint256 _price) internal view returns (uint256) {
        return _price * auctionFee / 10000;
    }

    /// @dev Computes the price and transfers winnings.
    /// Does NOT transfer ownership of token.
    function _bid(uint256 _tokenId, uint256 _bidAmount) internal returns (uint256) {
        // Get a reference to the auction struct
        Auction storage _auction = auctions[_tokenId];

        // Explicitly check that this auction is currently live.
        // (Because of how Ethereum mappings work, we can't just count
        // on the lookup above failing. An invalid _tokenId will just
        // return an auction object that is all zeros.)
        require(_isOnAuction(_auction), "MarketplaceCore: Specified token ID is not on auction");

        // Check that the incoming bid is higher than the current
        // price
        uint256 _price = _currentPrice(_auction);
        require(_bidAmount >= _price, "MarketplaceCore: Bid amount is less than price");

        // Grab a reference to the seller before the auction struct
        // gets deleted.
        address payable _seller = payable(_auction.seller);

        // The bid is good! Remove the auction before sending the fees
        // to the sender so we can't have a reentrancy attack.
        _removeAuction(_tokenId);

        // Transfer proceeds to seller (if there are any!)
        if (_price > 0) {
        //  Calculate the auctioneer's cut.
        uint256 _auctioneerCut = _computeFee(_price);
        uint256 _sellerProceeds = _price - _auctioneerCut;

        // NOTE: Doing a transfer() in the middle of a complex
        // method like this is generally discouraged because of
        // reentrancy attacks and DoS attacks if the seller is
        // a contract with an invalid fallback function. We explicitly
        // guard against reentrancy attacks by removing the auction
        // before calling transfer(), and the only thing the seller
        // can DoS is the sale of their own asset! (And if it's an
        // accident, they can call cancelAuction(). )
        _seller.transfer(_sellerProceeds);
        }

        emit AuctionSuccessful(address(nftContract), _tokenId, _price, _msgSender());

        return _price;
    }

    /// @dev Removes an auction from the list of open auctions.
    /// @param _tokenId - ID of NFT on auction.
    function _removeAuction(uint256 _tokenId) internal {
        delete auctions[_tokenId];
    }

    /// @dev Returns true if the NFT is on auction.
    /// @param _auction - Auction to check.
    function _isOnAuction(Auction storage _auction) internal view returns (bool) {
        return (_auction.startedAt > 0);
    }

    /// @dev Returns current price of an NFT on auction. Broken into two
    ///  functions (this one, that computes the duration from the auction
    ///  structure, and the other that does the price computation) so we
    ///  can easily test that the price computation works correctly.
    function _currentPrice(Auction storage _auction) internal view returns (uint256) {
        uint256 secondsPassed = 0;

        return _computeCurrentPrice(
            _auction.startingPrice,
            _auction.endingPrice,
            _auction.duration,
            secondsPassed
        );
    }

    /// @dev Computes the current price of an auction. Factored out
    ///  from _currentPrice so we can run extensive unit tests.
    ///  When testing, make this function public and turn on
    ///  `Current price computation` test suite.
    function _computeCurrentPrice(
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        uint256 _secondsPassed
    )
        internal
        pure
        returns (uint256)
    {
        if (_secondsPassed >= _duration) {
            // We've reached the end of the dynamic pricing portion
            // of the auction, just return the end price.
            return _endingPrice;
        } else {
            // Starting price can be higher than ending price (and often is!), so
            // this delta can be negative.
            int256 totalPriceChange = int256(_endingPrice) - int256(_startingPrice);
            int256 currentPriceChange = totalPriceChange * int256(_secondsPassed) / int256(_duration);
            // currentPriceChange can be negative, but if so, will have a magnitude
            // less that _startingPrice. Thus, this result will always end up positive.
            int256 currentPrice = int256(_startingPrice) + currentPriceChange;
            
            return uint256(currentPrice);
        }
    }
}