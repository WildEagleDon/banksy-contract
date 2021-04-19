// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "./IGovernance.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

contract Governance is IGovernance, Ownable {
    mapping(address => bool) agentConfig;

    function setAgentEnabled(address agent, bool enable) 
    external onlyOwner() {
        agentConfig[agent] = enable;
    }

    function isAgentEnabled(address agent) external view override returns(bool) {
        return agentConfig[agent];
    }
}