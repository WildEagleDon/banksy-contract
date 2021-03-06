// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
import "../splitwallet/SplitWallet.sol";
import "hardhat/console.sol";
import "../agent/Agent.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";


struct AcquisitionInfo {
    address acquirer;
    uint256 unitPrice;
    uint256 beginTime;
    uint256 amount;
    bool    isRefuse;
}

contract AcquisitionAgent is Agent {
    mapping(SplitWallet => AcquisitionInfo) private infos;

    event Refused (SplitWallet wallet, address acquirer);

    constructor (address goverAddr) Agent(goverAddr) {}
    // register a agent for a wallet
    function start(SplitWallet wallet, uint256 unitPrice) 
    external payable isAlive() {
        require(governance.isWallet(address(wallet)), "wallet is error format");
        require(infos[wallet].acquirer == address(0), "wallet is on anther acquisition");
        require(wallet.balanceOf(msg.sender) > 0, "acquirer has not split token");
        
        uint256 payValue = SafeMath.mul(SafeMath.sub(wallet.totalSupply(), wallet.balanceOf(msg.sender)), unitPrice);
        
        require(payValue <= msg.value, "ether for acquisition is not match");
        if(msg.value > payValue) {
            Address.sendValue(payable(msg.sender), SafeMath.sub(msg.value, payValue));
        }
        
        wallet.changeOwnerByAgent(address(this));
        
        wallet.transferFromByAgent(msg.sender, address(this), wallet.balanceOf(msg.sender));
        
        infos[wallet].acquirer = msg.sender;
        infos[wallet].unitPrice = unitPrice;
        infos[wallet].beginTime = block.timestamp;
        infos[wallet].isRefuse = false;
        infos[wallet].amount = payValue;
    }

    // to check if the acquisition is timeout
    function isTimeout(SplitWallet wallet) private view returns (bool) {
        return (SafeMath.sub(block.timestamp, infos[wallet].beginTime) >= governance.getSetting("ACQUISITION_TIMEOUT"));
    }

    // to check if the acquisition is refused
    function isRefuse(SplitWallet wallet) private view returns (bool) {
        return infos[wallet].isRefuse;
    }

    // to find if the acquisition is finished
    function isFinish(SplitWallet wallet) public view returns(bool finished, bool accepted) {
        if(isRefuse(wallet)) {
            // acquisition is refuse
            return (true,false);
        }
        else if(isTimeout(wallet)) {
            // duration is finish
            return (true,true);
        }
        return (false,false);
    }
    
    // to refuse the acquisition 
    function refuse(SplitWallet wallet) external payable {
        require(infos[wallet].acquirer != address(0), "wallet is not on acquisition");
        require(wallet.balanceOf(msg.sender) > 0, "sender do not have token");
        require(!isTimeout(wallet) && !isRefuse(wallet),"acquisition is finished");

        uint256 payValue = SafeMath.mul(wallet.balanceOf(address(this)), infos[wallet].unitPrice);
        uint256 msgValue = msg.value;

        if(msgValue > payValue) {
            uint256 overValue = SafeMath.sub(msgValue, payValue);
            Address.sendValue(payable(msg.sender), overValue);
            msgValue = SafeMath.sub(msgValue, overValue);
        }

        uint256 tokenCount = SafeMath.div(msgValue, infos[wallet].unitPrice);
        
        infos[wallet].amount = SafeMath.add(infos[wallet].amount, msgValue);
        wallet.transfer(msg.sender, tokenCount);

        if(msgValue == payValue) {
            // refuse succeed
            infos[wallet].isRefuse = true;
            
            Address.sendValue(payable(infos[wallet].acquirer), infos[wallet].amount);
            wallet.changeOwnerByAgent(address(0));
            emit Refused(wallet, infos[wallet].acquirer);
        }
    }

    // if acquisition is accepted, use this function to get wallet owner
    function retrieve(SplitWallet wallet) external {
        (bool finish, bool accept) = isFinish(wallet);
        require(finish && accept, "acquisition is not accepted");

        wallet.burnByAgent(address(this), wallet.balanceOf(address(this)));
        wallet.changeOwnerByAgent(msg.sender);
        
    }

    // if acquisition is accepted, use this function to get claim fee
    function claim(SplitWallet wallet) external {
        (bool finish, bool accept) = isFinish(wallet);
        require(finish && accept, "acquisition is not accepted");
        uint256 balance = wallet.balanceOf(msg.sender);

        wallet.burnByAgent(msg.sender, balance);
        Address.sendValue(payable(msg.sender), SafeMath.mul(infos[wallet].unitPrice, balance));
    }
}