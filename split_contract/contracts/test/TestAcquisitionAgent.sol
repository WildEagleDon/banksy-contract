// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "../splitwallet/SplitWallet.sol";
import "../agent/Agent.sol";
import "../agent/AcquisitionAgent.sol";

contract TestAcquisitionAgent is AcquisitionAgent {
    constructor (address goverAddr) AcquisitionAgent(goverAddr) {}

}