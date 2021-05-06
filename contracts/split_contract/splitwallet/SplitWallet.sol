//SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "../token/ERC20.sol";
import "../access/Ownable.sol";
import "../governance/IGovernance.sol";

import "@openzeppelin/contracts/utils/Address.sol";

contract SplitWallet is ERC20, Ownable {
    IGovernance governance;

    // check if sender is a agent in governance
    modifier onlyAgent() {
        require(governance.isValidAgent(msg.sender), "onlyAgent: caller is not the agent");
        _;
    }

    // init the wallet
    function init(string memory name, string memory symbol, address owner, address goverAddr) 
    external {
        require(address(governance) == address(0), "governance has been register");
        require(address(goverAddr) != address(0), "governance is null");
        ERC20._init(name, symbol);
        governance = IGovernance(goverAddr);
        transferOwnership(owner);
    }


    function burnByAgent(address account, uint256 amount)
    external onlyAgent() {
        _burn(account, amount);
    }

    function mintByAgent(address account, uint256 amount)
    external onlyAgent() {
        _mint(account, amount);
    }

    function changeOwnerByAgent(address newOwner)
    external onlyAgent() {
        transferOwnership(newOwner);
    }

    function transferFromByAgent(address sender, address receiver,uint256 amount)
    external onlyAgent() { 
        _transfer(sender, receiver, amount);
    }
    

    // owner can use this function to take out the NFT of the wallet
    function functionCallWithValue(address to, uint256 value, bytes calldata data) 
    external onlyOwner() {
        Address.functionCallWithValue(to, data, value);
    }

    // if someone has all of the token, can use this function to retrieve
    function retrieve(address newOwner)
    external
    {
        require(owner() == address(0), "the wallet has a onwer");
        _burn(msg.sender, totalSupply());
        transferOwnership(newOwner);
    }
}