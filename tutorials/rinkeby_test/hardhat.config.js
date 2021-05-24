require("@nomiclabs/hardhat-ethers");
/**
 * @type import('hardhat/config').HardhatUserConfig
 */
const infuraUrl = 'https://rinkeby.infura.io/v3/{PROJECT_ID}';
const accounts = ['{ACCOUNT_PRIKEY}'];

module.exports = {
  solidity: "0.7.3",
  networks: {
    rinkeby: {
      url: infuraUrl,
      accounts: accounts
    }
  }
};
