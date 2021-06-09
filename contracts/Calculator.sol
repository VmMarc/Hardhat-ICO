// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IToken.sol";

contract Calculator {
    IToken private _token;
    address private _owner;

    event Added(address indexed user, int256 nb1, int256 nb2, int256 result);
    event Subtracted(address indexed user, int256 nb1, int256 nb2, int256 result);
    event Multiplied(address indexed user, int256 nb1, int256 nb2, int256 result);
    event Divided(address indexed user, int256 nb1, int256 nb2, int256 result);
    event Modulo(address indexed user, int256 nb1, int256 nb2, int256 result);

    constructor(address firstTokenAddress, address owner_) {
        _token = FirstToken(firstTokenAddress);
        _owner = owner_;
        _price = 1 wei;
    }

    modifier rightPayment() {
        require(_token.allowance(msg.sender, address(this)) >= 1 wei,"Calculator: you need to approve this smart contract for at least 1 token before using it");
        require(_token.balanceOf(msg.sender) >= 1 wei,"Calculator: you do not have enough token to use this function");
        _token.transferFrom(msg.sender, _owner, _price);
        _;
    }

    function add(int256 nb1, int256 nb2) public rightPayment()returns (int256) {
        emit Added(msg.sender, nb1, nb2, nb1 + nb2);
        return nb1 + nb2;
    }

    function sub(int256 nb1, int256 nb2) public rightPayment() returns (int256) {
        emit Subtracted(msg.sender, nb1, nb2, nb1 - nb2);
        return nb1 - nb2;
    }

    function mul(int256 nb1, int256 nb2) public rightPayment() returns (int256) {
        emit Multiplied(msg.sender, nb1, nb2, nb1 * nb2);
        return nb1 * nb2;
    }

    function div(int256 nb1, int256 nb2) public rightPayment() returns (int256) {
        require(nb2 != 0, "Calculator: can not divide by zero");
        emit Divided(msg.sender, nb1, nb2, nb1 / nb2);
        return nb1 / nb2;
    }


    function mod(int256 nb1, int256 nb2) public rightPayment() returns (int256) {
        require(nb2 != 0, "Calculator: can not modulus by zero");
        emit Modulo(msg.sender, nb1, nb2, nb1 % nb2);
        return nb1 % nb2;
    }


    function owner() public view returns (address) {
        return _owner;
    }

    function price() public pure returns (uint256) {
        return _price;
    }
}
