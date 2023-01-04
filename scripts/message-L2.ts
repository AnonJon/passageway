import { ethers } from "hardhat";
import config from "../config/network.config.json";
import l1controllerABI from "../artifacts/contracts/L1Controller.sol/L1Controller.json";

const pk = process.env.PRIVATE_KEY as string;
async function main() {
  const networkId = await ethers.provider.getNetwork();
  let controller: any;
  const signer = new ethers.Wallet(pk, ethers.provider);

  if (networkId.chainId === 5) {
    controller = new ethers.Contract(
      config.testnet.l1Controller.address,
      l1controllerABI.abi,
      signer
    );
  } else {
    throw new Error("Invalid network");
  }

  const tx = await controller.setGreeting("second try from L1");
  await tx.wait();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
