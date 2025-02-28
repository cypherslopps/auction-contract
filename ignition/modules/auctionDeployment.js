const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("DeployAuction", m => {
    const owner = m.getAccount(0);
    const initialOwner = m.getParameter("initialOwner", owner);
    const usdcAddress = m.getParameter("usdcAddress", ethers.ZeroAddress);

    // Auction Constructor
    const auction = m.contract("Auction", [initialOwner, usdcAddress]);

    return { auction };
});