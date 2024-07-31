 const { ethers, upgrades } = require("hardhat");
 require("dotenv").config();

async function main() {
   const Contract = await ethers.getContractFactory("DZap_Staking_NFT");
   console.log("Deploying Contract...");
   const contract = await upgrades.deployProxy(Contract, [process.env.initialOwner,process.env.nftCollection,process.env.rewardToken,60,60,1], {
      initializer: "initialize",
   });
   await contract.waitForDeployment();
   console.log("Contract deployed to:", await contract.getAddress());
}

main().catch((error) => {
   console.error(error);
   process.exitCode = 1;
 });
