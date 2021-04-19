// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
import "../splitwallet/SplitWallet.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Address.sol";


struct AcquisitionInfo {
    address acquirer;
    uint256 unitPrice;
    uint256 beginTime;
    uint256 refuseFee;
    uint256 amount;
}

contract AcquisitionAgent {
    // is the duration of the acquisition
    uint256 public constant ACQUISITION_TIMEOUT = 10 seconds;

    mapping(SplitWallet => AcquisitionInfo) private infos;

    event Refused (SplitWallet wallet, address acquirer);


    // register a agent for a wallet
    function start(SplitWallet wallet, uint256 unitPrice) external payable {

        require(infos[wallet].acquirer == address(0), "wallet is on anther acquisition");
        require(wallet.balanceOf(msg.sender) > 0, "acquirer has not split token");
        
        uint256 payValue = (wallet.totalSupply() - wallet.balanceOf(msg.sender)) * unitPrice;
        
        require(payValue <= msg.value, "ether for acquisition is not match");
        Address.sendValue(payable(msg.sender), msg.value - payValue);

        wallet.changeOwnerByAgent(address(this));
        
        wallet.transferFromByAgent(msg.sender, address(this), wallet.balanceOf(msg.sender));

        infos[wallet].acquirer = msg.sender;
        infos[wallet].unitPrice = unitPrice;
        infos[wallet].beginTime = block.timestamp;
        infos[wallet].refuseFee = 0;
        infos[wallet].amount = payValue;

    }

    // to check if the acquisition is timeout
    function isTimeout(SplitWallet wallet) private view returns (bool) {
        console.log(block.timestamp);
        return ((block.timestamp - infos[wallet].beginTime) >= ACQUISITION_TIMEOUT);
    }

    // to check if the acquisition is refused
    function isRefuse(SplitWallet wallet) private view returns (bool) {
        return (infos[wallet].refuseFee == (wallet.balanceOf(address(this)) * infos[wallet].unitPrice));
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
        require(!isTimeout(wallet) && !isRefuse(wallet),"acquisition is finished");

        uint256 payValue = wallet.balanceOf(infos[wallet].acquirer) * infos[wallet].unitPrice;
        uint256 msgValue = msg.value;

        if(infos[wallet].refuseFee + msgValue > payValue) {
            uint256 overValue = (infos[wallet].refuseFee + msgValue - payValue);
            Address.sendValue(payable(msg.sender), overValue);
            msgValue -= overValue;
        }

        uint256 tokenCount = msgValue / infos[wallet].unitPrice;
        
        infos[wallet].amount += msgValue;
        wallet.transfer(msg.sender, tokenCount);

        if(infos[wallet].refuseFee == payValue) {
            // refuse succeed
            Address.sendValue(payable(infos[wallet].acquirer), infos[wallet].amount);
            emit Refused(wallet, infos[wallet].acquirer);
        }
    }

    // if acquisition is accepted, use this function to get wallet owner
    function retrieve(SplitWallet wallet) external {
        (bool finish, bool accept) = isFinish(wallet);
        if(finish && accept) {
            wallet.changeOwnerByAgent(address(this));
        }
    }

    // if acquisition is accepted, use this function to get claim fee
    function claim(SplitWallet wallet) external {
        (bool finish, bool accept) = isFinish(wallet);
        require(finish == true && accept == true);

        wallet.burnByAgent(msg.sender, wallet.balanceOf(msg.sender));
        Address.sendValue(payable(msg.sender), infos[wallet].unitPrice * wallet.balanceOf(msg.sender));
    }
}