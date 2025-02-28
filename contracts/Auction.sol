// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IERC721Receiver } from "@openzeppelin/contracts/interfaces/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Interfaces
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { IAuctionErrors } from "./interfaces/IAuctionErrors.sol";
        
contract Auction is 
        Ownable, 
        IAuctionErrors,
        IERC721Receiver {
    IERC20 public usdcToken;


    /**
     * @dev Constructor for Auction Contract
     * @param _initialOwner Address of the initial owner.
     * @param _usdcToken Address of the USDC token contract.
     */
    constructor(
        address _initialOwner,
        IERC20 _usdcToken
    ) Ownable (_initialOwner) {
        usdcToken = _usdcToken;
    }

    struct AuctionItem {
        address nftAddress;
        uint256 tokenId;
        uint256 biddingEndTime;
        address highestBidder;
        uint256 highestBid;
        bool auctionEnded;
        address auctionCreator;
    }

    mapping(uint256 auctionId => AuctionItem) public auctions;
    mapping(address highestBidderAddress => mapping(uint256 auctionId => uint256 highestBid)) public bids;
    uint256 public auctionCounter;

    // Events
    event AuctionCreated(
        uint auctionId,
        address nftAddress,
        uint256 tokenId,
        uint256 biddingEndTime
    );
    event BidPlaced(
        uint256 auctionId,
        address bidder,
        uint256 amount
    );
    event AuctionEnded(
        uint256 auctionId,
        address winner,
        uint256 amount
    );

    /**
     * @dev Creates a new auction for an ERC721 token.
     * @param nftAddress Address of the ERC721 token contract.
     * @param tokenId ID for the token to be auctioned
     * @param duration Duration of the auction in seconds.
     * @return auctionId The ID of the created auction.
     */
    function createAuction(
        address nftAddress,
        uint256 tokenId,
        uint256 duration
    ) external returns (uint256) {
        auctionCounter += 1;
        uint256 auctionId = auctionCounter;

        IERC721(nftAddress).safeTransferFrom(
            msg.sender,
            address(this), 
            tokenId
        );

        uint256 biddingEndTime = block.timestamp + duration;
        auctions[auctionId] = AuctionItem({
            nftAddress: nftAddress,
            tokenId: tokenId,
            biddingEndTime: biddingEndTime,
            highestBidder: address(0),
            highestBid: 0,
            auctionEnded: false,
            auctionCreator: msg.sender
        });
        
        emit AuctionCreated(
            auctionId,
            nftAddress,
            tokenId,
            biddingEndTime
        );
        return auctionId;
    }

    /**
     * @dev Places a bid on an auction using USDC
     * @param _auctionId The ID of the auctionto bid on. 
     * @param _usdcAmount The amount of USDC to bid.
     */
    function placeBid(
        uint256 _auctionId,
        uint256 _usdcAmount
    ) external {
        AuctionItem storage auction = auctions[_auctionId];

        if (block.timestamp > auction.biddingEndTime) 
            revert BiddingIsEnded(auction.biddingEndTime);
        

        if (_usdcAmount < auction.highestBid)
            revert BidShouldBeHigher(auction.highestBid);

        usdcToken.transferFrom(msg.sender, address(this), _usdcAmount);

        bids[msg.sender][auction.tokenId] += _usdcAmount;

        auction.highestBidder = msg.sender;
        auction.highestBid = _usdcAmount;
        emit BidPlaced(_auctionId, msg.sender, _usdcAmount);
    }

    /**
     * @dev Ends an auction and transfers the NFT to the highest bidder 
     * @dev Gives a USDC balance to the auction creator as equal as the highest bid. 
     * @param _auctionId The ID of the auction to end. 
     */
    function endAuction(uint256 _auctionId) external {
        AuctionItem storage auction = auctions[_auctionId];

        if (block.timestamp < auction.biddingEndTime)
            revert BiddingDidNotEnd(auction.biddingEndTime);
        
        if (auction.auctionEnded) revert AuctionAlreadyEnded();

        auction.auctionEnded = true;

        bids[auction.highestBidder][_auctionId] -= auction.highestBid;

        IERC721(auction.nftAddress).safeTransferFrom(
            address(this), 
            auction.highestBidder, 
            auction.tokenId
        );

        usdcToken.transfer(auction.auctionCreator, auction.highestBid);

        emit AuctionEnded(
            _auctionId, 
            auction.highestBidder,
            auction.highestBid
        );
    }

    /**
     * @dev Withdraws USDC bids from a specific auction.
     * @param _auctionId The ID of the auction to withdraw from.
     */
    function withdraw(uint256 _auctionId) external {
        AuctionItem storage auction = auctions[_auctionId];

        if (!auction.auctionEnded) revert AuctionDidNotEnd();

        uint256 amount = bids[msg.sender][_auctionId];

        if (amount == 0) revert NoFundsToWithdraw();
        bids[msg.sender][_auctionId] = 0;

        // Transfer USDC token to Auction Creator
        usdcToken.transfer((msg.sender), amount);
    }

    /**
     * @dev Handles the receipt of an ERC721 token.
     * @return bytes4 The selector of the onERC721Received function.
     */
    function onERC721Received(
        address, 
        address, 
        uint256, 
        bytes calldata
    ) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}