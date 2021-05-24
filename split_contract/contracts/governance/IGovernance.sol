// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

interface IGovernance {
    function isValidAgent(address agent) external view returns (bool);
    
    function isAliveAgent(address agent) external view returns (bool);

    function isDeprecatedAgent(address agent) external view returns (bool);
    
    function isWallet(address wallet) external view returns (bool);
    
    function getSetting(string memory name) external view returns (uint256);
}