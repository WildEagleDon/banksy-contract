// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "../governance/IGovernance.sol";

contract Agent {
    IGovernance internal governance;

    constructor (address goverAddr) {
        governance = IGovernance(goverAddr);
    }

    modifier isAlive() {
        require(governance.isAliveAgent(address(this)), "isAlive: caller is not the alive agent");
        _;
    }

    modifier isDeprecatedAgent() {
        require(governance.isDeprecatedAgent(address(this)), "isDeprecatedAgent: caller is not the deprecatedAgent agent");
        _;
    }
}