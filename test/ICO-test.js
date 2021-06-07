/* eslint-disable spaced-comment */
/* eslint-disable no-unused-vars */
/* eslint-disable no-undef */
const { expect } = require('chai');

describe('ICO', function () {
  let Token, token, ICO, ico, dev, owner, contractOwner, alice, bob, tx;
  const RATE = 10 ** 9;
  const TOTAL_SUPPLY = ethers.utils.parseEther('1000000');

  beforeEach(async function () {
    [dev, owner, contractOwner, alice, bob] = await ethers.getSigners();
    Token = await ethers.getContractFactory('FirstToken');
    token = await Token.connect(dev).deploy(owner.address, TOTAL_SUPPLY);
    await token.deployed();
    ICO = await ethers.getContractFactory('ICO');
    ico = await ICO.connect(contractOwner).deploy(token.address, contractOwner.address);
    await ico.deployed();
    await token.connect(owner).approve(ico.address, TOTAL_SUPPLY);
  });

  describe('Deployment', function () {
    it('Should set rate', async function () {
      expect(await ico.rate()).to.equal(RATE);
    });
  });

  describe('Buy function', function () {
    it('Should receive function', async function () {
      tx = await bob.sendTransaction({ to: ico.address, value: 1 * RATE });
      expect(await token.balanceOf(bob.address)).to.equal(ethers.utils.parseEther('1'));
      expect(await ico.total()).to.equal(1 * RATE);
      expect(tx).to.changeEtherBalance(bob, -1 * RATE);
    });
    it('Should buyTokens function', async function () {
      tx = await ico.connect(bob).buyTokens({ value: 1 * RATE });
      expect(await token.balanceOf(bob.address)).to.equal(ethers.utils.parseEther('1'));
      expect(await ico.total()).to.equal(RATE);
      expect(tx).to.changeEtherBalance(bob, -1 * RATE);
    });
    it('Should emit a Bought event', async function () {
      await expect(ico.connect(bob).buyTokens({ value: 1 * RATE }))
        .to.emit(ico, 'Bought')
        .withArgs(bob.address, 1, 1 * RATE); //Error...
    });
  });
  describe('Withdraw', function () {
    beforeEach(async function () {
      await ico.connect(alice).buyTokens({ value: 10 * RATE });
    });
    it('Should revert if not the right time for Withdraw', async function () {
      await ethers.provider.send('evm_increaseTime', [604800]); //1semaine en secondes
      await ethers.provider.send('evm_mine');
      await expect(ico.connect(contractOwner).withdrawAll()).to.be.revertedWith(
        'ICO (withdrawAll): Cannot withdraw yet.');
    });
    it('Should emit Withdrew event', async function () {
      await ethers.provider.send('evm_increaseTime', [1209600]); //2 semaines
      await ethers.provider.send('evm_mine');
      await expect(ico.connect(contractOwner).withdrawAll())
        .to.emit(ico, 'Withdrew')
        .withArgs(contractOwner.address, 10 * RATE);
    });
  });
  describe('WithdrawTokens', function () {
    beforeEach(async function () {
      await ico.connect(alice).buyTokens({ value: 10 * RATE });
    });
    it('Should revert if not the right time for Withdraw Tokens', async function () {
      await ethers.provider.send('evm_increaseTime', [604800]); //1semaine en secondes
      await ethers.provider.send('evm_mine');
      await expect(ico.connect(alice).withdrawToken()).to.be.revertedWith(
        'ICO (withdrawToken): Cannot withdraw Tokens yet.');
    });
    it('Should emit withdrewToken event', async function () {
      await ethers.provider.send('evm_increaseTime', [1209600]); //2 semaines
      await ethers.provider.send('evm_mine');
      await expect(ico.connect(alice).withdrawToken())
        .to.emit(ico, 'withdrewToken')
        .withArgs(alice.address, 10 * RATE); //Error
    });
  });
});
