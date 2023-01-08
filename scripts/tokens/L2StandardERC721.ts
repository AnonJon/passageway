import { deploy } from "../../test/utils/helpers";

async function main() {
  const constract = await deploy("L2StandardERC721");
  await constract.deployed();

  console.log(`constract deployed to ${constract.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
