// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Token.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title My first ICO contract
 * @author Victor
 * @notice Contract uses ERC-20 token base, 
 * this contract is up for 2 weeks then the owner can withdraw profits.
 * this is also an early version I want to add a withdrawToken function
 * where the buyers could claim tokens when the sale's end.
 */

contract ICO is Ownable {
    using Address for address payable;

    FirstToken private _token;
    mapping(address => uint256) private _balances;
    address _contractOwner;
    uint256 _rate;
    uint256 _contractStart;
    uint256 _contractEnd;

/** @dev Few events to check the output of critical functions in the contract.
 */
    event Withdrew(address indexed owner, uint256 profit);
    event Bought(address indexed sender, uint256 tokenAmount);
    //event withdrewToken(address indexed sender, uint256 amount);

/** @dev firstTokenAddress will set the contract token addres in the ICO.
 *  owner_ will set the owner of this particular ICO contract.
 *  _rate will set the amount of token in wei.
 *  _contractStart will set the start of the ICO.
 *  _contractEnd will set the end of the ICO.
 */
    constructor (address firstTokenAddress, address owner_) {
        _contractOwner = owner_;
        _token = FirstToken(firstTokenAddress);
        _rate = 10 ** 9;
        _contractStart = block.timestamp;
        _contractEnd = _contractStart + 2 weeks;
    }

/** @dev This two functions below call _buy function.
 *  @notice This function can "receive" from outside the contract.
 */
    receive() external payable {
        _buy(msg.sender, msg.value);
    }

/** @notice This function is used to buy Tokens inside the contract.
 */

    function buyTokens() public payable {
        _buy(msg.sender, msg.value);
    }

/** @notice This function is for the owner to withdraw benefits,
 * can only be call when the right time has come (2 weeks after deployment).
 */
    function withdrawAll() public onlyOwner {
        require (address(this).balance > 0 ,"ICO (withdrawAll): No profit yet.");
        require (block.timestamp >= _contractEnd, "ICO (withdrawAll): Cannot withdraw yet.");
        uint256 profit = address(this).balance;
        payable(msg.sender).sendValue(profit);
        emit Withdrew(msg.sender, profit);
    }

/** todo...
    function withdrawToken() public {
        require(_balances[msg.sender] > 0 ,"ICO (withdrawToken): No Tokens to withdraw.");
        require(block.timestamp >= _contractEnd, "ICO (withdrawToken): Cannot withdraw Tokens yet.");
        uint256 weiAmount = _balances[msg.sender];
        _balances[msg.sender] = 0;
        _token.transfer(msg.sender, weiAmount);
        emit withdrewToken(msg.sender, weiAmount);
    }
*/

/** @notice tokensLeft getter is used in the _buy function,
 *  it checks the allowance of the Token's owner to the ICO.
 */
    function tokensLeft() public view returns (uint256) {
        return _token.allowance(_token.owner(), address(this));
    }

/** @notice This getter checks the current _rate of the Token.
 */
    function rate() public view returns (uint256) {
        return _rate;
    }

/** @notice This getter checks to balance of the ICO.
 */
    function total() public view returns (uint256) {
        return address(this).balance;
    }
}

/** @param sender is the Token's buyer.
 *  @param weiAmount is the amount of wei the buyer sends for a Token.
 *  @notice The owner sends the right amount of Token to the buyer.
 */
    function _buy(address sender, uint256 weiAmount) private {
        require(block.timestamp < _contractEnd, "ICO (buy): Contract is closed.");
        uint256 tokenAmount = weiAmount * _rate;
        require(tokenAmount <= tokensLeft(), "ICO (buy): Not enough Tokens");
        _balances[msg.sender] += tokenAmount;
        _token.transferFrom(_token.owner(), sender/*address(this)*/, tokenAmount);
        emit Bought(sender, weiAmount);
    }
