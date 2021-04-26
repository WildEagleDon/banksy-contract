# 1. Hardhat's tutorial for beginners

Hardhat is an Ethereum development environment for professionals. It facilitates performing frequent tasks, such as running tests, automatically checking code for mistakes or interacting with a smart contract.  

links: 

https://hardhat.org/tutorial/

https://github.com/nomiclabs/hardhat

In this tutorial we'll guide you through:

- Setting up your Node.js environment for Ethereum development
- Creating and configuring a **Hardhat** project
- The basics of a Solidity smart contract that implements a token
- Writing automated tests for your contract using [Ethers.js](https://docs.ethers.io/) and [Waffle](https://getwaffle.io/)
- Debugging Solidity with `console.log()` using **Hardhat Network**
- Deploying your contract to **Hardhat Network** and Ethereum testnets

To follow this tutorial you should be able to:

- Write code in [JavaScript](https://developer.mozilla.org/en-US/docs/Learn/Getting_started_with_the_web/JavaScript_basics)
- Operate a [terminal](https://en.wikipedia.org/wiki/Terminal_emulator)
- Use [git](https://git-scm.com/doc)
- Understand the basics of how [smart contracts](https://ethereum.org/learn/#smart-contracts) work
- Set up a [Metamask](https://metamask.io/) wallet

If you can't do any of the above, follow the links and take some time to learn the basics.

# 2. Setting up the environment

Most Ethereum libraries and tools are written in JavaScript, and so is **Hardhat**. If you're not familiar with Node.js, it's a JavaScript runtime built on Chrome's V8 JavaScript engine. It's the most popular solution to run JavaScript outside of a web browser and **Hardhat** is built on top of it.

## Installing Node.js

You can [skip](https://github.com/xilibi2003/tutorial-hardhat-deploy/blob/main/creating-a-new-hardhat-project.md) this section if you already have a working Node.js `>=12.0` installation. If not, here's how to install it on Ubuntu, MacOS and Windows.

### Linux

#### Ubuntu

Copy and paste these commands in a terminal:

```
sudo apt update
sudo apt install curl git
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt install nodejs
```

### MacOS

Make sure you have `git` installed. Otherwise, follow [these instructions](https://www.atlassian.com/git/tutorials/install-git).

There are multiple ways of installing Node.js on MacOS. We will be using [Node Version Manager (nvm)](http://github.com/creationix/nvm). Copy and paste these commands in a terminal:

```
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.35.2/install.sh | bash
nvm install 12
nvm use 12
nvm alias default 12
npm install npm --global # Upgrade npm to the latest version
```

### Windows

Installing Node.js on Windows requires a few manual steps. We'll install git, Node.js 12.x and npm. Download and run these:

1. [Git's installer for Windows](https://git-scm.com/download/win)
2. `node-v12.XX.XX-x64.msi` from [here](https://nodejs.org/dist/latest-v12.x)

## Upgrading your Node.js installation

If your version of Node.js is older than `12.0` follow the instructions below to upgrade.

### Linux

#### Ubuntu

1. Run `sudo apt remove nodejs` in a terminal to remove Node.js.
2. Find the version of Node.js that you want to install [here](https://github.com/nodesource/distributions#debinstall) and follow the instructions.
3. Run `sudo apt update && sudo apt install nodejs` in a terminal to install Node.js again.

### MacOS

You can change your Node.js version using [nvm](http://github.com/creationix/nvm). To upgrade to Node.js `12.x` run these in a terminal:

```
nvm install 12
nvm use 12
nvm alias default 12
npm install npm --global # Upgrade npm to the latest version
```

### Windows

You need to follow the [same installation instructions](https://github.com/xilibi2003/tutorial-hardhat-deploy#windows) as before but choose a different version. You can check the list of all available versions [here](https://nodejs.org/en/download/releases/).

## Installing yarn

To install it do the following: https://yarn.bootcss.com/docs/install/#debian-stable

# 3. Creating a new Hardhat project

We'll install **Hardhat** using the npm CLI. The **N**ode.js **p**ackage **m**anager is a package manager and an online repository for JavaScript code.

Open a new terminal and run these commands:

```
mkdir hardhat-tutorial
cd hardhat-tutorial
yarn init --yes
yarn add -D hardhat
```

:::Tip Installing **Hardhat** will install some Ethereum JavaScript dependencies, so be patient. :::

In the same directory where you installed **Hardhat** add a `hardhat.config.ts` (we are going to use typescript and use solidity 0.7.6 compiler)

```
import {HardhatUserConfig} from 'hardhat/types';
const config: HardhatUserConfig = {
  solidity: {
    version: '0.7.6',
  }
};
export default config;
```

## Hardhat's architecture

**Hardhat** is designed around the concepts of **tasks** and **plugins**. The bulk of **Hardhat**'s functionality comes from plugins, which as a developer [you're free to choose](https://github.com/xilibi2003/tutorial-hardhat-deploy/blob/main/plugins) the ones you want to use.

### Tasks

Every time you're running **Hardhat** from the CLI you're running a task. e.g. `npx hardhat compile` is running the `compile` task. To see the currently available tasks in your project, run `npx hardhat`. Feel free to explore any task by running `npx hardhat help [task]`.

::: Tip You can create your own tasks. Check out the [Creating a task](https://github.com/xilibi2003/tutorial-hardhat-deploy/blob/main/guides/create-task.md) guide. :::

### Plugins

**Hardhat** is unopinionated in terms of what tools you end up using, but it does come with some built-in defaults. All of which can be overriden. Most of the time the way to use a given tool is by consuming a plugin that integrates it into **Hardhat**.

For this tutorial we are going to use the hardhat-deploy-ethers and hardhat-deploy plugin. They'll allow you to interact with Ethereum and to test your contracts. We'll explain how they're used later on. We also install ethers chai and mocha and typescript. To install them, in your project directory run:

```
yarn add -D hardhat-deploy hardhat-deploy-ethers ethers chai chai-ethers mocha @types/chai @types/mocha @types/node typescript ts-node dotenv
```

Edit `hardhat.config.ts` so that it looks like this:

```
import {HardhatUserConfig} from 'hardhat/types';
import 'hardhat-deploy';
import 'hardhat-deploy-ethers';

const config: HardhatUserConfig = {
  solidity: {
    version: '0.7.6',
  },
  namedAccounts: {
    deployer: 0,
  },
};
export default config;
```

We also create the following `tsconfig.json` :

```
{
  "compilerOptions": {
    "target": "es5",
    "module": "commonjs",
    "strict": true,
    "esModuleInterop": true,
    "moduleResolution": "node",
    "forceConsistentCasingInFileNames": true,
    "outDir": "dist"
  },
  "include": [
    "hardhat.config.ts",
    "./scripts",
    "./deploy",
    "./test",
    "typechain/**/*"
  ]
}
```

# 4. Writing and compiling smart contracts

We're going to create a simple smart contract that implements a token that can be transferred. Token contracts are most frequently used to exchange or store value. We won't go in depth into the Solidity code of the contract on this tutorial, but there's some logic we implemented that you should know:

- There is a fixed total supply of tokens that can't be changed.
- The entire supply is assigned to the address that deploys the contract.
- Anyone can receive tokens.
- Anyone with at least one token can transfer tokens.
- The token is non-divisible. You can transfer 1, 2, 3 or 37 tokens but not 2.5.

::: Tip You might have heard about ERC20, which is a token standard in Ethereum. Tokens such as DAI, USDC, MKR and ZRX follow the ERC20 standard which allows them all to be compatible with any software that can deal with ERC20 tokens. **For simplicity's sake the token we're going to build is \*not\* an ERC20.** :::

## Writing smart contracts

While by default hardhat use `contracts` as the source folder, we prefers to change it to `src`.

You thus need to edit your `hardhat.config.ts` file with the new config :

```
import {HardhatUserConfig} from 'hardhat/types';
import 'hardhat-deploy';
import 'hardhat-deploy-ethers';

const config: HardhatUserConfig = {
  solidity: {
    version: '0.7.6',
  },
  namedAccounts: {
    deployer: 0,
  },
  paths: {
    sources: 'src',
  },
};
export default config;
```

Start by creating a new directory called `src` and create a file inside the directory called `Token.sol`.

Paste the code below into the file and take a minute to read the code. It's simple and it's full of comments explaining the basics of Solidity.

::: Tip To get syntax highlighting you should add Solidity support to your text editor. Just look for Solidity or Ethereum plugins. We recommend using Visual Studio Code or Sublime Text 3. :::

```
// SPDX-License-Identifier: MIT
// The line above is recommended and let you define the license of your contract
// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.7.0;


// This is the main building block for smart contracts.
contract Token {
    // Some string type variables to identify the token.
    // The `public` modifier makes a variable readable from outside the contract.
    string public name = "My Hardhat Token";
    string public symbol = "MBT";

    // The fixed amount of tokens stored in an unsigned integer type variable.
    uint256 public totalSupply = 1000000;

    // An address type variable is used to store ethereum accounts.
    address public owner;

    // A mapping is a key/value map. Here we store each account balance.
    mapping(address => uint256) balances;

    /**
     * Contract initialization.
     *
     * The `constructor` is executed only once when the contract is created.
     */
    constructor(address _owner) {
        // The totalSupply is assigned to transaction sender, which is the account
        // that is deploying the contract.
        balances[_owner] = totalSupply;
        owner = _owner;
    }

    /**
     * A function to transfer tokens.
     *
     * The `external` modifier makes a function *only* callable from outside
     * the contract.
     */
    function transfer(address to, uint256 amount) external {
        // Check if the transaction sender has enough tokens.
        // If `require`'s first argument evaluates to `false` then the
        // transaction will revert.
        require(balances[msg.sender] >= amount, "Not enough tokens");

        // Transfer the amount.
        balances[msg.sender] -= amount;
        balances[to] += amount;
    }

    /**
     * Read only function to retrieve the token balance of a given account.
     *
     * The `view` modifier indicates that it doesn't modify the contract's
     * state, which allows us to call it without executing a transaction.
     */
    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }
}
```

::: Tip `*.sol` is used for Solidity files. We recommend matching the file name to the contract it contains, which is a common practice. :::

## Compiling contracts

To compile the contract run `yarn hardhat compile` in your terminal. The `compile` task is one of the built-in tasks.

```
$ yarn hardhat compile
Compiling 1 file with 0.7.3
Compilation finished successfully
```

The contract has been successfully compiled and it's ready to be used.

# 5. Deployments Scripts

Before being able to test or deploy contract, you can setup the deployment that can then be used both in test and when you are ready to deploy. This allow you to focus on what the contract will be in their final form, setup their parameters and dependencies and ensure your test are testing what will be deployed. This also remove the need to duplicate the deployment procedures

## Writing deployments scripts

Create a new directory called `deploy` inside our project root directory and create a new file called `001_deploy_token.ts`.

Let's start with the code below. We'll explain it next, but for now paste this into `001_deploy_token.ts`:

```
import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction} from 'hardhat-deploy/types';

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const {deployments, getNamedAccounts} = hre;
  const {deploy} = deployments;

  const {deployer, tokenOwner} = await getNamedAccounts();

  await deploy('Token', {
    from: deployer,
    args: [tokenOwner],
    log: true,
  });
};
export default func;
func.tags = ['Token'];
```

Notice the mentioned of `getNamedAccounts` ?

the plugin `hardhat-deploy` allows you to name your accounts. Here there are 2 named accounts:

- deployer that will is account used to deploy the contract
- tokenOwner which is potentially another account that is passed to the constructor of Token.sol. It will receive the initial supply

These accounts need to be setup in hardhat.config.ts

Modifiy it so it looks like this :

```
import {HardhatUserConfig} from 'hardhat/types';
import 'hardhat-deploy';
import 'hardhat-deploy-ethers';

const config: HardhatUserConfig = {
  solidity: {
    version: '0.7.6',
  },
  namedAccounts: {
    deployer: 0,
    tokenOwner: 1,
  },
  paths: {
    sources: 'src',
  },
};
export default config;
```

`deployer` was already there and is setup to use the first account (index = 0)

`tokenOwner` is the second account

On your terminal run `yarn hardhat deploy`. You should see the following output:

```
Nothing to compile
deploying "Token" (tx: 0x8b8556d7b954a73d6daf26baac7f6803b473ae3c735ad2cd6656148a3103c56a)...: deployed at 0x5FbDB2315678afecb367f032d93F642f64180aa3 with 483242 gas
Done in 22.16s.
```

This deployment was made in the `in-memory` hardhat network and indicate that deployment was succesful.

We can now write tests against this contract. its name is set to be the same name as the contract name: `Token`

But let's add comments to the deploy script above to explain each line that matters :

```
import {HardhatRuntimeEnvironment} from 'hardhat/types'; // this add the type from hardhat runtime environment
import {DeployFunction} from 'hardhat-deploy/types'; // this add the type that a deploy function is expected to fullfil

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) { // the deploy function receive the hardhat runtime env as argument
  const {deployments, getNamedAccounts} = hre; // we get the deployments and getNamedAccounts which are provided by hardhat-deploy
  const {deploy} = deployments; // the deployments field itself contains the deploy function

  const {deployer, tokenOwner} = await getNamedAccounts(); // we fetch the accounts. These can be configured in hardhat.config.ts as explained above

  await deploy('Token', { // this will create a deployment called 'Token'. By default it will look for an artifact with the same name. the contract option allows you to use a different artifact
    from: deployer, // deployer will be performing the deployment transaction
    args: [tokenOwner], // tokenOwner is the address used as the first argument to the Token contract's constructor
    log: true, // display the address and gas used in the console (not when run in test though)
  });
};
export default func;
func.tags = ['Token']; // this setup a tag so you can execute the script on its own (and its dependencies)
```

# 6. Testing contracts

Writing automated tests when building smart contracts is of crucial importance, as your user's money is what's at stake. For this we're going to use **Hardhat Network**, a local Ethereum network designed for development that is built-in and the default network in **Hardhat**. You don't need to setup anything to use it. In our tests we're going to use ethers.js to interact with the Ethereum contract we built in the previous section, and [Mocha](https://mochajs.org/) as our test runner.

## Writing tests

Create a new directory called `test` inside our project root directory and create a new file called `001_test_Token.ts`.

Let's start with the code below. We'll explain it next, but for now paste this into `001_test_Token.ts`:

```
import {expect} from "./chai-setup";

import {ethers, deployments, getNamedAccounts} from 'hardhat';

describe("Token contract", function() {
  it("Deployment should assign the total supply of tokens to the owner", async function() {
    await deployments.fixture(["Token"]);
    const {tokenOwner} = await getNamedAccounts();
    const Token = await ethers.getContract("Token");
    const ownerBalance = await Token.balanceOf(tokenOwner);
    const supply = await Token.totalSupply();
    expect(ownerBalance).to.equal(supply);
  });
});
```

We also create a file called `chai-setup.ts` in the test folder too:

```
import chaiModule from 'chai';
import {chaiEthers} from 'chai-ethers';
chaiModule.use(chaiEthers);
export = chaiModule;
```

This will use chai matchers from `chai-ethers` but also allow you to easily add more.

Then on your terminal run `npx hardhat test`. You should see the following output:

```
$ npx hardhat test

  Token contract
    ✓ Deployment should assign the total supply of tokens to the owner (7442ms)


  1 passing (7s)
```

This means the test passed. Let's now explain each line:

```
await deployments.fixture(["Token"]);
```

Remember the deploy script you wrote earlier. this line allow to execute it prior to the test. It also generate a evm_snapshot automatically so if you write many test and they all refers to that fixture, behind the scene it does not deploy it again and again. Instead it revert to a previous state, speeding up yoru tests automatically

```
const {tokenOwner} = await getNamedAccounts();
```

This give you access to the tokenOwner address, the same one that was used in the deploy script.

```
const Token = await ethers.getContract("Token");
```

Since we already perform the deploy script, we can easily access the deployed contract via name. This is what this line does and thanks to `hardhat-deploy-ethers` plugin, you get an ethers contract ready to be invoked. If you needed that contract to be associated to a specific signer, you can pass the address as the extra argument like `const TokenAsOwner = await ethers.getContract('Token', tokenOwner);`

```
const ownerBalance = await Token.balanceOf(tokenOwner);
```

We can call our contract methods on `Token` and use them to get the balance of the owner account by calling `balanceOf()`.

```
const supply = await Token.totalSupply();
```

Here we're again using our `Contract` instance to call a smart contract function in our Solidity code. `totalSupply()` returns the token's supply amount.

```
expect(ownerBalance).to.equal(supply);
```

Finally we're checking that it's equal to `ownerBalance`, as it should.

To do this we're using [Chai](https://www.chaijs.com/) which is an assertions library. These asserting functions are called "matchers", and the ones we're using here actually come from `chai-ethers` npm package (which itself is a fork of [Waffle chai matchers](https://getwaffle.io/) without unecessary dependencies).

### Using a different account

If you need to send a transaction from an account other than the default one to test your code, you can use the second argument of `getContract` .

Create a new file called `002_test_Token.ts` and paste this into `002_test_Token.ts`:

```
import {expect} from "./chai-setup";

import {ethers, deployments, getNamedAccounts, getUnnamedAccounts} from 'hardhat';

describe("Token contract", function() {
  it("Deployment should assign the total supply of tokens to the owner", async function() {
    await deployments.fixture(["Token"]);
    const {tokenOwner} = await getNamedAccounts();
    const users = await getUnnamedAccounts();
    const TokenAsOwner = await ethers.getContract("Token", tokenOwner);
    await TokenAsOwner.transfer(users[0], 50);
    expect(await TokenAsOwner.balanceOf(users[0])).to.equal(50);

    const TokenAsUser0 = await ethers.getContract("Token", users[0]);
    await TokenAsUser0.transfer(users[1], 50);
    expect(await TokenAsOwner.balanceOf(users[1])).to.equal(50);
  });
});
```

### Full coverage

Now that we've covered the basics you'll need for testing your contracts, here's a full test suite for the token with a lot of additional information about Mocha and how to structure your tests. We recommend reading through.

But first we add some utility functions that we will use in that test suite.

create a folder `utils` in the `test` folder and create a file `index.ts` in it with the following content :

```
import {Contract} from 'ethers';
import {ethers} from 'hardhat';

export async function setupUsers<T extends {[contractName: string]: Contract}>(
  addresses: string[],
  contracts: T
): Promise<({address: string} & T)[]> {
  const users: ({address: string} & T)[] = [];
  for (const address of addresses) {
    users.push(await setupUser(address, contracts));
  }
  return users;
}

export async function setupUser<T extends {[contractName: string]: Contract}>(
  address: string,
  contracts: T
): Promise<{address: string} & T> {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const user: any = {address};
  for (const key of Object.keys(contracts)) {
    user[key] = contracts[key].connect(await ethers.getSigner(address));
  }
  return user as {address: string} & T;
}
```

Here is the full test suite, create a new file called `003_test_Token.ts` and paste this into `003_test_Token.ts`:

```
// We import Chai to use its asserting functions here.
import {expect} from "./chai-setup";

// we import our utilities
import {setupUsers, setupUser} from './utils';

// We import the hardhat environment field we are planning to use
import {ethers, deployments, getNamedAccounts, getUnnamedAccounts} from 'hardhat';

// we create a stup function that can be called by every test and setup variable for easy to read tests
async function setup () {
  // it first ensure the deployment is executed and reset (use of evm_snaphost for fast test)
  await deployments.fixture(["Token"]);

  // we get an instantiated contract in teh form of a ethers.js Contract instance:
  const contracts = {
    Token: (await ethers.getContract('Token')),
  };

  // we get the tokenOwner
  const {tokenOwner} = await getNamedAccounts();
  // get fet unnammedAccounts (which are basically all accounts not named in the config, useful for tests as you can be sure they do not have been given token for example)
  // we then use the utilities function to generate user object/
  // These object allow you to write things like `users[0].Token.transfer(....)`
  const users = await setupUsers(await getUnnamedAccounts(), contracts);
  // finally we return the whole object (including the tokenOwner setup as a User object)
  return {
    ...contracts,
    users,
    tokenOwner: await setupUser(tokenOwner, contracts),
  };
}

// `describe` is a Mocha function that allows you to organize your tests. It's
// not actually needed, but having your tests organized makes debugging them
// easier. All Mocha functions are available in the global scope.

// `describe` receives the name of a section of your test suite, and a callback.
// The callback must define the tests of that section. This callback can't be
// an async function.
describe("Token contract", function() {

  // You can nest describe calls to create subsections.
  describe("Deployment", function () {
    // `it` is another Mocha function. This is the one you use to define your
    // tests. It receives the test name, and a callback function.

    // If the callback function is async, Mocha will `await` it.
    it("Should set the right owner", async function () {
      // Expect receives a value, and wraps it in an Assertion object. These
      // objects have a lot of utility methods to assert values.

      // before the test, we call the fixture function.
      // while mocha have hooks to perform these automatically, they force you to declare the variable in greater scope which can introduce subttle errors
      // as such we prefers to have the setup called right at the beginning of the test. this also allow yout o name it accordingly for easier to read tests.
      const {Token} = await setup();


      // This test expects the owner variable stored in the contract to be equal to our configured owner
      const {tokenOwner} = await getNamedAccounts();
      expect(await Token.owner()).to.equal(tokenOwner);
    });

    it("Should assign the total supply of tokens to the owner", async function () {
      const {Token, tokenOwner} = await setup();
      const ownerBalance = await Token.balanceOf(tokenOwner.address);
      expect(await Token.totalSupply()).to.equal(ownerBalance);
    });
  });

  describe("Transactions", function () {
    it("Should transfer tokens between accounts", async function () {
      const {Token, users, tokenOwner} = await setup();
      // Transfer 50 tokens from owner to users[0]
      await tokenOwner.Token.transfer(users[0].address, 50);
      const users0Balance = await Token.balanceOf(users[0].address);
      expect(users0Balance).to.equal(50);

      // Transfer 50 tokens from users[0] to users[1]
      // We use .connect(signer) to send a transaction from another account
      await users[0].Token.transfer(users[1].address, 50);
      const users1Balance = await Token.balanceOf(users[1].address);
      expect(users1Balance).to.equal(50);
    });

    it("Should fail if sender doesn’t have enough tokens", async function () {
      const {Token, users, tokenOwner} = await setup();
      const initialOwnerBalance = await Token.balanceOf(tokenOwner.address);

      // Try to send 1 token from users[0] (0 tokens) to owner (1000 tokens).
      // `require` will evaluate false and revert the transaction.
      await expect(users[0].Token.transfer(tokenOwner.address, 1)
      ).to.be.revertedWith("Not enough tokens");

      // Owner balance shouldn't have changed.
      expect(await Token.balanceOf(tokenOwner.address)).to.equal(
        initialOwnerBalance
      );
    });

    it("Should update balances after transfers", async function () {
      const {Token, users, tokenOwner} = await setup();
      const initialOwnerBalance = await Token.balanceOf(tokenOwner.address);

      // Transfer 100 tokens from owner to users[0].
      await tokenOwner.Token.transfer(users[0].address, 100);

      // Transfer another 50 tokens from owner to users[1].
      await tokenOwner.Token.transfer(users[1].address, 50);

      // Check balances.
      const finalOwnerBalance = await Token.balanceOf(tokenOwner.address);
      expect(finalOwnerBalance).to.equal(initialOwnerBalance - 150);

      const users0Balance = await Token.balanceOf(users[0].address);
      expect(users0Balance).to.equal(100);

      const users1Balance = await Token.balanceOf(users[1].address);
      expect(users1Balance).to.equal(50);
    });
  });
});
```

This is what the output of `yarn hardhat test` should look like against the full test suite:

```
$ yarn hardhat test

  Token contract
    ✓ Deployment should assign the total supply of tokens to the owner (7583ms)

  Token contract
    ✓ Deployment should assign the total supply of tokens to the owner (73ms)

  Token contract
    Deployment
      ✓ Should set the right owner
      ✓ Should assign the total supply of tokens to the owner
    Transactions
      ✓ Should transfer tokens between accounts (79ms)
      ✓ Should fail if sender doesn’t have enough tokens (107ms)
      ✓ Should update balances after transfers (70ms)


  7 passing (8s)
```

Keep in mind that when you run `yarn hardhat test`, your contracts will be compiled if they've changed since the last time you ran your tests.

# 7. Debugging with Hardhat Network

**Hardhat** comes built-in with **Hardhat Network**, a local Ethereum network designed for development. It allows you to deploy your contracts, run your tests and debug your code. It's the default network **Hardhat** connects to, so you don't need to setup anything for it to work. Just run your tests.

## Solidity `console.log`

When running your contracts and tests on **Hardhat Network** you can print logging messages and contract variables calling `console.log()` from your Solidity code. To use it you have to import **Hardhat**'s`console.log` from your contract code.

This is what it looks like:

```
pragma solidity 0.7.6;

import "hardhat/console.sol";

contract Token {
  //...
}
```

Add some `console.log` to the `transfer()` function as if you were using it in JavaScript:

```
function transfer(address to, uint256 amount) external {
    console.log("Sender balance is %s tokens", balances[msg.sender]);
    console.log("Trying to send %s tokens to %s", amount, to);

    require(balances[msg.sender] >= amount, "Not enough tokens");

    balances[msg.sender] -= amount;
    balances[to] += amount;
}
```

The logging output will show when you run your tests:

```
$ yarn hardhat test

  Token contract
    ✓ Deployment should assign the total supply of tokens to the owner (7476ms)

  Token contract
Sender balance is 1000000 tokens
Trying to send 50 tokens to 0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc
Sender balance is 50 tokens
Trying to send 50 tokens to 0x90f79bf6eb2c4f870365e785982e1f101e93b906
    ✓ Deployment should assign the total supply of tokens to the owner (107ms)

  Token contract
    Deployment
      ✓ Should set the right owner
      ✓ Should assign the total supply of tokens to the owner (39ms)
    Transactions
Sender balance is 1000000 tokens
Trying to send 50 tokens to 0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc
Sender balance is 50 tokens
Trying to send 50 tokens to 0x90f79bf6eb2c4f870365e785982e1f101e93b906
      ✓ Should transfer tokens between accounts (104ms)
Sender balance is 0 tokens
Trying to send 1 tokens to 0x70997970c51812dc3a010c7d01b50e0d17dc79c8
      ✓ Should fail if sender doesn’t have enough tokens (105ms)
Sender balance is 1000000 tokens
Trying to send 100 tokens to 0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc
Sender balance is 999900 tokens
Trying to send 50 tokens to 0x90f79bf6eb2c4f870365e785982e1f101e93b906
      ✓ Should update balances after transfers (115ms)


  7 passing (8s)
```

Check out the [documentation](https://github.com/xilibi2003/tutorial-hardhat-deploy/blob/main/hardhat-network/README.md#console-log) to learn more about this feature.