import { ethers, network } from "hardhat";
import { deploy, verify } from "../../test/utils/helpers";

async function main() {
  let contract: any;

  contract = await deploy("L1Bridge");
  await contract.deployed();
  console.log("contract deployed to:", contract.address);

  await verify(network.name, contract.address);
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
