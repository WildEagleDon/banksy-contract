const tests = require("@daonomic/tests-common");

const SplitWallet = artifacts.require("SplitWallet");
const Governance = artifacts.require("Governance");
const BasicSplitAgent = artifacts.require("BasicSplitAgent");
const AcquisitionAgent = artifacts.require("AcquisitionAgent");
const TestAcquisitionAgent = artifacts.require("TestAcquisitionAgent");
const NFT = artifacts.require("NFT");

contract("acuire agent update test", accounts => {
  before(async function () {

    [owner, account1] = await web3.eth.getAccounts();

    governance = await Governance.new();
    splitWalletTemplate = await SplitWallet.new();
    basicSplitAgent = await BasicSplitAgent.new(governance.address);
    acquisitionAgent = await AcquisitionAgent.new(governance.address);
    testAcquisitionAgent = await TestAcquisitionAgent.new(governance.address);
    nft = await NFT.new();

    await governance.setWalletTemplate(splitWalletTemplate.address);
    await governance.addAgent(basicSplitAgent.address);
    await governance.addAgent(acquisitionAgent.address);
    await governance.updateAgent(acquisitionAgent.address, testAcquisitionAgent.address);

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
    await wallet.transfer(owner, 10, { from: account1 , gasPrice: 0});
      
    // check token on the wallet
    assert.equal(await wallet.balanceOf(owner), 110);
    assert.equal(await wallet.balanceOf(account1), 190);
    

  });

  it("old acquisition start", async function() {
    await tests.expectThrow(acquisitionAgent.start(wallet.address, 10, { from: owner, value: 190 * 10, gasPrice: 0}));   
  });

  it("new acquisition start", async function() {
    // acuire all token 
    await tests.verifyBalanceChange(testAcquisitionAgent.address, -1900, async() =>
      await tests.verifyBalanceChange(owner, 1900, async () => 
        await testAcquisitionAgent.start(wallet.address, 10, { from: owner, value: 190 * 10, gasPrice: 0})
      )
    );

    
    assert.equal(await wallet.balanceOf(owner), 0);
    assert.equal(await wallet.balanceOf(account1), 190);
    assert.equal(await wallet.balanceOf(testAcquisitionAgent.address), 110);

    // check ehter on the ethereum
    assert.equal(await web3.eth.getBalance(testAcquisitionAgent.address), 1900);


  });

  it("acquisition retrieve whitout acception", async function() {
    const {finished, accepted} = await testAcquisitionAgent.isFinish(wallet.address);

    assert.equal(finished, false);
    assert.equal(accepted, false);
    
    await tests.expectThrow(testAcquisitionAgent.retrieve(wallet.address, {from: owner, gasPrice: 0}));

    await tests.expectThrow(wallet.functionCallWithValue(
      nft.address,'0',
      nft.contract.methods.safeTransferFrom(wallet.address, owner, 1).encodeABI(),
      { from: owner }
    ));
  });

  it("acquisition timeout", async function() {
    // simulate time running
    await tests.increaseTime(11);
    const {finished, accepted} = await testAcquisitionAgent.isFinish(wallet.address);

    assert.equal(finished, true);
    assert.equal(accepted, true);

  });

  it("acquisition retrieve", async function() { 
    //retrieve wallet owner
    
    await testAcquisitionAgent.retrieve(wallet.address, {from: owner, gasPrice: 0});

    assert.equal(await wallet.owner(), owner);
    
    assert.equal(await wallet.totalSupply(), 190);
  });

  it("acquisition claim", async function() { 
    //retrieve wallet owner
    
    await tests.verifyBalanceChange(account1, -1900, async() =>
      await tests.verifyBalanceChange(testAcquisitionAgent.address, 1900, async () => 
        await testAcquisitionAgent.claim(wallet.address, {from: account1, gasPrice: 0})
      )
    )
    assert.equal(await wallet.balanceOf(owner), 0);
    assert.equal(await wallet.balanceOf(account1), 0);
    assert.equal(await wallet.totalSupply(), 0);
  });

  it("take back NFT", async function() { 
    await wallet.functionCallWithValue(
      nft.address,'0',
      nft.contract.methods.safeTransferFrom(wallet.address, owner, 1).encodeABI(),
      { from: owner }
    );

    assert.equal(await nft.ownerOf(tokenId), owner);
  });

});