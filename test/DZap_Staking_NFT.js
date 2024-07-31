const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("DZap_Staking_NFT", function () {
  let DZapStakingNFT, dzapStakingNFT;
  let rewardToken, nftCollection;
  let owner, addr1, addr2;
  const unboundingTime = 60; // 60 seconds
  const delayTime = 60; // 60 seconds
  const rewardPerBlock = 1; // 1 token per block

  beforeEach(async function () {
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    // Deploy ERC20 token
    const RewardToken = await ethers.getContractFactory("ERC20");
    rewardToken = await RewardToken.deploy("Reward Token", "RWT");
    await rewardToken.deployed();

    // Deploy ERC721 NFT collection
    const NFTCollection = await ethers.getContractFactory("ERC721");
    nftCollection = await NFTCollection.deploy("NFT Collection", "NFTC");
    await nftCollection.deployed();

    // Mint some NFTs to addr1
    await nftCollection.mint(addr1.address, 1);
    await nftCollection.mint(addr1.address, 2);

    // Deploy DZap_Staking_NFT contract
    DZapStakingNFT = await ethers.getContractFactory("DZap_Staking_NFT");
    dzapStakingNFT = await upgrades.deployProxy(
      DZapStakingNFT,
      [owner.address, nftCollection.address, rewardToken.address, unboundingTime, delayTime, rewardPerBlock],
      { initializer: "initialize" }
    );
    await dzapStakingNFT.deployed();

    // Transfer some reward tokens to the staking contract
    await rewardToken.transfer(dzapStakingNFT.address, ethers.utils.parseEther("1000"));
  });

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      expect(await dzapStakingNFT.owner()).to.equal(owner.address);
    });
  });

  describe("Staking", function () {
    it("Should allow users to stake NFTs", async function () {
      await nftCollection.connect(addr1).approve(dzapStakingNFT.address, 1);
      await dzapStakingNFT.connect(addr1).stake(1);

      expect(await nftCollection.ownerOf(1)).to.equal(dzapStakingNFT.address);
      const staker = await dzapStakingNFT.stakers(addr1.address);
      expect(staker.amountstaked).to.equal(1);
    });
  });

  describe("Unstaking", function () {
    it("Should allow users to unstake NFTs after unbounding time", async function () {
      await nftCollection.connect(addr1).approve(dzapStakingNFT.address, 1);
      await dzapStakingNFT.connect(addr1).stake(1);

      // Move time forward by unbounding time
      await ethers.provider.send("evm_increaseTime", [unboundingTime + 1]);
      await ethers.provider.send("evm_mine");

      await dzapStakingNFT.connect(addr1).unstake(1);

      expect(await nftCollection.ownerOf(1)).to.equal(addr1.address);
      const staker = await dzapStakingNFT.stakers(addr1.address);
      expect(staker.amountstaked).to.equal(0);
    });
  });

  describe("Claiming Rewards", function () {
    it("Should allow users to claim rewards after delay time", async function () {
      await nftCollection.connect(addr1).approve(dzapStakingNFT.address, 1);
      await dzapStakingNFT.connect(addr1).stake(1);

      // Move time forward by a few blocks
      await ethers.provider.send("evm_mine");
      await ethers.provider.send("evm_mine");

      await dzapStakingNFT.connect(addr1).claimrewards();

      // Move time forward by delay time
      await ethers.provider.send("evm_increaseTime", [delayTime + 1]);
      await ethers.provider.send("evm_mine");

      await dzapStakingNFT.connect(addr1).claimrewards();

      const rewardBalance = await rewardToken.balanceOf(addr1.address);
      expect(rewardBalance).to.be.above(0);
    });
  });

  describe("Admin Functions", function () {
    it("Should allow owner to set reward per block", async function () {
      await dzapStakingNFT.setRewardperblock(2);
      expect(await dzapStakingNFT.rewardperblock()).to.equal(2);
    });

    it("Should allow owner to set delay time", async function () {
      await dzapStakingNFT.setDelaytime(120);
      expect(await dzapStakingNFT.delaytime()).to.equal(120);
    });

    it("Should allow owner to set unbounding time", async function () {
      await dzapStakingNFT.setUnbondingtime(120);
      expect(await dzapStakingNFT.unboundingtime()).to.equal(120);
    });
  });
});
