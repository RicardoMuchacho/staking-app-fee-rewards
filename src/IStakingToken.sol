// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.24;

import "./StakingToken.sol";

interface IStakingToken {
    function buyTokens() external payable;
    function sellTokens(uint256 tokens) external;
    function addEthToFees() external payable;
    function distributeStakingRewards(address to, uint256 ethAmount) external;
    function grantStakeRole() external;
}
