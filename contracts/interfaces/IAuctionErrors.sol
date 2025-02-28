// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @dev Interface defining standard auction errors. 
 */

interface IAuctionErrors {
    /**
     * @dev Error indicating that the bidding period for the auction has ended.
     * @param biddingEndTime The time when the bidding period ended.
     */
    error BiddingIsEnded(uint256 biddingEndTime);

    /**
     * @dev Error indicating that the bidding period for the auction has not yet ended.
     * @param biddingEndTime The time when the bidding period ended.
     */
    error BiddingDidNotEnd(uint256 biddingEndTime);

    /**
     * @dev Error indicating that the auction has already ended
     */
    error AuctionAlreadyEnded();

    /**
     * @dev Error indicating that the auction did not end yet.
     */
    error AuctionDidNotEnd();

    /**
     * @dev Error indicating that the bid amount is not higher than the current highest bid.
     * @param highestBid The current highest bid in the auction
     */
    error BidShouldBeHigher(uint256 highestBid);

    /**
     * @dev Error indicating that there are no funds to withdraw for the caller.
     */
    error NoFundsToWithdraw();
}