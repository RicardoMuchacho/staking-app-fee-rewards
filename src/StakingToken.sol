// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract StakingToken is ERC20, Ownable, AccessControl {
    uint256 public initSupply = 1_000_000 ether;
    uint256 public tokenPrice = 10; // 10 tokens = 1 ether
    uint256 public fees;
    uint256 public feePercentage = 5;

    bytes32 public constant STAKE_ROLE = keccak256("STAKE_ROLE");

    event buyTokensEvent(address buyer, uint256 tokens);
    event sellTokensEvent(address seller, uint256 tokens);
    event addEthToFeesEvent(uint256 amount);
    event distributeStakingRewardsEvent(address account, uint256 fees);

    constructor(string memory _name, string memory _symbol)
        ERC20(_name, _symbol)
        Ownable(msg.sender)
    {
        _mint(address(this), initSupply);
    }

    // Buy tokens with 5% fee
    function buyTokens() external payable returns (uint256 tokensBought, uint256 feesPaid) {
        feesPaid = msg.value * 5 / 100;
        tokensBought = (msg.value - feesPaid) * tokenPrice;

        require(balanceOf(address(this)) >= tokensBought, "Not enough tokens");

        fees += feesPaid;
        _transfer(address(this), msg.sender, tokensBought);

        emit buyTokensEvent(msg.sender, tokensBought);
    }

    // Sell tokens with 5% fee
    function sellTokens(uint256 tokens) external returns (uint256 ethAfterFee, uint256 feesPaid) {
        uint256 ethValue = tokens / tokenPrice;
        feesPaid = ethValue * 5 / 100;
        ethAfterFee = ethValue - feesPaid;

        require(balanceOf(msg.sender) >= tokens, "Not enough tokens to sell");

        fees += feesPaid;
        _transfer(msg.sender, address(this), tokens);

        (bool success,) = msg.sender.call{ value: ethAfterFee }("");
        require(success, "Transfer Failed");

        emit sellTokensEvent(msg.sender, ethAfterFee);
    }

    function addEthToFees() external payable onlyOwner {
        fees += msg.value;
        emit addEthToFeesEvent(msg.value);
    }

    function distributeStakingRewards(address to, uint256 ethAmount)
        external
        onlyRole(STAKE_ROLE)
    {
        require(ethAmount < fees, "Not enough eth");
        fees -= ethAmount;
        (bool success,) = to.call{ value: ethAmount }("");
        require(success, "Withdraw Failed");

        emit distributeStakingRewardsEvent(msg.sender, ethAmount);
    }

    function grantStakeRole(address _account) external onlyOwner {
        _grantRole(STAKE_ROLE, _account);
    }
}
