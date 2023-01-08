import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect, assert } from "chai";
import { ethers, network } from "hardhat";
import { deploy } from "./utils/helpers";
import config from "../config/network.config.json";
import { any } from "hardhat/internal/core/params/argumentTypes";
import L2StandardToken from "../artifacts/contracts/tokens/L2StandardERC721.sol/L2StandardERC721.json";

const pk = process.env.PRIVATE_KEY as string;
const signer = new ethers.Wallet(pk, ethers.provider);

describe("L2 Bridge Tests", function () {
  let owner: any,
    l1Bridge: any,
    l1Messenger: any,
    l2Bridge: any,
    nftL1: any,
    nftL2: any,
    l2StandardERC721: any,
    l2Messenger: any;

  beforeEach(async () => {
    const accounts = await ethers.getSigners();
    owner = accounts[0];
    l2StandardERC721 = await deploy("L2StandardERC721");
    l1Messenger = await deploy("L1CDMMock");
    nftL1 = await deploy("NFT", ["Cool NFT's", "CNFT"]);
    l1Bridge = await deploy("L1Bridge");
    l2Messenger = await deploy("L2CDMMock", [l1Bridge.address]);
    l2Bridge = await deploy("L2Bridge", [
      l1Bridge.address,
      l2Messenger.address,
      l2StandardERC721.address,
    ]);
    await l1Bridge.initialize(
      l2Messenger.address,
      l2Bridge.address,
      l2StandardERC721.address
    );
  });

  describe("deposit", function () {
    it("bridge nft into L2 bridge without mapping", async () => {
      const abi = ethers.utils.defaultAbiCoder;
      const name = "NFT WORLD";
      const symbol = "NFTW";
      const uri = "https://google.com/0";
      const data = abi.encode(
        ["string", "string", "string"],
        [name, symbol, uri]
      );
      await l2Bridge._finalizeDeposit(
        nftL1.address,
        owner.address,
        owner.address,
        0,
        data
      );
      const l2tokenAddress = await l2Bridge.tokenMapping(nftL1.address);
      nftL2 = new ethers.Contract(l2tokenAddress, L2StandardToken.abi, signer);
      assert((await nftL2.tokenURI(0)) == uri);
      assert((await nftL2.ownerOf(0)) == owner.address);
    });
  });
});
