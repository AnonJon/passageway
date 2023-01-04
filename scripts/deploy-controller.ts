import { ethers, network } from "hardhat";
import { deploy, verify } from "../test/utils/helpers";
import config from "../config/network.config.json";

async function main() {
  const networkId = await ethers.provider.getNetwork();
  const l2baseAddress: string = config.testnet.l2BaseState.address;
  const l1baseAddress: string = config.testnet.l1BaseState.address;
  let controller: any;

  if (networkId.chainId === 5) {
    controller = await deploy("L1Controller", [l2baseAddress]);
    console.log("contract deployed to:", controller.address);
    await verify(network.name, controller.address, l2baseAddress);
  } else if (networkId.chainId === 420) {
    controller = await deploy("L2Controller", [l1baseAddress]);
    console.log("contract deployed to:", controller.address);
    await verify(network.name, controller.address, l1baseAddress);
  }
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
