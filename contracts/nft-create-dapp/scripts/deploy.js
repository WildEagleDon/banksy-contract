const hre = require("hardhat");

async function main() {
  const PlanetItem = await hre.ethers.getContractFactory("PlanetItem");
  const planetitem = await PlanetItem.deploy();
  await planetitem.deployed();
  console.log("PlanetItem deployed to:", planetitem.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
