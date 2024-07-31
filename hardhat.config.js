require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-ethers");
require('@openzeppelin/hardhat-upgrades');
// require("@nomiclabs/hardhat-ethers");
require("dotenv").config();



/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.24",
  networks: {
    polygonAmoyTestnet: {
     
      url: process.env.URL,
      accounts: [process.env.PRIVATE_KEY],
    }
  },
};

