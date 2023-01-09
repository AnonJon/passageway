import { ethers } from "hardhat";
import { crossChainMessenger, messageStatus } from "../../src/messanger";
const { exec } = require("node:child_process");

export const deploy = async (contractName: string, args: any[] = []) => {
  const Contract = await ethers.getContractFactory(contractName);
  return Contract.deploy(...args);
};

export const deployBySigner = async (
  contractName: string,
  bytecode: string,
  signer: any,
  args: any[] = []
) => {
  const Contract = new ethers.ContractFactory(contractName, bytecode, signer);
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

export const finalizeMessage = async (hash: string) => {
  console.log(`Tx: ${hash} is in challenge period`);
  await crossChainMessenger.waitForMessageStatus(
    hash,
    messageStatus.IN_CHALLENGE_PERIOD
  );
  console.log(`Tx: ${hash} is waiting for relay`);

  await crossChainMessenger.waitForMessageStatus(
    hash,
    messageStatus.READY_FOR_RELAY
  );
  console.log(`Tx: ${hash} is ready for relay`);

  await crossChainMessenger.finalizeMessage(hash);
  console.log(`Tx: ${hash} is waiting for relayed status...`);

  await crossChainMessenger.waitForMessageStatus(hash, messageStatus.RELAYED);
  console.log(`Tx: ${hash} Message finalized`);
};
