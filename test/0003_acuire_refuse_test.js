const tests = require("@daonomic/tests-common");

const SplitWallet = artifacts.require("SplitWallet");
const Governance = artifacts.require("Governance");
const BasicSplitAgent = artifacts.require("BasicSplitAgent");
const AcquisitionAgent = artifacts.require("AcquisitionAgent");
const NFT = artifacts.require("NFT");
// 修改acuisition 对应的token个数*1e18

contract("acuire refuse test", accounts => {
  before(async function () {

    [owner, account1] = await web3.eth.getAccounts();

    governance = await Governance.new();
    splitWalletTemplate = await SplitWallet.new();
    basicSplitAgent = await BasicSplitAgent.new(governance.address);
    acquisitionAgent = await AcquisitionAgent.new(governance.address);
    nft = await NFT.new();

    await governance.setWalletTemplate(splitWalletTemplate.address);
    await governance.setAgentEnabled(basicSplitAgent.address, true);
    await governance.setAgentEnabled(acquisitionAgent.address, true);

    const { receipt } = await governance.createWallet();
    wallet = await SplitWallet.at(receipt.logs.find(({ event}) => event == 'CreatedWallet').args.newWallet);
			
    await wallet.init("TESTTocken","TT", owner, governance.address);
  });

  it("agent for NFT", async function() {
    // add item to ERC721 
    await nft.awardItem(owner,"test item");
    // transfer the NTF to splitwallet
    tokenId = await nft.tokenOfOwnerByIndex(owner, 0);
    await nft.transferFrom(owner, wallet.address, tokenId);

    // check the owner of the NFT
    assert.equal(await nft.ownerOf(tokenId), wallet.address);

  });

  
  it("split wallet", async function() {
    await basicSplitAgent.start(wallet.address,[owner, account1], [100, 200]);

    assert.equal(await wallet.balanceOf(owner), 100);
    assert.equal(await wallet.balanceOf(account1), 200);
     
      // check the owner of wallet
    assert.equal(await wallet.owner(), 0);
    
 
  });

  it("transfer with token", async function() { 
    await wallet.transfer(owner, 10, { from: account1 });
      
    // check token on the wallet
    assert.equal(await wallet.balanceOf(owner), 110);
    assert.equal(await wallet.balanceOf(account1), 190);
    

  });

  
  it("acquisition start", async function() {
    // acuire all token 
    
    await acquisitionAgent.start(wallet.address, 10, { from: owner, value: 190 * 10 });
    
    assert.equal(await wallet.balanceOf(owner), 0);
    assert.equal(await wallet.balanceOf(account1), 190);
    assert.equal(await wallet.balanceOf(acquisitionAgent.address), 110);

    // check ehter on the ethereum
    assert.equal(await web3.eth.getBalance(acquisitionAgent.address), 190 * 10);
  });

  it("acquisition refuse", async function() {
    // simulate time running

    await acquisitionAgent.refuse(wallet.address, {from: account1, value: 110 * 10});
    const {finished, accepted} = await acquisitionAgent.isFinish(wallet.address);

    assert.equal(finished, true);
    assert.equal(accepted, false);   

    assert.equal(await wallet.owner(), 0);
    assert.equal(await wallet.balanceOf(owner), 0);
    assert.equal(await wallet.balanceOf(account1), 300);
  });

  it("acquisition retrieve whitout acception", async function() {
    const {finished, accepted} = await acquisitionAgent.isFinish(wallet.address);

    assert.equal(finished, true);
    assert.equal(accepted, false);
    
    await tests.expectThrow(acquisitionAgent.retrieve(wallet.address, {from: owner}));
  });

});