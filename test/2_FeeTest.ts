import BigNumber from "bignumber.js";
import { ERC20, MultiSender, OldMultiSender } from "../typechain-types";
import { ethers } from "hardhat";

const getRandomAddress = () => {
  const wallet = ethers.Wallet.createRandom();
  return wallet.address;
};

const getRandomAddresses = (n: number) => {
  return Array.from({ length: n }, () => getRandomAddress());
}

const getRandomNumberInRange = (min: number, max: number) => {
  return new BigNumber(Math.floor(Math.random() * (max - min + 1) ) + min);
}

const getRandomNumbersInRange = (n: number, min: number, max: number) => {
  return Array.from({ length: n }, () => getRandomNumberInRange(min, max));
}

const getTotalofAmounts = (amounts: BigNumber[]) => {
  return amounts.reduce((acc, amount) => acc.plus(amount), new BigNumber(0));
}


describe("MultiSender", () => {
  let multiSender: MultiSender;
  let oldMultiSender: OldMultiSender;
  let token: ERC20;
  let accounts: Awaited<ReturnType<typeof ethers.getSigners>>;

  before(async () => {
    multiSender = await ethers.deployContract("MultiSender")
    oldMultiSender = await ethers.deployContract("OldMultiSender")
    token = await ethers.deployContract("ERC20Token", ["TestToken", "TEST"])
    accounts = (await ethers.getSigners())
  });

  it("should multisend to 10 addresses", async () => {
    const count = 10
    const addresses = getRandomAddresses(count);
    const amounts = getRandomNumbersInRange(count, 1000, 100000);
    const total = getTotalofAmounts(amounts);
    await token.approve(multiSender.getAddress(), total.toFixed());
    await token.approve(oldMultiSender.getAddress(), total.toFixed());
    const oldTx = await oldMultiSender.MultiSendERC20(token.getAddress(), addresses, amounts.map(a => a.toFixed()));
    const oldTxReceipt = await oldTx.wait();
    const tx = await multiSender.MultiSendERC20(token.getAddress(), total.toFixed(), addresses, amounts.map(a => a.toFixed())); 
    const txReceipt = await tx.wait();
    const newGas = txReceipt?.gasUsed.toString();
    const oldGas = oldTxReceipt?.gasUsed.toString();
    const diff = new BigNumber(oldGas || 0).minus(new BigNumber(newGas || 0));
    console.log('New MultiSendERC20 gas used: ', newGas);
    console.log('Old MultiSendERC20 gas used: ', oldGas);
    console.log("Difference= ", diff.toString());
  })
  it("should multisend to 100 addresses", async () => {
    const count = 100
    const addresses = getRandomAddresses(count);
    const amounts = getRandomNumbersInRange(count, 1000, 100000);
    const total = getTotalofAmounts(amounts);
    await token.approve(multiSender.getAddress(), total.toFixed());
    await token.approve(oldMultiSender.getAddress(), total.toFixed());
    const oldTx = await oldMultiSender.MultiSendERC20(token.getAddress(), addresses, amounts.map(a => a.toFixed()));
    const oldTxReceipt = await oldTx.wait();
    const tx = await multiSender.MultiSendERC20(token.getAddress(), total.toFixed(), addresses, amounts.map(a => a.toFixed())); 
    const txReceipt = await tx.wait();
    const newGas = txReceipt?.gasUsed.toString();
    const oldGas = oldTxReceipt?.gasUsed.toString();
    const diff = new BigNumber(oldGas || 0).minus(new BigNumber(newGas || 0));
    console.log('New MultiSendERC20 gas used: ', newGas);
    console.log('Old MultiSendERC20 gas used: ', oldGas);
    console.log("Difference= ", diff.toString());
  })
  // it("should multisend to 500 addresses", async () => {
  //   const count = 500
  //   const addresses = getRandomAddresses(count);
  //   const amounts = getRandomNumbersInRange(count, 1000, 100000);
  //   const total = getTotalofAmounts(amounts);
  //   await token.approve(multiSender.getAddress(), total.toFixed());
  //   await token.approve(oldMultiSender.getAddress(), total.toFixed());
  //   const tx = await multiSender.MultiSendERC20(token.getAddress(), total.toFixed(), addresses, amounts.map(a => a.toFixed())); 
  //   const txReceipt = await tx.wait();
  //   const oldTx = await oldMultiSender.MultiSendERC20(token.getAddress(), addresses, amounts.map(a => a.toFixed()));
  //   const oldTxReceipt = await oldTx.wait();
  //   const newGas = txReceipt?.gasUsed.toString();
  //   const oldGas = oldTxReceipt?.gasUsed.toString();
  //   const diff = new BigNumber(newGas || 0).minus(new BigNumber(oldGas || 0));
  //   console.log('New MultiSendERC20 gas used: ', newGas);
  //   console.log('Old MultiSendERC20 gas used: ', oldGas);
  //   console.log("Difference= ", diff.toString());
  // })
  // it("should multisend to 100 addresses", async () => {
  //   const count = 100
  //   const addresses = getRandomAddresses(count);
  //   const amounts = getRandomNumbersInRange(count, 1000, 100000);
  //   const total = getTotalofAmounts(amounts);
  //   await token.approve(multiSender.getAddress(), total.toFixed());
  //   const tx = await multiSender.MultiSendERC20(token.getAddress(), total.toFixed(), addresses, amounts.map(a => a.toFixed())); 
  //   const txReceipt = await tx.wait();
  //   console.log('MultiSendERC20 gas used: ', txReceipt?.gasUsed.toString());
  // })
  // it("should multisend to 500 addresses", async () => {
  //   const count = 500
  //   const addresses = getRandomAddresses(count);
  //   const amounts = getRandomNumbersInRange(count, 1000, 100000);
  //   const total = getTotalofAmounts(amounts);
  //   await token.approve(multiSender.getAddress(), total.toFixed());
  //   const tx = await multiSender.MultiSendERC20(token.getAddress(), total.toFixed(), addresses, amounts.map(a => a.toFixed())); 
  //   const txReceipt = await tx.wait();
  //   console.log('MultiSendERC20 gas used: ', txReceipt?.gasUsed.toString());
  // })
});
