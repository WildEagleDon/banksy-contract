const { expect } = require("chai");


describe("upgrade test", function() {
    it('upgrade', async () => {

    const MyContract1 = await ethers.getContractFactory("MyContract1");
    const MyContract2 = await ethers.getContractFactory("MyContract2");

    const mycontract1 = await upgrades.deployProxy(MyContract1, [10, true]);
    expect(await mycontract1.getValue()).to.equal(10);
    expect(await mycontract1.getFlag()).to.equal(true);
    
    const mycontract2 = await upgrades.upgradeProxy(mycontract1.address, MyContract2);
    expect(await mycontract2.getValue()).to.equal(10);
    expect(await mycontract2.getFlag()).to.equal(true);
    expect(await mycontract2.test()).to.equal("test");

  });

});