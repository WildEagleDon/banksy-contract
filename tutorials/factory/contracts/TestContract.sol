// SPDX-License-Identifier: MIT
pragma solidity ^0.7;

contract TestContract {
    string name;
    function getName() view external returns(string memory) {
        return name;
    }
    
    function setName(string memory name_) external {
        name = name_;
    }
}