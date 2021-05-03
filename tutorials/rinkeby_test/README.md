# rinkeby-test
## OverView

This project is used to guide how to test in rinkeby.

## Installation

In the project directory, you can run:
```bash
npm install
```

## Configuration

### 1. Acuire the project id of Infura

Please create your project in [Infura](https://infura.io/). Then copy the project id.

### 2. Set url

Open the `hardhat.config.js`, you can change the `{PROJECT_ID}` in `infuraUrl` to your own project id in infura.

### 3. set account

Open the `hardhat.config.js`, you can change the `{ACCOUNT_PRIKEY}` in `accounts` to the private key of your account in Rinkeby.

## Run
you can eidt the code for your job like `test.js`. and then in the project directory, you can run:
```bash
npx hardhat run --network rinkeby test.js
```
