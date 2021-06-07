/* eslint-disable no-undef */
const { expect } = require('chai');

describe('Token', function () {
  let Token, token, dev, owner;
  const INITIAL_SUPPLY = ethers.utils.parseEther('1000');

  beforeEach(async function () {
    [dev, owner] = await ethers.getSigners();
    Token = await ethers.getContractFactory('FirstToken');
    token = await Token.connect(dev).deploy(owner.address, 1000);
    await token.deployed();
  });
  describe('Deployment', function () {
    it('Should have name FirstToken', async function () {
      expect(await token.name()).to.equal('FirstToken');
    });
    it('Should have symbol FTN', async function () {
      expect(await token.symbol()).to.equal('FTN');
    });
    it('Should set owner', async function () {
      expect(await token.owner()).to.equal(owner.address);
    });
    it(`Should have total supply ${INITIAL_SUPPLY.toString()}`, async function () {
      expect(await token.totalSupply()).to.equal(INITIAL_SUPPLY);
    });
    it('Should mint total supply to owner', async function () {
      expect(await token.balanceOf(owner.address)).to.equal(INITIAL_SUPPLY);
    });
  });
});
