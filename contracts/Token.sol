// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FirstToken is ERC20, Ownable {
    address private _owner;

    constructor( address owner_, uint256 totalSupply_) ERC20("FirstToken", "FTN") {
        _owner = owner_;
        _mint(_owner, totalSupply_*10**decimals());
    }

    function owner() public view override returns (address) {
        return _owner;
    }
}
