import { ethers, network } from "hardhat";
import { deploy, verify } from "../test/utils/helpers";

async function main() {
  let contract: any;

  contract = await deploy("Greeter", ["hello world"]);
  await contract.deployed();
  console.log("contract deployed to:", contract.address);

  await verify(network.name, contract.address, "hello world");
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
