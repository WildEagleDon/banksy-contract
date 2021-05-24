// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "@openzeppelin/contracts/cryptography/ECDSA.sol";

contract VerifySign {
    function verify(bytes32 hash, bytes memory sign) external pure returns(address) {
        
        address addr = ECDSA.recover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)),sign);
        return addr;
    }
}