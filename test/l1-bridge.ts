import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect, assert } from "chai";
import { ethers, network } from "hardhat";
import { deploy } from "./utils/helpers";
import config from "../config/network.config.json";
import { any } from "hardhat/internal/core/params/argumentTypes";

describe("L1 Bridge Tests", function () {
  let owner: any, l1Bridge: any;

  beforeEach(async () => {
    const accounts = await ethers.getSigners();
    owner = accounts[0];
    l1Bridge = await deploy("L1Bridge");
  });

  describe("deploy", function () {
    it("creates contract", async () => {});
  });
});
