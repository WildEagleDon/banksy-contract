// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;
import "./MyContract1.sol";

contract MyContract2 is MyContract1{
    function test() external pure returns(string memory) {
        return "test";
    }
}
