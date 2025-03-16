// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract StakingToken is ERC20 {

  constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol){

  }

  function mint(uint256 tokenAmount) public {
    _mint(msg.sender, tokenAmount);
  }

} 