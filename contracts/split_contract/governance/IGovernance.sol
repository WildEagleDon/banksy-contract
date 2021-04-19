// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

interface IGovernance {
    function isAgentEnabled(address agent) external view returns(bool);
}