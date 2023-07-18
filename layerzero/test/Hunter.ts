import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import { BigNumber } from "ethers";

var hunterAddress;

describe("Hunter", function () {

    describe("Deployment", function () {

        it("deploy Hunter", async function () {
            const Hunter = await ethers.getContractFactory("Hunter");
            const hunter = await Hunter.deploy("0x0000000000000000000000000000000000000000");
            await hunter.deployed();
            hunterAddress = hunter.address;
            expect(await hunter.name()).equal("Hunter");
            expect(await hunter.symbol()).equal("HTR");
        });

        it("owner and token balance should be correct", async function () {
            const accounts = await ethers.getSigners();
            const Hunter = await ethers.getContractFactory("Hunter");
            const hunter = await Hunter.attach(hunterAddress.toString());
            expect((await hunter.owner()).toString()).equal(accounts[0].address);
            expect((await hunter.balanceOf(hunterAddress)).toString()).equal("1000000000000000000000000000");
        })
    
    });

    describe("Withdraw", function () {
        
        it("send eth to contract", async function () {
            const accounts = await ethers.getSigners();
            const Hunter = await ethers.getContractFactory("Hunter");
            const hunter = await Hunter.attach(hunterAddress.toString());
            expect((await ethers.provider.getBalance(hunterAddress)).toString()).equal("0");
            await accounts[1].sendTransaction({
                to : hunterAddress,
                value : ethers.utils.parseEther("2"),
            });
            expect((await ethers.provider.getBalance(hunterAddress)).toString()).equal("2000000000000000000");
        });

        it("withdraw eth from contract", async function () {
            const accounts = await ethers.getSigners();
            const Hunter = await ethers.getContractFactory("Hunter");
            const hunter = await Hunter.attach(hunterAddress.toString());
            await expect(hunter.connect(accounts[1]).withdraw({
                from : accounts[1].address,
            })).to.be.revertedWith("Ownable: caller is not the owner");
            await hunter.connect(accounts[0]).withdraw();
            expect((await ethers.provider.getBalance(hunterAddress)).toString()).equal("0");
            var balance0 = await ethers.provider.getBalance(accounts[0].address);
            var balance1 = await ethers.provider.getBalance(accounts[1].address);
            expect(balance0.sub(balance1)).greaterThan(BigNumber.from("3900000000000000000"));
        });

    });

    describe("Config", function () {

        it("update and check config", async function () {
            const Hunter = await ethers.getContractFactory("Hunter");
            const hunter = await Hunter.attach(hunterAddress.toString());
            await hunter.updateSrcEndpoint(hunterAddress);
            expect((await hunter.getSrcEndpoint()).toString()).equal(hunterAddress.toString());
            await hunter.updateChainConfig(100, hunterAddress);
            expect((await hunter.getChainConfig(100)).toString()).equal(hunterAddress.toString());
        });

    });

});