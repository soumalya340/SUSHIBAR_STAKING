const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("SUSHI BAR CONTRACT", function () {
  it("Deployment should assign the total total supply", async function () {
    const [owner] = await ethers.getSigners();

    //console.log("Singers object", owner);

    const Sushi = await ethers.getContractFactory("SushiBar");

    const SushiContract = await Sushi.deploy(
      "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4"
    );

    const ownerBalance = await SushiContract.balanceOf(owner.address);
    console.log("Owner Address and Balance ", owner.address, ownerBalance);
    expect(await SushiContract.totalSupply()).to.equal(ownerBalance);
  });

  it("Deployment should assign the total total supply", async function () {
    const [owner] = await ethers.getSigners();

    //console.log("Singers object", owner);

    const Sushi = await ethers.getContractFactory("SushiBar");

    const SushiContract = await Sushi.deploy(
      "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4"
    );

    const ownerBalance = await SushiContract.balanceOf(owner.address);
    console.log("Owner Address and Balance ", owner.address, ownerBalance);
    expect(await SushiContract.totalSupply()).to.equal(ownerBalance);
  });
});
