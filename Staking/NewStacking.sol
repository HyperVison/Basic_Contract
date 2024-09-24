// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Staking is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    IERC20 private stakingToken;
    IERC20 private rewardToken;

    bool public timestampSet;
    uint256 public lockingPeriod;
    uint256 public rewardRate;

    mapping(address => uint256) public startTime;
    mapping(address => uint256) public withdrawn;
    mapping(address => uint256) public stackedBalance;

    event TokenStacked(address indexed from, uint256 amount);
    event TokenUnstacked(address indexed to, uint amount);
    event RewardsClaimed(address stacker, uint256 reward);

    constructor(IERC20 _tokenAddress, IERC20 _rewardToken, uint256 _rewardRate) Ownable(msg.sender) {
        stakingToken = _tokenAddress;
        rewardToken = _rewardToken;
        rewardRate = _rewardRate;
    }

    modifier timestampIsSet() {
        require(timestampSet == true, "Please set the time stamp first, then try again.");
        _;
    }

    function setTimestamp(uint256 _timePeriodInSeconds) public onlyOwner {
        timestampSet = true;
        lockingPeriod = _timePeriodInSeconds;
    }

    function stakeTokens(uint256 amount) external timestampIsSet nonReentrant {
        require(amount > 0, "Cannot stake zero tokens");
        require(amount <= stakingToken.balanceOf(msg.sender), "Not enough tokens to stake");
        bool success = stakingToken.transferFrom(msg.sender, address(this), amount);
        require(success, "Token transfer failed");

        stackedBalance[msg.sender] = stackedBalance[msg.sender].add(amount);
        startTime[msg.sender] = block.timestamp;
        emit TokenStacked(msg.sender, amount);
    }

    function unstakeToken(uint256 amount) external nonReentrant timestampIsSet {
        require(amount > 0, "Cannot unstake zero tokens");
        require(stackedBalance[msg.sender] >= amount, "Staked amount not enough");
        require(block.timestamp >= startTime[msg.sender].add(lockingPeriod), "Tokens are still locked");

        uint256 rewardAmount = calculateReward(amount);
        require(rewardToken.balanceOf(address(this)) >= rewardAmount, "Not enough reward tokens in contract");

        stackedBalance[msg.sender] = stackedBalance[msg.sender].sub(amount);
        withdrawn[msg.sender] = withdrawn[msg.sender].add(amount);

        stakingToken.transfer(msg.sender, amount);
        rewardToken.transfer(msg.sender, rewardAmount);
        
        emit TokenUnstacked(msg.sender, amount);
        emit RewardsClaimed(msg.sender, rewardAmount);
    }

    function calculateReward(uint256 stakeAmount) internal view returns (uint256) {
        return stakeAmount.mul(rewardRate).div(100);  //reward rate = 10 Stacking token per 1 reward Token 
    }

    // Admin function to deposit reward tokens into the contract
    function depositRewardTokens(uint256 amount) external onlyOwner {
        require(amount > 0, "Cannot deposit zero tokens");
        bool success = rewardToken.transferFrom(msg.sender, address(this), amount);
        require(success, "Reward token transfer failed");
    }
}
