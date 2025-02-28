const { ethers, ignition } = require("hardhat");
const { expect } = require("chai");
const { loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");

const auctionModule = require("../ignition/modules/auctionDeployment");

describe("Auction Testing", () => {
    describe("Validating Input Values", () => {
        async function setupSmartContract() {
            const [owner] = await ethers.getSigners();

            // Deploy USDC Contract
            const usdc = await ethers.deployContract("USDCMockCoin", [owner]);

            // Deployed reusing the ignition module
            const { auction } = await ignition.deploy(auctionModule, {
                parameters: {
                    DeployAuction: {
                        initialOwner: owner.address,
                        usdcAddress: await usdc.getAddress()
                    }
                }
            });

            return {
                usdc,
                auction
            };
        }

        it ("USDC Address should be the same", async () => {
            const { usdc, auction } = await setupSmartContract();
            console.log(await usdc.getAddress(), await auction.usdcToken());

            expect(await usdc.getAddress()).to.be.equal(await auction.usdcToken());
        })
    })
})