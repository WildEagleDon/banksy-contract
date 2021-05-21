// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "./IGovernance.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "../utils/Clone.sol";

contract Governance is IGovernance, Ownable {
    mapping(address => bool) aliveAgent;
    mapping(address => bool) deprecatedAgent;
    mapping(string => uint256) settings;
    address walletTemplate;

    event CreatedWallet(address newWallet);
    constructor () {
    	// is the duration of the acquisition
        settings["ACQUISITION_TIMEOUT"] = 10 seconds;
    }

    function addAgent(address agent) 
    external onlyOwner() {
        aliveAgent[agent] = true;
    }


    function updateAgent(address oldAgent, address newAgent) 
    external onlyOwner() {
        require(aliveAgent[oldAgent], "oldAgent is not enabled");
        require(!aliveAgent[newAgent], "newAgent is enabled");

        aliveAgent[oldAgent] = false;
        deprecatedAgent[oldAgent] = true;
        aliveAgent[newAgent] = true;
    }

    function isValidAgent(address agent) external view override returns (bool) {
        return aliveAgent[agent] || deprecatedAgent[agent];
    }


    function isAliveAgent(address agent) external view override returns (bool) {
        return aliveAgent[agent];
    }

    function isDeprecatedAgent(address agent) external view override returns (bool) {
        return deprecatedAgent[agent];
    }
    
    function createWallet() external returns (address) { 
        require(walletTemplate != address(0), "wallet template has not init");

        address newWallet = Clone.createClone(walletTemplate);

        emit CreatedWallet(newWallet);
        return newWallet;
    }

    function setWalletTemplate(address wallet)
    external onlyOwner() {
        walletTemplate = wallet;
    }

    function isWallet(address wallet) external view override returns (bool) {
        return Clone.isClone(walletTemplate, wallet);
    }

    function setSetting(string memory name, uint256 value)
    external onlyOwner() {
        settings[name] = value;
    }

    function getSetting(string memory name) external view override returns (uint256) {
        return settings[name];
    }
}

