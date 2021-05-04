// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

interface IGovernance {
    function isAgentEnabled(address agent) external view returns (bool);
    
    function isWallet(address wallet) external view returns (bool);
    
    function getSetting(string memory name) external view returns (uint256);
}