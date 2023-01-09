import { deploy, verify } from "../../test/utils/helpers";
import { ethers, network } from "hardhat";

async function main() {
  const name = "Froggy";
  const symbol = "FROG";
  const nft = await deploy("NFT", [name, symbol]);
  await nft.deployed();

  console.log(`NFT deployed to ${nft.address}`);

  await verify(network.name, nft.address, name, symbol);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
