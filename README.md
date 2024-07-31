# DZap Staking NFT

## Overview

The `DZap_Staking_NFT` contract is an upgradeable staking contract for NFTs. Users can stake their NFTs to earn ERC20 token rewards. The contract supports staking, unstaking, and reward claiming functionalities. It is built using Solidity with OpenZeppelin Contracts and is upgradeable using UUPS (Universal Upgradeable Proxy Standard).

## Features

- **Staking:** Users can stake their NFTs to earn rewards in ERC20 tokens.
- **Unstaking:** Users can unstake their NFTs after a specified unbonding period.
- **Reward Claiming:** Users can claim their accumulated rewards.
- **Upgradable:** The contract is upgradeable using the UUPS proxy pattern.
- **Pausable:** The contract owner can pause and unpause the contract to prevent staking, unstaking, or claiming rewards.

## Prerequisites

- Node.js
- Hardhat
- dotenv (for environment variables)

## Installation

1. Clone the repository:

   git clone https://github.com/your-repo/dzap-staking-nft.git
   cd dzap-staking-nft

2. install dependencies:

   npm install

3. create .env file

## Deployment 

- npx hardhat run -- network polygonAmoyTestnet scripts/deploy.js
