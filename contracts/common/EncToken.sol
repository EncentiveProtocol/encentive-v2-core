// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract EncToken is ERC20 {
    /// @param name_ should be less than 32 char
    /// @param symbol_ should be less than 32 char
    /// @param amount amount of coin mint.
    /// @param to address that receives coins.
    constructor(string memory name_, string memory symbol_, uint amount, address to) ERC20(name_, symbol_){
       require(to != address(0),'Invalid to adr');
       _mint(to, amount);
    }    
}
