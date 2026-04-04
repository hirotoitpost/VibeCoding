// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title VibeCodingToken
 * @dev ERC-20 token implementation for VibeCoding DApp
 * 
 * Features:
 * - Standard ERC-20 interface
 * - Burnable: token holders can burn their tokens
 * - Ownable: owner has special privileges
 */
contract VibeCodingToken is ERC20, ERC20Burnable, Ownable {
    // Initial supply: 1,000,000 tokens (18 decimals = 10^24 wei)
    uint256 public constant INITIAL_SUPPLY = 1_000_000 * 10 ** 18;

    constructor() ERC20("VibeCoding Token", "VBC") Ownable(msg.sender) {
        _mint(msg.sender, INITIAL_SUPPLY);
    }
}
