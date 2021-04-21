// SPDX-License-Identifier: MIT
pragma solidity ^0.7;

import "../utils/Clone.sol";
contract WalletFactory {
    address target;
    event CreatedWallet(address newWallet);

    constructor(address walletTarget) {
        target = walletTarget;
    }

    function createWallet() external returns (address) { 
        address newWallet = Clone.createClone(target);
        emit CreatedWallet(newWallet);
        return newWallet;
    }

    function isWallet(address wallet) external view returns (bool) {
        return Clone.isClone(target, wallet);
    }
}