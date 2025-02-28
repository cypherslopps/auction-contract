// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract USDCMockCoin is Ownable, ERC20 {
    constructor (
        address _initialOwner
    ) ERC20("USDC MOCK Coin", "USDCMock") Ownable(_initialOwner) {}

    function mint(
        address to, 
        uint256 amount
    ) public onlyOwner {
        _mint(to, amount);
    }

    function decimals() public pure override returns (uint8) {
        return 6;
    }
}