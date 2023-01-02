import { ethers } from "hardhat";
import { CCM } from "../src/messanger";

async function main() {
  const ccm = CCM;
  console.log(ccm.bridges[0]);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
