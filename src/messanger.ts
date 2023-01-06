import { CrossChainMessenger, MessageStatus } from "@eth-optimism/sdk";
import { ethers } from "hardhat";
require("dotenv").config();

const pk = process.env.PRIVATE_KEY as string;
const OPTIMISM_GOERLI_RPC_URL = process.env.OPTIMISM_GOERLI_RPC_URL as string;
const GOERLI_RPC_URL = process.env.GOERLI_RPC_URL as string;
const l1Provider = new ethers.providers.JsonRpcProvider(GOERLI_RPC_URL);
const l2Provider = new ethers.providers.JsonRpcProvider(
  OPTIMISM_GOERLI_RPC_URL
);
const l1signer = new ethers.Wallet(pk, l1Provider);
const l2signer = new ethers.Wallet(pk, l2Provider);

export const crossChainMessenger = new CrossChainMessenger({
  l1SignerOrProvider: l1signer,
  l2SignerOrProvider: l2signer,
  l1ChainId: 5,
  l2ChainId: 420,
});

export const messageStatus = MessageStatus;
