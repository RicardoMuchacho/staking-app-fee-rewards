# ⚖️ Staking App

Solidity staking app built with [Foundry](https://book.getfoundry.sh/). The project includes:

- **Staking App Contract**: Allows users to stake tokens, withdraw their stake, and claim rewards.
- **Staking Token Contract**: An ERC20 token used for staking.
- **100% Test Coverage** ensuring reliable functionality and security.

## 📊 Contracts Overview

### StakingApp.sol
This contract handles staking logic, withdrawals, and reward claims.

| Function             | Description                                           |
|---------------------|-------------------------------------------------------|
| `stakeTokens(uint256 _amount)`  | Allows users to stake tokens with a fixed amount of 10 ETH. |
| `withdraw()`                   | Allows users to withdraw their staked tokens.                |
| `claimRewards()`               | Enables users to claim their accumulated rewards.             |
| `changeStakingPeriod(uint256 _period)` | Allows the owner to modify the staking period.               |
| `receive()`                    | Allows the owner to deposit ETH as staking rewards.           |

### StakingToken.sol
This ERC20 token contract represents the staking token.

| Function             | Description                                           |
|---------------------|-------------------------------------------------------|
| `constructor(string memory _name, string memory _symbol)`  | Deploys the ERC20 token with a specified name and symbol. |
| `mint(uint256 tokenAmount)` | Mints new tokens and assigns them to the caller's address.      |

## ✅ Testing Coverage

| File                 | % Lines | % Statements | % Branches | % Funcs |
|----------------------|----------|---------------|-------------|----------|
| src/StakingApp.sol    | 100.00% (26/26) | 100.00% (23/23)       | 100.00% (11/11)    | 100.00% (6/6) |
| src/StakingToken.sol  | 100.00% (2/2) | 100.00% (1/1)       | 100.00% (0/0)    | 100.00% (1/1) |
| **Total**             | **100.00%** | **100.00%** | **100.00%** | **100.00%** |

## ⚙️ How to Run the Project

### Prerequisites
- Install Foundry: [Foundry Installation Guide](https://book.getfoundry.sh/getting-started/installation.html)

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

