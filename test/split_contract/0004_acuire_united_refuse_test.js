const tests = require("@daonomic/tests-common");

const SplitWallet = artifacts.require("SplitWallet");
const Governance = artifacts.require("Governance");
const BasicSplitAgent = artifacts.require("BasicSplitAgent");
const AcquisitionAgent = artifacts.require("AcquisitionAgent");
const NFT = artifacts.require("NFT");
// 修改acuisition 对应的token个数*1e18

contract("acuire united refuse test", accounts => {
  before(async function () {

    [owner, account1, account2, account3] = await web3.eth.getAccounts();

    governance = await Governance.new();
    
    splitWalletTemplate = await SplitWallet.new();
    basicSplitAgent = await BasicSplitAgent.new(governance.address);
    acquisitionAgent = await AcquisitionAgent.new(governance.address);
    nft = await NFT.new();

    await governance.setWalletTemplate(splitWalletTemplate.address);
    await governance.addAgent(basicSplitAgent.address);
    await governance.addAgent(acquisitionAgent.address);

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
    await basicSplitAgent.start(wallet.address,[owner, account1, account2], [100, 200, 300]);

    assert.equal(await wallet.balanceOf(owner), 100);
    assert.equal(await wallet.balanceOf(account1), 200);
    assert.equal(await wallet.balanceOf(account2), 300);
     
      // check the owner of wallet
    assert.equal(await wallet.owner(), 0);
    
 
  });

  it("transfer with token", async function() { 
    await wallet.transfer(owner, 10, { from: account1, gasPrice: 0 });
      
    // check token on the wallet
    assert.equal(await wallet.balanceOf(owner), 110);
    assert.equal(await wallet.balanceOf(account1), 190);
    assert.equal(await wallet.balanceOf(account2), 300);
    

  });

  
  it("acquisition start", async function() {
    // acuire all token 
    await tests.verifyBalanceChange(acquisitionAgent.address, -4900, async() =>
      await tests.verifyBalanceChange(owner, 4900, async () => 
        await acquisitionAgent.start(wallet.address, 10, { from: owner, value: (300 + 190) * 10, gasPrice: 0 })
      )
    );
    
    assert.equal(await wallet.balanceOf(owner), 0);
    assert.equal(await wallet.balanceOf(account1), 190);
    assert.equal(await wallet.balanceOf(account2), 300);
    assert.equal(await wallet.balanceOf(acquisitionAgent.address), 110);

    // check ehter on the ethereum
    assert.equal(await web3.eth.getBalance(acquisitionAgent.address), 490 * 10);
  });

  it("acquisition refuse 1", async function() {
    // simulate time running
    await tests.verifyBalanceChange(acquisitionAgent.address, -500, async() =>
      await tests.verifyBalanceChange(account1, 500, async () => 
        await acquisitionAgent.refuse(wallet.address, {from: account1, value: 50 * 10, gasPrice: 0})
      )
    );
    const {finished, accepted} = await acquisitionAgent.isFinish(wallet.address);

    assert.equal(finished, false);
    assert.equal(accepted, false);

    assert.equal(await wallet.owner(), acquisitionAgent.address);
    assert.equal(await wallet.balanceOf(owner), 0);
    assert.equal(await wallet.balanceOf(account1), 190 + 50);
    assert.equal(await wallet.balanceOf(account2), 300);
    assert.equal(await wallet.balanceOf(acquisitionAgent.address), 60);
    
  });
  
  it("acquisition refuse 2", async function() {
    await tests.verifyBalanceChange(owner, -6000, async() =>
      await tests.verifyBalanceChange(acquisitionAgent.address, 4900 + 500, async() =>
        await tests.verifyBalanceChange(account2, 600, async () => 
          await acquisitionAgent.refuse(wallet.address, {from: account2, value: 60 * 10, gasPrice: 0})
        )
      )
    );

    const {finished, accepted} = await acquisitionAgent.isFinish(wallet.address);
    assert.equal(finished, true);
    assert.equal(accepted, false);   

    assert.equal(await wallet.owner(), 0);
    assert.equal(await wallet.balanceOf(owner), 0);
    assert.equal(await wallet.balanceOf(account1), 190 + 50);
    assert.equal(await wallet.balanceOf(account2), 300 + 60);
    assert.equal(await wallet.balanceOf(acquisitionAgent.address), 0);
  });

  it("acquisition refuse 3", async function() {
    await tests.expectThrow(acquisitionAgent.refuse(wallet.address, {from: account3, value: 160 * 10, gasPrice: 0}));
  });

  it("acquisition retrieve whitout acception", async function() {
    await tests.expectThrow(acquisitionAgent.retrieve(wallet.address, {from: owner, gasPrice: 0}));
  });

  it("acquisition claim whitout acception", async function() { 
    await tests.expectThrow(acquisitionAgent.claim(wallet.address, {from: account1, gasPrice: 0}));
  });
});