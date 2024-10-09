// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract HippoSteroids is Ownable, ReentrancyGuard {
    // ...
constructor(address _devWallet, address _stakingPoolWallet) Ownable(_devWallet) ReentrancyGuard() {
        devWallet = _devWallet;
        stakingPoolWallet = _stakingPoolWallet;
    }

    uint256 public steroidCost = 699420000; // Steroid cost in SUN (699.42 TRX)
    mapping(address => uint256) public steroidBalance;

    address public devWallet;
    address public stakingPoolWallet;

    event SteroidPurchased(address indexed buyer, uint256 amount);
    event SteroidCostUpdated(uint256 newCost);



    /// @notice Purchases a steroid boost for the Hippo NFT.
    /// @dev The buyer's steroid balance is incremented and the purchase amount is split between the dev and staking wallets.
    function buySteroid() external payable nonReentrant {
        require(msg.value >= steroidCost, "Insufficient funds for Steroid NFT");

        steroidBalance[msg.sender]++;

        // Split the payment equally between devWallet and stakingPoolWallet
        uint256 devShare = msg.value / 2;
        uint256 stakingShare = msg.value - devShare;

        _payTo(devWallet, devShare);
        _payTo(stakingPoolWallet, stakingShare);

        emit SteroidPurchased(msg.sender, 1);
    }

    /// @dev Utility function to transfer funds to a specified address.
    /// @param to The recipient address.
    /// @param amount The amount to be transferred.
    function _payTo(address to, uint256 amount) internal {
        (bool success, ) = to.call{value: amount}("");
        require(success, "Transfer to wallet failed.");
    }

    /// @notice Gets the steroid balance of a user.
    /// @param user The address of the user.
    /// @return The steroid balance of the specified user.
    function getSteroidBalance(address user) external view returns (uint256) {
        return steroidBalance[user];
    }

    /// @notice Allows the owner to update the cost of a steroid.
    /// @param newCost The new steroid cost in SUN (1 TRX = 1,000,000 SUN).
    function setSteroidCost(uint256 newCost) external onlyOwner {
        require(newCost > 0, "Steroid cost must be greater than zero");
        steroidCost = newCost;
        emit SteroidCostUpdated(newCost);
    }
function decreaseSteroidBalance() public {
    steroidBalance[msg.sender] = steroidBalance[msg.sender] - 1;
}
    /// @notice Allows the owner to withdraw any excess funds from the contract.
    /// @param amount The amount to withdraw.
    function withdrawFunds(uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "Insufficient contract balance");
        _payTo(owner(), amount);
    }

    /// @notice Gets the contract's current balance in wei.
    /// @return The balance of the contract.
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /// @notice Allows the owner to update the dev wallet address.
    /// @param newDevWallet The new address for the dev wallet.
    function setDevWallet(address newDevWallet) external onlyOwner {
        require(newDevWallet != address(0), "Invalid address");
        devWallet = newDevWallet;
    }

    /// @notice Allows the owner to update the staking pool wallet address.
    /// @param newStakingPoolWallet The new address for the staking pool wallet.
    function setStakingPoolWallet(address newStakingPoolWallet) external onlyOwner {
        require(newStakingPoolWallet != address(0), "Invalid address");
        stakingPoolWallet = newStakingPoolWallet;
    }
}