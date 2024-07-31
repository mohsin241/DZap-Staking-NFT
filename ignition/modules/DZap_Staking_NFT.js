const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");




module.exports = buildModule("DZap_Staking_NFTModule", (m) => {
 

  const StakingContract = m.contract("DZap_Staking_NFT", ["0x67A8f98E347A2079a937ed874f56E7862b5073A7","0x12848759c4ad6854177b2217f2e3f54d171b317b","0x40804b6B9Bb257e5B46e0A7b14f9540555b5776C"]);

  return { StakingContract };
});
