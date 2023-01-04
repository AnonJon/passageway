import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

require("dotenv").config();

const GOERLI_RPC_URL = process.env.GOERLI_RPC_URL as string;
const OPTIMISM_GOERLI_RPC_URL = process.env.OPTIMISM_GOERLI_RPC_URL as string;
const PRIVATE_KEY = (process.env.PRIVATE_KEY as string) || "0x";
const ETHERSCAN_KEY = process.env.ETHERSCAN_KEY as string;
const OP_ETHERSCAN_KEY = process.env.OP_ETHERSCAN_KEY as string;
interface Config extends HardhatUserConfig {}

const config: Config = {
  solidity: {
    compilers: [
      {
        version: "0.8.17",
      },
      {
        version: "0.8.15",
      },
      {
        version: "0.8.0",
      },
    ],
  },
  defaultNetwork: "hardhat",
  networks: {
    // ganache: {
    //   url: GANACHE_RPC_URL,
    // },
    hardhat: {
      // // comment out forking to run tests on a local chain
    },
    // mainnet: {
    //   url: MAINNET_RPC_URL,
    //   accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
    //   chainId: 1,
    // },
    goerli: {
      url: GOERLI_RPC_URL,
      accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
      chainId: 5,
    },
    "optimism-goerli": {
      url: OPTIMISM_GOERLI_RPC_URL,
      accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
      chainId: 420,
    },
    // binance: {
    //   url: BINANCE_MAINNET_RPC_URL,
    //   accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
    //   chainId: 56,
    // },
  },
  etherscan: {
    apiKey: {
      optimisticGoerli: OP_ETHERSCAN_KEY,
      goerli: ETHERSCAN_KEY,
    },
  },
};

export default config;
