// hardhat js test

const { expect } = require("chai");

describe("InterbankSettlement", function () {
  let contract;
  let owner, bank1, bank2, bank3;

  beforeEach(async function () {
    [owner, bank1, bank2, bank3] = await ethers.getSigners();
    const InterbankSettlement = await ethers.getContractFactory("InterbankSettlement");
    contract = await InterbankSettlement.deploy([bank1.address, bank2.address, bank3.address], 2);
    await contract.deployed();
  });

  it("Should initiate a transaction and require approvals", async function () {
    await contract.connect(bank1).initiateTransaction(bank2.address, 1000);
    let txn = await contract.transactions(1);
    expect(txn.status).to.equal(0); // Pending
  });

  it("Should confirm the transaction with sufficient approvals", async function () {
    await contract.connect(bank1).initiateTransaction(bank2.address, 1000);
    await contract.connect(bank1).confirmTransaction(1);
    await contract.connect(bank2).confirmTransaction(1);
    let txn = await contract.transactions(1);
    expect(txn.status).to.equal(1); // Confirmed
  });

  it("Should handle disputes and resolve them", async function () {
    await contract.connect(bank1).initiateTransaction(bank2.address, 1000);
    await contract.connect(bank1).confirmTransaction(1);
    await contract.connect(bank2).confirmTransaction(1);
    await contract.connect(bank1).reconcileTransaction(1, 500); // Mismatch
    let dispute = await contract.disputes(1);
    expect(dispute.resolved).to.equal(false);
  });
});
