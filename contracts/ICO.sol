// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Token.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";


contract ICO is Ownable {
    using Address for address payable;

    FirstToken private _token;
    mapping(address => uint256) private _balances;
    address _contractOwner;
    uint256 _rate;
    uint256 _contractStart;
    uint256 _contractEnd;

    event Withdrew(address indexed owner, uint256 profit);
    event Bought(address indexed sender, uint256 amount, uint256 tokenPrice);
    event withdrewToken(address indexed sender, uint256 amount);

    constructor (address firstTokenAddress, address owner_) {
        _contractOwner = owner_;
        _token = FirstToken(firstTokenAddress);
        _rate = 10**9;
        _contractStart = block.timestamp;
        _contractEnd = _contractStart + 2 weeks;
    }

    receive() external payable {
        _buy(msg.sender, msg.value);
    }

    function buyTokens() public payable {
        _buy(msg.sender, msg.value);
    }

    function withdrawAll() public onlyOwner {
        require (address(this).balance > 0 ,"ICO (withdrawAll): No profit yet.");
        require (block.timestamp >= _contractEnd, "ICO (withdrawAll): Cannot withdraw yet.");
        uint256 profit = address(this).balance;
        payable(msg.sender).sendValue(profit);
        emit Withdrew(msg.sender, profit);
    }

    function withdrawToken() public {
        require(_balances[msg.sender] > 0 ,"ICO (withdrawToken): No Tokens to withdraw.");
        require(block.timestamp >= _contractEnd, "ICO (withdrawToken): Cannot withdraw Tokens yet.");
        uint256 amount = _balances[msg.sender];
        _balances[msg.sender] = 0;
        _token.transfer(msg.sender, amount);
        emit withdrewToken(msg.sender, amount);
    }

    function _buy(address sender, uint256 amount) private {
        require(block.timestamp < _contractEnd, "ICO (buy): Contract is closed.");
        require(amount <= tokensLeft(), "ICO (buy): Not enough Tokens");
        uint256 tokenPrice = amount * _rate;
        _balances[sender] += amount;
        _token.transferFrom(_token.owner(), sender, tokenPrice);
        emit Bought(msg.sender, amount, tokenPrice);
    }

    function tokensLeft() public view returns (uint256) {
        return _token.allowance(_token.owner(), address(this));
    }

    function rate() public view returns (uint256) {
        return _rate;
    }

    function total() public view returns (uint256) {
        return address(this).balance;
    }
}
