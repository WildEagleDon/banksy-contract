## Getting started

1. Create a new React application

```
npx create-react-app react-dapp
```

2. Change into **react-dapp** and install [`ethers.js`](https://docs.ethers.io/v5/) and [`hardhat`](https://github.com/nomiclabs/hardhat) using either **NPM** or **Yarn**

```
npm install ethers hardhat @nomiclabs/hardhat-waffle ethereum-waffle chai @nomiclabs/hardhat-ethers
```

3. Initialize a new Ethereum Development Environment with Hardhat

```
npx hardhat

? What do you want to do? Create a sample project
? Hardhat project root: <Choose default path>
```

4. Update **hardhat.config.js**  and **contracts/Greeter.sol**

5. Compile an ABI for the project

```
npx hardhat compile
```

6. Start the local test node

```
npx hardhat node
```

7. Deploy the contract

```
npx hardhat run scripts/deploy.js --network localhost
```

8. Update **src/App.js** with the values of your contract addresses (`greeterAddress` and `tokenAddress`)

9. Run the app

```
npm start
```