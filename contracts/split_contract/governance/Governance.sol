// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "./IGovernance.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "../utils/Clone.sol";

contract Governance is IGovernance, Ownable {
    mapping(address => bool) agentConfig;
    address walletTemplate;

    event CreatedWallet(address newWallet);

    function setAgentEnabled(address agent, bool enable) 
    external onlyOwner() {
        agentConfig[agent] = enable;
    }

    function setWalletTemplate(address wallet)
    external onlyOwner() {
        walletTemplate = wallet;
    }

    function isAgentEnabled(address agent) external view override returns (bool) {
        return agentConfig[agent];
    }

    function createWallet() external returns (address) { 
        require(walletTemplate != address(0), "wallet template has not init");

        address newWallet = Clone.createClone(walletTemplate);

        emit CreatedWallet(newWallet);
        return newWallet;
    }

    function isWallet(address wallet) external view override returns (bool) {
        return Clone.isClone(walletTemplate, wallet);
    }

}

