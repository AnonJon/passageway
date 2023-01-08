import { ethers, network } from "hardhat";
import { deploy, verify, deployBySigner } from "../../test/utils/helpers";
import config from "../../config/network.config.json";

async function main() {
  let contract: any;

  contract = await deploy("L2Bridge", [
    config.testnet.l2CrossDomainMessenger.address,
    config.testnet.l1Bridge.address,
    config.testnet.l2Template.address,
  ]);
  await contract.deployed();
  console.log("contract deployed to:", contract.address);
  await verify(
    network.name,
    contract.address,
    config.testnet.l2CrossDomainMessenger.address,
    config.testnet.l1Bridge.address,
    config.testnet.l2Template.address
  );
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
