## Bloque 6 - Staking App


### ERC20 not native token transfers

- transfer     = direct transfers, user to destination address
- transferFrom = user calls the SC and it takes the tokens from the user and transfers them to itself or other destination. It can only take the approve() amount of tokens 

### Concepts

unchecked: used to disable aithmetich over/under flow errors, only use when sure of the  