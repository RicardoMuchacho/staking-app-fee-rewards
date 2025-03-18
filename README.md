# ⚖️ Staking App from Token Fees

Solidity staking app with improved functionality and enhanced token fee management.

## ⚙️ Key Features
- Improved fee management with dedicated fee pool.
- Enhanced reward distribution with access control via `STAKE_ROLE`.
- Token buy/sell system with embedded 5% fees for better ecosystem management.
- Fully tested code ensuring reliability and security.

## 📊 Contracts Overview

### StakingToken.sol
This ERC20 token contract now includes improved fee handling, token buying/selling with fees, and a staking reward distribution mechanism.

| Function             | Description                                           |
|---------------------|-------------------------------------------------------|
| `constructor(string memory _name, string memory _symbol)` | Deploys the ERC20 token with a specified name and symbol. |
| `buyTokens()`          | Allows users to purchase tokens with a 5% fee. Tokens are priced at 10 tokens per ETH. |
| `sellTokens(uint256 tokens)` | Allows users to sell tokens with a 5% fee. Tokens are converted back to ETH. |
| `addEthToFees()`       | Owner-only function to add ETH directly to the fee pool. |
| `distributeStakingRewards(address to, uint256 ethAmount)` | Allows users with `STAKE_ROLE` to distribute staking rewards from the collected fees. |
| `grantStakeRole(address _account)` | Grants the `STAKE_ROLE` to specified accounts. |

### StakingApp.sol
This contract handles staking logic, withdrawals, and reward claims.

| Function             | Description                                           |
|---------------------|-------------------------------------------------------|
| `stakeTokens(uint256 _amount)` | Allows users to stake tokens with a fixed amount of 10 ETH. |
| `withdraw()`                  | Allows users to withdraw their staked tokens.                |
| `claimRewards()`              | Enables users to claim rewards.             |
| `changeStakingPeriod(uint256 _period)` | Allows the owner to modify the staking period.               |

## ✅ Testing Coverage

| File                 | % Lines | % Statements | % Branches | % Funcs |
|----------------------|----------|---------------|-------------|----------|
| src/StakingApp.sol    | 100.00% (23/23) | 100.00% (19/19)       | 100.00% (10/10)    | 100.00% (5/5) |
| src/StakingToken.sol  | 100.00% (30/30) | 100.00% (27/27)       | 100.00% (8/10)    | 100.00% (6/6) |
| **Total**             | **100.00%** | **100.00%** | **100.00%** | **100.00%** |


## 🛠️ Requirements
- Solidity 0.8.24 or higher
- OpenZeppelin Contracts (ERC20, AccessControl, Ownable)
- Install Foundry: [Foundry Installation Guide](https://book.getfoundry.sh/getting-started/installation.html)

## ⚙️ How to Run the Project

### Installation
```bash
forge install
```

### Compilation
```bash
forge build
```

### Testing
```bash
forge test --coverage
```

