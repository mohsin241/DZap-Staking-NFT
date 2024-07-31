// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";

contract DZap_Staking_NFT is Initializable, PausableUpgradeable, OwnableUpgradeable, UUPSUpgradeable {
    using SafeERC20 for IERC20;

    // Interfaces for ERC20 and ERC721 tokens
    IERC20 public rewardToken;
    IERC721 public nftCollection;

    uint256 public releaseTime;
    uint256 public unbondingTime;
    uint256 public delayTime;
    uint256 public rewardPerBlock;

    // Struct to represent staked tokens
    struct StakedToken {
        address staker;
        uint tokenId;
    }

    // Struct to represent stakers
    struct Staker {
        uint256 amountStaked;
        StakedToken[] stakedTokens;
        uint256 lastUpdateBlock;
        uint256 unclaimedRewards;
    }

    // Mapping of staker address to their staker details
    mapping(address => Staker) public stakers;

    // Mapping of token ID to the staker's address
    mapping(uint256 => address) public stakerAddress;

    function initialize(
        address initialOwner,
        IERC721 _nftCollection,
        IERC20 _rewardToken,
        uint256 _unbondingTime,
        uint256 _delayTime,
        uint256 _rewardPerBlock
    ) public initializer {
        __Pausable_init();
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
        nftCollection = _nftCollection;
        rewardToken = _rewardToken;
        unbondingTime = _unbondingTime;
        delayTime = _delayTime;
        rewardPerBlock = _rewardPerBlock;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}

    /**
     * @notice Allows a user to stake their NFT
     * @param _tokenId The ID of the NFT to stake
     */
    function stake(uint256 _tokenId) external whenNotPaused {
        if (stakers[msg.sender].amountStaked > 0) {
            uint256 rewards = calculateRewards(msg.sender);
            stakers[msg.sender].unclaimedRewards += rewards;
        }
        require(nftCollection.ownerOf(_tokenId) == msg.sender, "You are not the owner");
        nftCollection.transferFrom(msg.sender, address(this), _tokenId);

        StakedToken memory stakedToken = StakedToken(msg.sender, _tokenId);
        stakers[msg.sender].stakedTokens.push(stakedToken);
        stakers[msg.sender].amountStaked++;
        stakerAddress[_tokenId] = msg.sender;
        stakers[msg.sender].lastUpdateBlock = block.number;
    }

    /**
     * @notice Allows a user to unstake their NFT
     * @param _tokenId The ID of the NFT to unstake
     */
    function unstake(uint256 _tokenId) external whenNotPaused {
        require(stakers[msg.sender].amountStaked > 0, "You don't own this token");

        uint256 rewards = calculateRewards(msg.sender);
        stakers[msg.sender].unclaimedRewards += rewards;

        uint256 index = 0;
        for (uint256 i = 0; i < stakers[msg.sender].stakedTokens.length; i++) {
            if (stakers[msg.sender].stakedTokens[i].tokenId == _tokenId) {
                index = i;
                break;
            }
        }
        delete stakers[msg.sender].stakedTokens[index];
        stakers[msg.sender].amountStaked--;
        delete stakerAddress[_tokenId];

        releaseTime = block.timestamp + unbondingTime;
        require(block.timestamp > releaseTime, "You will receive after unbonding time");

        nftCollection.transferFrom(address(this), msg.sender, _tokenId);
        stakers[msg.sender].lastUpdateBlock = block.number;
    }

    /**
     * @notice Allows a user to claim their rewards
     */
    function claimRewards() external whenNotPaused {
        uint256 rewards = calculateRewards(msg.sender) + stakers[msg.sender].unclaimedRewards;
        require(rewards > 0, "You have no rewards to claim");

        stakers[msg.sender].lastUpdateBlock = block.number;
        stakers[msg.sender].unclaimedRewards = 0;

        releaseTime = block.number + delayTime;
        require(block.number > releaseTime, "You will receive tokens after delay period");

        rewardToken.safeTransfer(msg.sender, rewards);
    }

    /**
     * @notice Calculates the rewards for a staker
     * @param _staker The address of the staker
     * @return  calculated rewards
     */
    function calculateRewards(address _staker) internal view returns (uint256) {
        return ((block.number - stakers[_staker].lastUpdateBlock) * rewardPerBlock);
    }

    /**
     * @notice Pauses the contract, preventing any staking, unstaking, or claiming rewards
     */
    function pause() public onlyOwner {
        _pause();
    }

    /**
     * @notice Unpauses the contract, allowing staking, unstaking, and claiming rewards
     */
    function unpause() public onlyOwner {
        _unpause();
    }

    /**
     * @notice Sets the reward per block
     * @param _rewardPerBlock The new reward per block
     */
    function setRewardPerBlock(uint256 _rewardPerBlock) external onlyOwner {
        rewardPerBlock = _rewardPerBlock;
    }

    /**
     * @notice Sets the delay time for rewards
     * @param _delayTime The new delay time
     */
    function setDelayTime(uint256 _delayTime) external onlyOwner {
        delayTime = _delayTime;
    }

    /**
     * @notice Sets the unbonding time for unstaking
     * @param _unbondingTime The new unbonding time
     */
    function setUnbondingTime(uint256 _unbondingTime) external onlyOwner {
        unbondingTime = _unbondingTime;
    }
}
