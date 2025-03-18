// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.24;

import "../src/StakingApp.sol";
import "../src/StakingToken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Test, console } from "forge-std/Test.sol";

contract StakingAppTest is Test {
    StakingApp stakingApp;
    StakingToken stakingToken;

    uint256 fixedStakingAmount;

    address owner = vm.addr(1);
    address randomUser = vm.addr(2);

    string symbol = "STK";
    string name = "Staking Test";

    function setUp() public {
        vm.startPrank(owner);
        stakingToken = new StakingToken(symbol, name);
        stakingApp = new StakingApp(owner, address(stakingToken));
        fixedStakingAmount = stakingApp.stakingFixedAmount();
        vm.stopPrank();
    }

    function test_contractsDeployed() external view {
        assert(address(stakingApp) != address(0));
        assert(address(stakingToken) != address(0));
    }

    // // stake tokens
    function test_stakeCorrectly() external {
        vm.startPrank(owner);

        buySTK(fixedStakingAmount, owner);

        uint256 userTokensBefore = stakingApp.userBalance(owner);
        uint256 lastActivityBefore = stakingApp.lastActivity(owner);
        IERC20(stakingToken).approve(address(stakingApp), fixedStakingAmount);
        //stakingToken.approve(address(stakingApp), fixedStakingAmount); //also works, simpler
        stakingApp.stakeTokens(fixedStakingAmount);
        uint256 userTokensAfter = stakingApp.userBalance(owner);
        uint256 lastActivityAfter = stakingApp.lastActivity(owner);

        assertEq(userTokensAfter - userTokensBefore, fixedStakingAmount);
        assertEq(lastActivityBefore, 0);
        assertEq(lastActivityAfter, block.timestamp);

        vm.stopPrank();
    }

    function test_revertStakeMoreThanOnce() external {
        vm.startPrank(owner);

        buySTK(fixedStakingAmount * 2, owner);

        IERC20(stakingToken).approve(address(stakingApp), fixedStakingAmount);
        stakingApp.stakeTokens(fixedStakingAmount);

        vm.expectRevert("Already staking");
        stakingApp.stakeTokens(fixedStakingAmount);

        vm.stopPrank();
    }

    function test_RevertStakeIncorrectAmount() external {
        vm.startPrank(owner);

        vm.expectRevert("Amount must be 10 ETH");
        stakingApp.stakeTokens(100);

        vm.stopPrank();
    }

    // withdraw tokens
    function test_withdraw() external {
        vm.startPrank(randomUser);

        buySTK(fixedStakingAmount, randomUser);
        IERC20(stakingToken).approve(address(stakingApp), fixedStakingAmount);
        stakingApp.stakeTokens(fixedStakingAmount);

        uint256 tokensBefore = stakingToken.balanceOf(randomUser);
        uint256 tokensStakedBefore = stakingApp.userBalance(randomUser);
        stakingApp.withdraw();
        uint256 tokensAfter = stakingToken.balanceOf(randomUser);

        assertEq(tokensBefore + tokensStakedBefore, tokensAfter);

        vm.stopPrank();
    }

    function test_revertWithdrawNoStake() external {
        vm.startPrank(randomUser);

        vm.expectRevert("No stake");
        stakingApp.withdraw();

        vm.stopPrank();
    }

    // claim rewards
    function test_claimRewards() external {
        // Grant Staking role to stakingApp contract
        vm.startPrank(owner);
        stakingToken.grantStakeRole(address(stakingApp));
        vm.stopPrank();

        vm.startPrank(randomUser);

        buySTK(fixedStakingAmount, randomUser);
        IERC20(stakingToken).approve(address(stakingApp), fixedStakingAmount);
        stakingApp.stakeTokens(fixedStakingAmount);

        uint256 ethBefore = randomUser.balance;
        uint256 ethFeesBefore = stakingToken.fees();
        vm.warp(block.timestamp + 1 days);
        stakingApp.claimRewards();
        uint256 ethAfter = randomUser.balance;
        uint256 ethFeesAfter = stakingToken.fees();

        uint256 rewards = stakingApp.userBalance(randomUser) / 100; // 1% daily reward
        assertEq(ethAfter - ethBefore, rewards);
        assertEq(ethFeesBefore - ethFeesAfter, rewards);
        console.log(ethFeesBefore, ethFeesAfter);

        vm.stopPrank();
    }

    function test_revertClaimRewardsNoStakeRole() external {
        vm.startPrank(randomUser);

        buySTK(fixedStakingAmount, randomUser);
        IERC20(stakingToken).approve(address(stakingApp), fixedStakingAmount);
        stakingApp.stakeTokens(fixedStakingAmount);

        vm.warp(block.timestamp + 1 days);
        vm.expectRevert();
        stakingApp.claimRewards();

        vm.stopPrank();
    }

    function test_revertClaimRewardsNoStake() external {
        vm.startPrank(randomUser);

        vm.expectRevert("No stake");
        stakingApp.claimRewards();

        vm.stopPrank();
    }

    function test_revertClaimRewardsInvalidPeriod() external {
        vm.startPrank(randomUser);

        buySTK(fixedStakingAmount, randomUser);
        IERC20(stakingToken).approve(address(stakingApp), fixedStakingAmount);
        stakingApp.stakeTokens(fixedStakingAmount);

        vm.expectRevert("Staking period not ended");
        stakingApp.claimRewards();

        vm.stopPrank();
    }

    // change staking period
    function test_revertChangeStakingPeriodNotOwner() external {
        vm.startPrank(randomUser);

        vm.expectRevert();
        stakingApp.changeStakingPeriod(2 hours);

        vm.stopPrank();
    }

    function test_changeStakingPeriod() external {
        vm.startPrank(owner);

        stakingApp.changeStakingPeriod(2 hours);
        assertEq(stakingApp.stakingPeriod(), 2 hours);

        vm.stopPrank();
    }

    function buySTK(uint256 _ethAmount, address _account) internal {
        vm.deal(_account, _ethAmount);
        stakingToken.buyTokens{ value: _ethAmount }();
    }
}
