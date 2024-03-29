import { ethers } from "hardhat"
import { ERC20, MultiSenderV2 } from "../typechain-types"
import { expect } from "chai"
import allUsers from "./mockData.json"
const ZERO_ADDRESS: string = '0x0000000000000000000000000000000000000000';

describe("MultiSenderV2", () => {
    let instance: MultiSenderV2
    let token: ERC20

    beforeEach(async () => {
        instance = await ethers.deployContract("MultiSenderV2")
        token = await ethers.deployContract("ERC20Token", ["TestToken", "TEST"])
    })

    it("should transfer ETH to multiple accounts", async function () {
        const [deployer] = await ethers.getSigners();
        const users = allUsers.slice(0,100).map((user) => ({
            user: user.address,
            amount: BigInt(user.amount) / BigInt(10000),
        }));
        const beforeBal = await ethers.provider.getBalance(deployer.address);
        const total = users.reduce((acc, user) => acc + user.amount, 0n);
        const tx = await instance.connect(deployer).MultiSendEth(users, { value: total });
        const receipt = await tx.wait();
        const afterBal = await ethers.provider.getBalance(deployer.address);
        for (let i = 0; i < users.length; i++) {
          let bal = await ethers.provider.getBalance(users[i].user);
          expect(bal).to.equal(users[i].amount);
        }
        const gasUsed = receipt?.gasUsed ? BigInt(receipt.gasUsed) * tx.gasPrice : 0n;
        expect(afterBal).to.equal(beforeBal - total - gasUsed);
    });

    it("should transfer ERC20 tokens to multiple accounts directly", async function () {
        const [deployer] = await ethers.getSigners();
        const beforeBal = await token.balanceOf(deployer.address);
        const users = allUsers.slice(0,100).map((user) => ({
            user: user.address,
            amount: BigInt(user.amount) / BigInt(10000),
        }));
        const total = users.reduce((acc, user) => acc + user.amount, 0n);
        await token.connect(deployer).approve(instance.getAddress(), total);
        await instance.connect(deployer).MultiSendERC20Direct(token.getAddress(), users );
        const afterBal = await token.balanceOf(deployer.address);
        for (let user of users) {
          let bal = await token.balanceOf(user.user);
          expect(bal).to.equal(user.amount);
        }
        expect(afterBal).to.equal(beforeBal - total);
    });

    it("should transfer ERC20 tokens to multiple accounts indirectly", async function () {
        const [deployer] = await ethers.getSigners();
        const beforeBal = await token.balanceOf(deployer.address);
        const users = allUsers.slice(0,100).map((user) => ({
            user: user.address,
            amount: BigInt(user.amount) / BigInt(10000),
        }));
        const total = users.reduce((acc, user) => acc + user.amount, 0n);
        await token.connect(deployer).approve(instance.getAddress(), total);
        await instance.connect(deployer).MultiSendERC20Indirect(token.getAddress(), total, users );
        const afterBal = await token.balanceOf(deployer.address);
        for (let user of users) {
          let bal = await token.balanceOf(user.user);
          expect(bal).to.equal(user.amount);
        }
        expect(afterBal).to.equal(beforeBal - total);
    });


    describe("Revert Tests", () => {

        it("should revert zero address erc transfer", async () => {
            await expect(instance.MultiSendERC20Direct(ZERO_ADDRESS, [])).to.be.revertedWithCustomError(instance, "InvalidTokenAddress")
        })


        it("should revert zero length array", async () => {
            await expect(instance.MultiSendEth([])).to.be.revertedWithCustomError(instance, "ArrayZeroLength")
            await expect(instance.MultiSendERC20Direct(token.getAddress(), [])).to.be.revertedWithCustomError(instance, "ArrayZeroLength")
            await expect(instance.MultiSendERC20Indirect(token.getAddress(), 0, [])).to.be.revertedWithCustomError(instance, "ArrayZeroLength")
        })

        it("should revert ERC20 indirect transfer when total higher than sum", async () => {
            const [deployer, ...accounts] = await ethers.getSigners();    
            const amount = ethers.parseUnits("1", 18);
            await token.connect(deployer).approve(instance.getAddress(), ethers.MaxUint256 );
            const users = accounts.map((acc) => ({
                user: acc.address,
                amount: amount,
            }));
            await expect(instance.MultiSendERC20Indirect(token.getAddress(), amount * BigInt(accounts.length + 1), users)).to.be.revertedWithCustomError(instance, "TotalMismatch").withArgs(true)
        })

        it("should revert ERC20 indirect transfer when total lower than sum", async () => {
            const [deployer, ...accounts] = await ethers.getSigners();    
            const amount = ethers.parseUnits("1", 18);
            const total = amount * BigInt(accounts.length);
            await token.connect(deployer).transfer(instance, total ); // manually sending tokens to contract to increase its balance
            await token.connect(deployer).approve(instance.getAddress(), ethers.MaxUint256 );
            const users = accounts.map((acc) => ({
                user: acc.address,
                amount: amount,
            }));
            await expect(instance.MultiSendERC20Indirect(token.getAddress(), amount * BigInt(accounts.length - 1), users)).to.be.revertedWithCustomError(instance, "TotalMismatch").withArgs(false)
        })
        
    })

    describe("MultiManageable", () => {
        it("should pause/unpause contract", async () => {
            await instance.Pause()
            expect(await instance.paused()).to.be.true
            await expect(instance.MultiSendEth([])).to.be.revertedWith("Pausable: paused")
            await expect(instance.MultiSendERC20Direct(token.getAddress(), [])).to.be.revertedWith("Pausable: paused")
            await expect(instance.MultiSendERC20Indirect(token.getAddress(), 0, [])).to.be.revertedWith("Pausable: paused")
            await instance.Unpause()
            expect(await instance.paused()).to.be.false
        })
    })
})
