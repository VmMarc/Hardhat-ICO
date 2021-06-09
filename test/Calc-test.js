/* eslint-disable no-undef */
const { expect } = require('chai');

describe('Calculator', () => {
  let Token, token, Calculator, calculator, dev, tokenOwner, calcOwner, toto;

  beforeEach(async function () {
    [dev, owner, toto] = await ethers.getSigners();
    Token = await ethers.getContractFactory('FirstToken');
    token = await Token.connect(dev).deploy(owner.address, TOTAL_SUPPLY);
    await token.deployed();
  });
});
