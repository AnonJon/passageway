import { crossChainMessenger, messageStatus } from "../src/messanger";
import { ethers } from "hardhat";
import config from "../config/network.config.json";
import l2controllerABI from "../artifacts/contracts/L2Controller.sol/L2Controller.json";

async function main() {
  const pk = process.env.PRIVATE_KEY as string;
  const networkId = await ethers.provider.getNetwork();
  const signer = new ethers.Wallet(pk, ethers.provider);

  let hash: string, controller: any;

  if (networkId.chainId === 420) {
    controller = new ethers.Contract(
      config.testnet.l2Controller.address,
      l2controllerABI.abi,
      signer
    );
  } else {
    throw new Error("Invalid network");
  }

  let tx = await controller.setGreeting("second try from L2");
  await tx.wait();
  hash = tx.hash;
  await crossChainMessenger.waitForMessageStatus(
    hash,
    messageStatus.IN_CHALLENGE_PERIOD
  );
  await crossChainMessenger.waitForMessageStatus(
    hash,
    messageStatus.READY_FOR_RELAY
  );
  console.log("Ready for relay, finalizing message now");
  await crossChainMessenger.finalizeMessage(hash);
  console.log("Waiting for status to change to RELAYED");
  await crossChainMessenger.waitForMessageStatus(hash, messageStatus.RELAYED);
  await crossChainMessenger.finalizeMessage(hash);
  console.log("Message finalized");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
