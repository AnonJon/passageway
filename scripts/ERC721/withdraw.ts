import { ethers, network } from "hardhat";
import config from "../../config/network.config.json";
import { finalizeMessage } from "../../test/utils/helpers";
import L2BridgeInterface from "../../artifacts/contracts/L2Bridge.sol/L2Bridge.json";

const pk = process.env.PRIVATE_KEY as string;

async function main() {
  const token = config.testnet.l2Token;
  const signer = new ethers.Wallet(pk, ethers.provider);
  const tokenAddress = token.address;
  const tokenId = token.id;
  const gas = token.gas;
  const data = token.data;
  let l2Bridge: any;

  l2Bridge = new ethers.Contract(
    config.testnet.l2Bridge.address,
    L2BridgeInterface.abi,
    signer
  );
  const tx = await l2Bridge.withdraw(tokenAddress, tokenId, gas, data);
  console.log("token withdrawn");
  await finalizeMessage(tx.hash);
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
