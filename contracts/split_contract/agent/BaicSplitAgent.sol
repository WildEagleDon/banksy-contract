// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "../splitwallet/SplitWallet.sol";


contract BasicSplitAgent {
    // start a agent for a wallet
    function start(SplitWallet wallet, address[] calldata account, uint256[] calldata amount) external {
        require(wallet.owner() == msg.sender);
        require(wallet.totalSupply() == 0);
        require(account.length == amount.length);

        for(uint256 i = 0; i < account.length; i++) {
            wallet.mintByAgent(account[i], amount[i]);
        }
        wallet.changeOwnerByAgent(address(0));
    }
}