// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.24;

import "../src/StakingToken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Test } from "forge-std/Test.sol";

contract StakingTokenTest is Test {
  StakingToken stakingToken;
  string name = "Staking Test";
  string symbol = "STK"; 

  address randomUser = vm.addr(2);
  function setUp() public {
     stakingToken = new StakingToken(name, symbol);
  }

  function test_mintCorrectly() public { 
    uint256 tokenAmount = 2 ether;

    vm.startPrank(randomUser);

    uint256 balanceBefore = IERC20(address(stakingToken)).balanceOf(randomUser);
    stakingToken.mint(tokenAmount);
    uint256 balanceAfter = stakingToken.balanceOf(randomUser); // better, stakingToken is already an ERC-20 instance

    assertEq(tokenAmount, balanceAfter - balanceBefore);

    vm.stopPrank();
  }
}