import logo from './logo.svg';
import './App.css';
import { useState } from 'react';
import { ethers } from 'ethers';
import PlanetItem from './artifacts/contracts/PlanetItem.sol/PlanetItem.json'

const planetitemAddress = '0x8bc9B9e8b2f38c4E8b75eeD13F518Ee051972344'

function App() {
  // store greeting in local state
  const [userAccount, setUserAccount] = useState('')
  const [tokenUri, setTokenUri] = useState('')

  // request access to the user's Metamask account
  async function requestAccount() {
    await window.ethereum.request({ method: 'eth_requestAccounts' });
  }

  async function createNFT() {
    if (typeof window.ethereum !== 'undefined') {
      await requestAccount()
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(planetitemAddress, PlanetItem.abi, signer);
      const transaction = await contract.awardItem(userAccount, tokenUri);
      await transaction.wait();
      console.log(`One piece of NFT which uri is ${tokenUri} successfully sent to ${userAccount}`);
    }
  }

  async function getBalance() {
    if (typeof window.ethereum !== 'undefined') {
      const [account] = await window.ethereum.request({ method: 'eth_requestAccounts' })
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const contract = new ethers.Contract(planetitemAddress, PlanetItem.abi, provider)
      const balance = await contract.balanceOf(account);
      console.log("Balance: ", balance.toString());
    }
  }

  
  return (
    <div className="App">
      <header className="App-header">
        <button onClick={getBalance}>Get Balance</button>
        <button onClick={createNFT}>Create NFT</button>
        <input onChange={e => setUserAccount(e.target.value)} placeholder="Account ID" />
        <input onChange={e => setTokenUri(e.target.value)} placeholder="URL" />        
      </header>
    </div>
  );
}

export default App;
