// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "../governance/IGovernance.sol";

contract Agent {
    IGovernance internal governance;

    constructor (address goverAddr) {
        governance = IGovernance(goverAddr);
    }
}