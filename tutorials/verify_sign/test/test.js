const VerifySign = artifacts.require("VerifySign");

contract("split test", accounts => {
  before(async function () {
    [address] = await web3.eth.getAccounts();
    verifySign = await VerifySign.new();
  });

  it("sign hash by web3", async function() {
    hash = await web3.utils.sha3("hello world");
    sign = await web3.eth.sign(hash, address);
  });

  it("verify sign by web3", async function() {
    assert.equal(await web3.eth.accounts.recover(hash, sign), address);
  });

  it("verify sign by contract", async function() {
    assert.equal(await verifySign.verify(hash, sign), address);
  });
});