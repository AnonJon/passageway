import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect, assert } from "chai";
import { ethers, network } from "hardhat";
import { deploy } from "./utils/helpers";
import config from "../config/network.config.json";
import { any } from "hardhat/internal/core/params/argumentTypes";

describe("L1 Bridge Tests", function () {
  let owner: any,
    l1Bridge: any,
    l1Messenger: any,
    l2Bridge: any,
    nft: any,
    l2StandardERC721: any,
    template: any,
    l2Messenger: any;

  beforeEach(async () => {
    const accounts = await ethers.getSigners();
    owner = accounts[0];
    l2StandardERC721 = await deploy("L2StandardERC721");
    l1Messenger = await deploy("L1CDMMock");
    l2Messenger = "0x4200000000000000000000000000000000000007";
    nft = await deploy("NFT", ["Cool NFT's", "CNFT"]);
    template = await deploy("L2StandardERC721");
    l1Bridge = await deploy("L1Bridge");
    l2Bridge = await deploy("L2Bridge", [
      l1Bridge.address,
      l2Messenger,
      l2StandardERC721.address,
    ]);
    await l1Bridge.initialize(
      l1Messenger.address,
      l2Bridge.address,
      template.address
    );
  });

  describe("deposit", function () {
    it("deposit nft into L1 bridge", async () => {
      await nft.setApprovalForAll(l1Bridge.address, true);
      await l1Bridge.depositERC721(nft.address, 0, 10000000, "0x00");
      assert((await nft.ownerOf(0)) == l1Bridge.address);
    });
  });
  describe("withdraw", function () {
    it("withdraw nft from L1 bridge", async () => {
      await nft.setApprovalForAll(l1Bridge.address, true);
      await l1Bridge.depositERC721(nft.address, 0, 10000000, "0x00");
      assert((await nft.ownerOf(0)) == l1Bridge.address);
    });
  });
});
