import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect, assert } from "chai";
import { ethers, network } from "hardhat";
import { deploy } from "./utils/helpers";
import config from "../config/network.config.json";
import { any } from "hardhat/internal/core/params/argumentTypes";

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
    nftL2 = await deploy("NFT", ["Cool NFT's", "CNFT"]);
    l1Bridge = await deploy("L1Bridge");
    l2Messenger = await deploy("L2CDMMock", [l1Bridge.address]);
    l2Bridge = await deploy("L2Bridge", [
      l1Bridge.address,
      l2Messenger.address,
      l2StandardERC721.address,
    ]);
    await l1Bridge.initialize(l2Messenger.address, l2Bridge.address);
  });

  describe("deposit", function () {
    it("bridge nft into L2 bridge", async () => {
      await nftL2.setApprovalForAll(l2Bridge.address, true);
      await l2Bridge._finalizeDeposit(
        nftL2.address,
        nftL2.address,
        owner.address,
        owner.address,
        0,
        "0x000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000e000000000000000000000000000000000000000000000000000000000000000094e465420574f524c44000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044e46545700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f7777772e676f6f676c652e636f6d2f0000000000000000000000000000000000"
      );
      assert((await nftL2.ownerOf(0)) == owner.address);
    });
  });
});
