import { ethers } from "hardhat";
const { exec } = require("node:child_process");

export const deploy = async (contractName: string, args: any[] = []) => {
  const Contract = await ethers.getContractFactory(contractName);
  return Contract.deploy(...args);
};

export const verify = async (network: string, ...args: any) => {
  let s = "";
  for (let arg of args) {
    s += arg + " ";
  }
  await new Promise((r) => setTimeout(r, 5000));
  exec(
    `npx hardhat verify --network ${network} ${s}`,
    (err: string, output: string) => {
      if (err) {
        console.error("could not execute command: ", err);
        return;
      }
      console.log(output);
    }
  );
  console.log("Verifying contract on etherscan...");
};
