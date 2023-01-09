import { ethers, network } from "hardhat";
import { deploy, verify } from "../../test/utils/helpers";
import config from "../../config/network.config.json";
import L1BridgeInterface from "../../artifacts/contracts/L1Bridge.sol/L1Bridge.json";

const pk = process.env.PRIVATE_KEY as string;

async function main() {
  const signer = new ethers.Wallet(pk, ethers.provider);
  const token = config.testnet.l1Token;
  const tokenAddress = token.address;
  const tokenId = token.id;
  const gas = token.gas;
  const data = token.data;
  let l1Bridge: any;

  l1Bridge = new ethers.Contract(
    config.testnet.l1Bridge.address,
    L1BridgeInterface.abi,
    signer
  );
  await l1Bridge.depositERC721(tokenAddress, tokenId, gas, data);
  console.log("token deposited");
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
