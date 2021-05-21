// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "../splitwallet/SplitWallet.sol";
import "../agent/Agent.sol";
import "../agent/BasicSplitAgent.sol";

contract TestSplitAgent is BasicSplitAgent {
    constructor (address goverAddr) BasicSplitAgent(goverAddr) {}

}