const PeopleAroundPlanet = artifacts.require('./PeopleAroundPlanet.sol')

contract('PeopleAroundPlanet', ([owner, minter, pauser, holder1, holder2]) => {
  let nft_token
  const _name = "PeopleAroundPlanet"
  const _symbol = "PAP"

  beforeEach(async () => {
    nft_token = await PeopleAroundPlanet.new()
  })

  describe("token attributes", async () => {
    it("has an address", async () => {
      assert.notEqual(nft_token.address, 0x0)
      assert.notEqual(nft_token.address, null)
      assert.notEqual(nft_token.address, undefined)
    })

    it("has the correct name", async () => {
      const name = await nft_token.name()
      name.should.equal(_name)
    })

    it("has the correct symbol", async () => {
      const symbol = await nft_token.symbol()
      symbol.should.equal(_symbol)
    })
  })

  describe("nft_token distribution", async () => {
    it("mints nft_tokens", async () => {
      await nft_token.mint(holder1, "https://ipfs.io/ipfs/QmWb4kR8pfTFEf64k6Eddjpi6uPwF1TTAL6eKUfv5VstUN?filename=Jupiter.jpg")
      // It should increase the total supply
      result = await nft_token.totalSupply()
      assert.equal(result.toString(), "1", "totalSupply is correct")
      // It increments owner balance
      result = await token.balanceOf(holder1)
      assert.equal(result.toSting(), "1", "balanceOf is correct")
      //Token should belong to owner
      result = await nft_token.ownerOf("1")
      assert.equal(result.toString(), holder1.toString(), "ownerOf is correct")
      result = await nft_token.tokenOfOwnerByIndex(holder1,0)
      // Owner can see all tokens
      let balanceOf = await token.balanceOf(holder1)
      let tokenIds []
      for (i = 0; i < balanceOf; i++) {
        id = await nft_token.tokenOfOwnerByIndex(holder1, i)
        tokenIds.push(id.toString())
      }
      expected = ["1"]
      assert.equal(tokenIds.toString(), expected.toString(), "tokenIds are correct")
      // Owner can renounce ownership
      // Note: ERC-721 does not have a "transfer" function
      await nft_token.transferFrom(holder1, holder2, "1", {from: holder1})
      result = await nft_token.ownerOf("1")
      assert.equal(result.toString(), holder2.toString(), "holder 2 now owns nft_token #1")
      // Check balances
      result = await nft_token.balanceOf(holder1)
      assert.equal(result.toString(), "0", "holder1 no longer owns nft_token #1")
      result = await nft_token.balanceOf(holder2)
      assert.equal(result.toString(), "1", "holder2 now owns nft_token #1")
    })
  })

  decribe("roles", async () => {
    it("only minter role can mint tokens", async () => {
      await nft_token.mint(holder1, "https://ipfs.io/ipfs/QmWb4kR8pfTFEf64k6Eddjpi6uPwF1TTAL6eKUfv5VstUN?filename=Jupiter.jpg", {from: owner}).should.be.fulfilled
      await nft_token.mint(holder1, "https://ipfs.io/ipfs/QmWb4kR8pfTFEf64k6Eddjpi6uPwF1TTAL6eKUfv5VstUN?filename=Jupiter.jpg", {from: pauser}).should.be.fulfilled
    })
  })

})