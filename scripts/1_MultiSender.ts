
import { ethers } from "hardhat";

const deployContract = async () => {
  await ethers.deployContract("MultiSenderV2");
}

deployContract()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });