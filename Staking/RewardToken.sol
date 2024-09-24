// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Reward_token is ERC20, ERC20Permit, Ownable {
    constructor(address initialOwner)
        ERC20("Reward_Token", "RTK")
        ERC20Permit("Reward_token")
        Ownable(initialOwner)
    {
        _mint(msg.sender, 10000 * 10 ** decimals());
    }
}
