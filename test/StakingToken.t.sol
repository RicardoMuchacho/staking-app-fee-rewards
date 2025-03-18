// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.24;

import "../src/StakingToken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Test } from "forge-std/Test.sol";

contract StakingTokenTest is Test {
    StakingToken stakingToken;
    string name = "Staking Test";
    string symbol = "STK";

    address owner = vm.addr(1);
    address randomUser = vm.addr(2);
    address stakeUser = vm.addr(3);

    function setUp() public {
        vm.startPrank(owner);
        stakingToken = new StakingToken(name, symbol);
        vm.stopPrank();
    }

    function test_buyTokensCorrectly() public {
        uint256 ethValue = 2 ether;
        vm.deal(randomUser, ethValue);
        vm.startPrank(randomUser);

        uint256 balanceBefore = stakingToken.balanceOf(randomUser);
        uint256 feesBefore = stakingToken.fees();
        (uint256 tokensBought, uint256 feesPaid) = stakingToken.buyTokens{ value: ethValue }();
        uint256 balanceAfter = stakingToken.balanceOf(randomUser);
        uint256 feesAfter = stakingToken.fees();

        assertEq(tokensBought, balanceAfter - balanceBefore);
        assertEq(feesPaid, feesAfter - feesBefore);

        vm.stopPrank();
    }

    function test_revertBuyTokensNoSupply() public {
        uint256 ethValue = stakingToken.initSupply() + 1 ether;
        vm.deal(randomUser, ethValue);
        vm.startPrank(randomUser);

        vm.expectRevert();
        stakingToken.buyTokens{ value: ethValue }();

        vm.stopPrank();
    }

    function test_sellTokensCorrectly() public {
        uint256 ethValue = 2 ether;

        vm.deal(randomUser, 2 ether);
        vm.startPrank(randomUser);
        (uint256 tokensBought,) = stakingToken.buyTokens{ value: ethValue }();

        uint256 balanceBefore = stakingToken.balanceOf(randomUser);
        uint256 feesBefore = stakingToken.fees();
        uint256 ethBalanceBefore = randomUser.balance;

        (uint256 ethValueSold, uint256 sellFees) = stakingToken.sellTokens(tokensBought);

        uint256 balanceAfter = stakingToken.balanceOf(randomUser);
        uint256 feesAfter = stakingToken.fees();
        uint256 ethBalanceAfter = randomUser.balance;

        assertEq(balanceAfter, balanceBefore - tokensBought);
        assertEq(feesAfter, feesBefore + sellFees);
        assertEq(ethValueSold, ethBalanceAfter - ethBalanceBefore);

        vm.stopPrank();
    }

    function test_revertSellTokensMoreThanCurrent() public {
        uint256 ethValue = 2 ether;

        vm.deal(randomUser, 2 ether);
        vm.startPrank(randomUser);
        (uint256 tokensBought,) = stakingToken.buyTokens{ value: ethValue }();
        vm.expectRevert("Not enough tokens to sell");
        stakingToken.sellTokens(tokensBought + 1);

        vm.stopPrank();
    }

    function test_AddEthToFeesCorrectly() public {
        uint256 ethAmount = 2 ether;
        vm.deal(owner, ethAmount);
        vm.startPrank(owner);

        uint256 feesBefore = address(stakingToken).balance;
        stakingToken.addEthToFees{ value: ethAmount }();
        uint256 feesAfter = address(stakingToken).balance;

        assertEq(ethAmount, feesAfter - feesBefore);
        vm.stopPrank();
    }

    function test_revertAddEthToFeesNotOwner() public {
        uint256 ethAmount = 2 ether;
        vm.deal(randomUser, ethAmount);
        vm.startPrank(randomUser);

        vm.expectRevert();
        stakingToken.addEthToFees{ value: ethAmount }();

        vm.stopPrank();
    }

    function test_distributeStakingRewards() public {
        uint256 ethAmount = 2 ether;
        vm.deal(owner, ethAmount);
        vm.startPrank(owner);

        stakingToken.grantStakeRole(stakeUser);
        stakingToken.addEthToFees{ value: ethAmount }();

        vm.stopPrank();
        vm.startPrank(stakeUser);

        uint256 reward = 0.1 ether;
        uint256 balanceBefore = address(randomUser).balance;
        stakingToken.distributeStakingRewards(randomUser, reward);
        uint256 balanceAfter = address(randomUser).balance;

        assertEq(reward, balanceAfter - balanceBefore);

        vm.stopPrank();
    }

    function test_revertDistributeNoRewards() public {
        vm.startPrank(owner);

        stakingToken.grantStakeRole(stakeUser);

        vm.stopPrank();
        vm.startPrank(stakeUser);

        uint256 reward = 0.1 ether;
        vm.expectRevert("Not enough eth");
        stakingToken.distributeStakingRewards(randomUser, reward);

        vm.stopPrank();
    }

    function test_revertDistributeRewardsNoStakeRole() public {
        vm.startPrank(stakeUser);

        uint256 reward = 0.1 ether;
        vm.expectRevert();
        stakingToken.distributeStakingRewards(randomUser, reward);

        vm.stopPrank();
    }

    function test_grantStakeRoleCorrectly() public {
        vm.startPrank(owner);
        stakingToken.grantStakeRole(stakeUser);
        assertEq(stakingToken.hasRole(stakingToken.STAKE_ROLE(), stakeUser), true);
        vm.stopPrank();
    }
}
