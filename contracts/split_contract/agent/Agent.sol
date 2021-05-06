// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "../governance/IGovernance.sol";

contract Agent {
    IGovernance internal governance;

    constructor (address goverAddr) {
        governance = IGovernance(goverAddr);
    }

    modifier isAlive() {
        require(governance.isAliveAgent(address(this)), "onlyAgent: caller is not the agent");
        _;
    }
}