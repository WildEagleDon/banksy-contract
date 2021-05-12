
const Factory = artifacts.require("Factory");
const TestContract = artifacts.require("TestContract");

contract("factory test", accounts => {
  before(async function () {
    testTactory = await Factory.new((await TestContract.new()).address);
    
    noCloneInstance = await TestContract.new();
  });

  it("create instance", async function() {
    const createHandle1 = await testTactory.create();
    const createHandle2 = await testTactory.create();

    instance1 = await TestContract.at(createHandle1.receipt.logs.find(({ event}) => event == 'Created').args.newOne);
    instance2 = await TestContract.at(createHandle2.receipt.logs.find(({ event}) => event == 'Created').args.newOne);
  });

  
  it("instance test", async function() {
    await instance1.setName("MyInstance 1");
    await instance2.setName("MyInstance 2");

    assert.equal(await instance1.getName(), "MyInstance 1");
    assert.equal(await instance2.getName(), "MyInstance 2");
  });
 
  it("instance check", async function() {
    assert.equal(await testTactory.check(instance1.address), true);
    assert.equal(await testTactory.check(instance2.address), true);

    assert.equal(await testTactory.check(noCloneInstance.address), false);
  });

});