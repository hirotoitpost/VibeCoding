import { expect } from "chai";
import { ethers } from "hardhat";

describe("VibeCodingToken", function () {
  // Test suite setup
  let token: any;
  let owner: any;
  let addr1: any;
  let addr2: any;

  beforeEach(async function () {
    // Get signers
    [owner, addr1, addr2] = await ethers.getSigners();

    // Deploy token
    const VibeCodingToken = await ethers.getContractFactory("VibeCodingToken");
    token = await VibeCodingToken.deploy();
  });

  describe("Deployment", function () {
    it("Should have correct name and symbol", async function () {
      expect(await token.name()).to.equal("VibeCoding Token");
      expect(await token.symbol()).to.equal("VBC");
    });

    it("Should have 18 decimals", async function () {
      expect(await token.decimals()).to.equal(18);
    });

    it("Should mint initial supply to owner", async function () {
      const initialSupply = ethers.parseEther("1000000");
      expect(await token.balanceOf(owner.address)).to.equal(initialSupply);
    });

    it("Should have correct total supply", async function () {
      const initialSupply = ethers.parseEther("1000000");
      expect(await token.totalSupply()).to.equal(initialSupply);
    });
  });

  describe("Transfer", function () {
    it("Should transfer tokens between accounts", async function () {
      const amount = ethers.parseEther("100");
      const initialBalance = await token.balanceOf(addr1.address);
      
      await token.connect(owner).transfer(addr1.address, amount);
      
      expect(await token.balanceOf(addr1.address)).to.equal(initialBalance + amount);
    });

    it("Should fail if sender doesn't have enough tokens", async function () {
      const ownerBalance = await token.balanceOf(owner.address);
      const amountTooMuch = ownerBalance + ethers.parseEther("1");

      await expect(
        token.connect(addr1).transfer(owner.address, amountTooMuch)
      ).to.be.revertedWithCustomError(token, "ERC20InsufficientBalance");
    });
  });

  describe("Approve and TransferFrom", function () {
    it("Should approve tokens", async function () {
      const amount = ethers.parseEther("100");
      await token.connect(owner).approve(addr1.address, amount);
      expect(await token.allowance(owner.address, addr1.address)).to.equal(amount);
    });

    it("Should transfer tokens via transferFrom", async function () {
      const amount = ethers.parseEther("100");
      await token.connect(owner).approve(addr1.address, amount);

      const initialBalance = await token.balanceOf(addr2.address);
      await token.connect(addr1).transferFrom(owner.address, addr2.address, amount);
      
      expect(await token.balanceOf(addr2.address)).to.equal(initialBalance + amount);
    });

    it("Should decrease allowance after transfer", async function () {
      const amount = ethers.parseEther("100");
      await token.connect(owner).approve(addr1.address, amount);
      await token.connect(addr1).transferFrom(owner.address, addr2.address, amount);
      
      expect(await token.allowance(owner.address, addr1.address)).to.equal(0);
    });
  });

  describe("Burn", function () {
    it("Should burn tokens", async function () {
      const initialSupply = await token.totalSupply();
      const amount = ethers.parseEther("100");

      await token.connect(owner).burn(amount);

      expect(await token.totalSupply()).to.equal(initialSupply - amount);
    });

    it("Should decrease burner's balance", async function () {
      const initialBalance = await token.balanceOf(owner.address);
      const amount = ethers.parseEther("100");

      await token.connect(owner).burn(amount);

      expect(await token.balanceOf(owner.address)).to.equal(initialBalance - amount);
    });
  });

  describe("Access Control", function () {
    it("Should have correct owner", async function () {
      expect(await token.owner()).to.equal(owner.address);
    });

    it("Should allow owner to renounce ownership", async function () {
      await token.connect(owner).renounceOwnership();
      expect(await token.owner()).to.equal(ethers.ZeroAddress);
    });

    it("Should prevent non-owner from transferring ownership", async function () {
      await expect(
        token.connect(addr1).transferOwnership(addr2.address)
      ).to.be.revertedWithCustomError(token, "OwnableUnauthorizedAccount");
    });
  });
});
