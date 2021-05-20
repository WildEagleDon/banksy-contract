require("@nomiclabs/hardhat-waffle");

task("accounts", "Prints the list of accounts", async () => {
  const accounts = await ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  defaultNetwork: "hardhat",
  solidity: "0.8.3",
  paths: {
    artifacts: './src/artifacts',
  },
  networks: {
    hardhat: {
      chainId: 1337
    },
    ropsten: {
      url: "https://ropsten.infura.io/v3/0cf884db4f6849d79931eab624f34128",
      accounts: [`0xba3b25024fbbd5f1471100167c7bdc87bf02ce478e94ca61ecaf0cf144a237a9`]
      //accounts: [`0x${your-private-key}`]
      //accounts: [process.env.a2key]
      //accounts: ['0x${process.env.ACCOUNT_KEY}']
    },
    rinkeby: {
      url: "https://rinkeby.infura.io/v3/0cf884db4f6849d79931eab624f34128",
      accounts: [`0xba3b25024fbbd5f1471100167c7bdc87bf02ce478e94ca61ecaf0cf144a237a9`]
      //accounts: [`0x${your-private-key}`]
      //accounts: [process.env.a2key]
      //accounts: ['0x${process.env.ACCOUNT_KEY}']
    }

  }
};

