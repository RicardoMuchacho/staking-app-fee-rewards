// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract StakingApp is Ownable {
    uint256 public stakingFixedAmount = 10 ether;
    uint256 public stakingPeriod = 1 days;
    address public stakingToken;
    mapping(address => uint256) public userBalance;
    mapping(address => uint256) public lastActivity;

    event stakeEvent(uint256);
    event withdrawEvent(uint256);
    event rewardsClaimEvent(uint256);
    event depositRewardsEvent(uint256);

    constructor(address _owner, address _stakingToken) Ownable(_owner) {
        stakingToken = _stakingToken;
    }

    // deposit token
    function stakeTokens(uint256 _amount) external {
        require(_amount == stakingFixedAmount, "Amount must be 10 ETH");
        require(userBalance[msg.sender] == 0, "Already staking");

        lastActivity[msg.sender] = block.timestamp;

        IERC20(stakingToken).transferFrom(msg.sender, address(this), _amount);
        userBalance[msg.sender] += _amount;

        emit stakeEvent(_amount);
    }

    // withdraw
    function withdraw() external {
        uint256 currentBalance = userBalance[msg.sender];
        //Checks
        require(currentBalance == stakingFixedAmount, "No stake");

        //Effects
        userBalance[msg.sender] = 0;

        //Interactions
        IERC20(stakingToken).transfer(msg.sender, currentBalance);

        emit withdrawEvent(currentBalance);
    }

    // claim rewards
    function claimRewards() external {
        require(userBalance[msg.sender] == stakingFixedAmount, "No stake");
        require(
            block.timestamp - lastActivity[msg.sender] >= stakingPeriod, "Staking period not ended"
        );

        uint256 reward = userBalance[msg.sender] / 100; // 1% daily reward

        (bool success,) = msg.sender.call{ value: reward }("");
        if (!success) revert();

        emit rewardsClaimEvent(reward);
    }

    function changeStakingPeriod(uint256 _period) external onlyOwner {
        stakingPeriod = _period;
    }

    // deposit rewards
    receive() external payable onlyOwner {
        emit depositRewardsEvent(msg.value);
    }
}
