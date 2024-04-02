import { ethers } from "hardhat"
import { ERC20, MultiSenderV2 } from "../typechain-types"
import { expect } from "chai"
import allUsers from "./mockData.json"
const ZERO_ADDRESS: string = '0x0000000000000000000000000000000000000000';

describe("MultiSenderV2", () => {
    let instance: MultiSenderV2
    let token: ERC20

    describe("MultiSendETH", () => {
        beforeEach(async () => {
            instance = await ethers.deployContract("MultiSenderV2")
        })
    
        it("should transfer ETH to multiple accounts", async () => {
            const [deployer] = await ethers.getSigners();
            const users = allUsers.slice(0,100).map((user) => ({
                user: user.address,
                amount: BigInt(user.amount) / BigInt(10000),
            }));
            const beforeBal = await ethers.provider.getBalance(deployer.address);
            const total = users.reduce((acc, user) => acc + user.amount, 0n);
            const tx = await instance.connect(deployer).MultiSendETH(users, { value: total });
            const receipt = await tx.wait();
            const afterBal = await ethers.provider.getBalance(deployer.address);
            for (const user of users) {
              const bal = await ethers.provider.getBalance(user.user);
              expect(bal).to.equal(user.amount);
            }
            const gasUsed = receipt?.gasUsed ? BigInt(receipt.gasUsed) * tx.gasPrice : 0n;
            expect(afterBal).to.equal(beforeBal - total - gasUsed);
        });

        it("should multisend ETH of same value", async () => {
            const [deployer] = await ethers.getSigners();
            const users = allUsers.slice(100,200).map((user) => (user.address));
            const amount = 10000n;
            const beforeBal = await ethers.provider.getBalance(deployer.address);
            const total = amount * BigInt(users.length);
            const tx = await instance.connect(deployer).MultiSendETHSameValue(users, amount, { value: total });
            const receipt = await tx.wait();
            const afterBal = await ethers.provider.getBalance(deployer.address);
            for(let user of users) {
                let bal = await ethers.provider.getBalance(user);
                expect(bal).to.equal(amount);
            }
            const gasUsed = receipt?.gasUsed ? BigInt(receipt.gasUsed) * tx.gasPrice : 0n;
            expect(afterBal).to.equal(beforeBal - total - gasUsed);
        })
    
        it("should multisend ETH grouped", async () => {
            const [deployer] = await ethers.getSigners();
            const userGroups: string[][] = [];
            userGroups.push(
                allUsers.slice(200, 250).map((user) => (user.address)),
                allUsers.slice(250, 300).map((user) => (user.address)),
                allUsers.slice(300, 350).map((user) => (user.address)),
                allUsers.slice(350, 400).map((user) => (user.address)),
                allUsers.slice(400, 450).map((user) => (user.address)),
            )
            const amounts = [10000n, 20000n, 30000n, 40000n, 50000n];
            const beforeBal = await ethers.provider.getBalance(deployer.address);
            const total  = userGroups.reduce((acc, user, i) => acc + amounts[i] * BigInt(user.length), 0n);
            const tx = await instance.connect(deployer).MultiSendETHGrouped(userGroups, amounts, { value: total });
            const receipt = await tx.wait();
            const afterBal = await ethers.provider.getBalance(deployer.address);
            for(const users of userGroups) {
                for(let user of users) {
                    let bal = await ethers.provider.getBalance(user);
                    expect(bal).to.equal(amounts[userGroups.indexOf(users)]);
                }
            }
            const gasUsed = receipt?.gasUsed ? BigInt(receipt.gasUsed) * tx.gasPrice : 0n;
            expect(afterBal).to.equal(beforeBal - total - gasUsed);
        })
    })
    
    describe("MultiSendERC20", () => {
        beforeEach(async () => {
            instance = await ethers.deployContract("MultiSenderV2")
            token = await ethers.deployContract("ERC20Token", ["TestToken", "TEST"])
        })

        it("should transfer ERC20 tokens to multiple accounts directly", async () => {
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
            for (const user of users) {
              const bal = await token.balanceOf(user.user);
              expect(bal).to.equal(user.amount);
            }
            expect(afterBal).to.equal(beforeBal - total);
        });
    
        it("should transfer ERC20 tokens to multiple accounts indirectly", async () => {
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
            for (const user of users) {
              const bal = await token.balanceOf(user.user);
              expect(bal).to.equal(user.amount);
            }
            expect(afterBal).to.equal(beforeBal - total);
        });
    
        it("should multi send ERC20 of same value Directly", async () => {
            const [deployer] = await ethers.getSigners();
            const beforeBal = await token.balanceOf(deployer.address);
            const users = allUsers.slice(100,200).map((user) => (user.address));
            const amount = ethers.parseUnits("100", 18);
            const total = amount * BigInt(users.length);
            await token.connect(deployer).approve(instance.getAddress(), total);
            await instance.connect(deployer).MultiSendERC20DirectSameValue(token.getAddress(), users, amount );
            const afterBal = await token.balanceOf(deployer.address);
            for (let user of users) {
              let bal = await token.balanceOf(user);
              expect(bal).to.equal(amount);
            }
            expect(afterBal).to.equal(beforeBal - total);
        });
    
        it("should multi send ERC20 of same value Indirectly", async () => {
            const [deployer] = await ethers.getSigners();
            const beforeBal = await token.balanceOf(deployer.address);
            const users = allUsers.slice(100,200).map((user) => (user.address));
            const amount = ethers.parseUnits("100", 18);
            const total = amount * BigInt(users.length);
            await token.connect(deployer).approve(instance.getAddress(), total);
            await instance.connect(deployer).MultiSendERC20IndirectSameValue(token.getAddress(), users, amount );
            const afterBal = await token.balanceOf(deployer.address);
            for (let user of users) {
              let bal = await token.balanceOf(user);
              expect(bal).to.equal(amount);
            }
            expect(afterBal).to.equal(beforeBal - total);
        });

        it("should multi send ERC20 grouped Directly", async () => {
            const [deployer] = await ethers.getSigners();
            const userGroups: string[][] = [];
            userGroups.push(
                allUsers.slice(200, 250).map((user) => (user.address)),
                allUsers.slice(250, 300).map((user) => (user.address)),
                allUsers.slice(300, 350).map((user) => (user.address)),
                allUsers.slice(350, 400).map((user) => (user.address)),
                allUsers.slice(400, 450).map((user) => (user.address)),
            )
            const amounts = [ethers.parseUnits("100", 18), ethers.parseUnits("200", 18), ethers.parseUnits("300", 18), ethers.parseUnits("400", 18), ethers.parseUnits("500", 18)];
            const beforeBal = await token.balanceOf(deployer.address);
            const total  = userGroups.reduce((acc, user, i) => acc + amounts[i] * BigInt(user.length), 0n);
            await token.connect(deployer).approve(instance.getAddress(), total);
            await instance.connect(deployer).MultiSendERC20DirectGrouped(token.getAddress(), userGroups, amounts );
            const afterBal = await token.balanceOf(deployer.address);
            for(const users of userGroups) {
                for(let user of users) {
                    let bal = await token.balanceOf(user);
                    expect(bal).to.equal(amounts[userGroups.indexOf(users)]);
                }
            }
            expect(afterBal).to.equal(beforeBal - total);
        })

        it("should multi send ERC20 grouped Indirectly", async () => {
            const [deployer] = await ethers.getSigners();
            const userGroups: string[][] = [];
            userGroups.push(
                allUsers.slice(200, 250).map((user) => (user.address)),
                allUsers.slice(250, 300).map((user) => (user.address)),
                allUsers.slice(300, 350).map((user) => (user.address)),
                allUsers.slice(350, 400).map((user) => (user.address)),
                allUsers.slice(400, 450).map((user) => (user.address)),
            )
            const amounts = [ethers.parseUnits("100", 18), ethers.parseUnits("200", 18), ethers.parseUnits("300", 18), ethers.parseUnits("400", 18), ethers.parseUnits("500", 18)];
            const beforeBal = await token.balanceOf(deployer.address);
            const total  = userGroups.reduce((acc, user, i) => acc + amounts[i] * BigInt(user.length), 0n);
            await token.connect(deployer).approve(instance.getAddress(), total);
            await instance.connect(deployer).MultiSendERC20IndirectGrouped(token.getAddress(), total, userGroups, amounts );
            const afterBal = await token.balanceOf(deployer.address);
            for(const users of userGroups) {
                for(let user of users) {
                    let bal = await token.balanceOf(user);
                    expect(bal).to.equal(amounts[userGroups.indexOf(users)]);
                }
            }
            expect(afterBal).to.equal(beforeBal - total);
        })
    })



    describe("Revert Tests", () => {
        beforeEach(async () => {
            instance = await ethers.deployContract("MultiSenderV2")
            token = await ethers.deployContract("ERC20Token", ["TestToken", "TEST"])
        })

        it("should revert zero address ERC20 transfer", async () => {
            const failString = "NoZeroAddress"
            await expect(instance.MultiSendERC20Direct(ZERO_ADDRESS, [])).to.be.revertedWithCustomError(instance, failString)
            await expect(instance.MultiSendERC20Indirect(ZERO_ADDRESS, 1000, [])).to.be.revertedWithCustomError(instance, failString)
            await expect(instance.MultiSendERC20DirectSameValue(ZERO_ADDRESS, [], 100)).to.be.revertedWithCustomError(instance, failString)
            await expect(instance.MultiSendERC20IndirectSameValue(ZERO_ADDRESS, [], 100)).to.be.revertedWithCustomError(instance, failString)
            await expect(instance.MultiSendERC20DirectGrouped(ZERO_ADDRESS, [], [])).to.be.revertedWithCustomError(instance, failString)
            await expect(instance.MultiSendERC20IndirectGrouped(ZERO_ADDRESS, 1000, [], [])).to.be.revertedWithCustomError(instance, failString)
        })


        it("should revert zero length array", async () => {
            const failString = "ArrayZeroLength"
            await expect(instance.MultiSendETH([])).to.be.revertedWithCustomError(instance, failString)
            await expect(instance.MultiSendETHSameValue([], 100)).to.be.revertedWithCustomError(instance, failString)
            await expect(instance.MultiSendERC20Direct(token.getAddress(), [])).to.be.revertedWithCustomError(instance, failString)
            await expect(instance.MultiSendERC20Indirect(token.getAddress(), 0, [])).to.be.revertedWithCustomError(instance, failString)
            await expect(instance.MultiSendERC20DirectSameValue(token.getAddress(), [], 100)).to.be.revertedWithCustomError(instance, failString)
            await expect(instance.MultiSendERC20IndirectSameValue(token.getAddress(), [], 100)).to.be.revertedWithCustomError(instance, failString)
            await expect(instance.MultiSendETHGrouped([], [])).to.be.revertedWithCustomError(instance, failString)
            await expect(instance.MultiSendERC20DirectGrouped(token.getAddress(), [], [])).to.be.revertedWithCustomError(instance, failString)
            await expect(instance.MultiSendERC20IndirectGrouped(token.getAddress(), 0, [], [])).to.be.revertedWithCustomError(instance, failString)
        })

        it("should revert ERC20 indirect transfer when total higher than sum", async () => {
            const [deployer] = await ethers.getSigners();    
            const amount = ethers.parseUnits("1", 18);
            await token.connect(deployer).approve(instance.getAddress(), ethers.MaxUint256 );
            const users = allUsers.slice(0,100).map((user) => ({
                user: user.address,
                amount: amount,
            }));
            const total = amount * BigInt(users.length);
            await expect(instance.MultiSendERC20Indirect(token.getAddress(), total + 1n, users)).to.be.revertedWithCustomError(instance, "TotalMismatch").withArgs(total + 1n, total)
        })

        it("should revert ERC20 indirect transfer when total lower than sum", async () => {
            const [deployer] = await ethers.getSigners();
            const users = allUsers.slice(0,100).map((user) => ({
                user: user.address,
                amount: ethers.parseUnits("1", 18),
            }));
            const amount = ethers.parseUnits("1", 18);
            const total = amount * BigInt(users.length);
            await token.connect(deployer).transfer(instance, total); // manually sending tokens to contract to increase its balance
            await token.connect(deployer).approve(instance.getAddress(), ethers.MaxUint256 );
            await expect(instance.MultiSendERC20Indirect(token.getAddress(), total - 1n, users)).to.be.revertedWithCustomError(instance, "TotalMismatch").withArgs(total - 1n, total)
        })

        it("should revert ERC20 Indirect Grouped transfer when Total Mismatch", async () => {
            const [deployer] = await ethers.getSigners();    
            await token.connect(deployer).approve(instance.getAddress(), ethers.MaxUint256 );
            const userGroups: string[][] = []
            userGroups.push(
                allUsers.slice(0, 10).map((acc) => acc.address),
                allUsers.slice(10, 20).map((acc) => acc.address),
                allUsers.slice(20, 30).map((acc) => acc.address),
                allUsers.slice(30, 40).map((acc) => acc.address),
                allUsers.slice(40, 50).map((acc) => acc.address),
            )
            const amounts = [ethers.parseUnits("1", 18), ethers.parseUnits("2", 18), ethers.parseUnits("3", 18), ethers.parseUnits("4", 18), ethers.parseUnits("5", 18)]
            const total = userGroups.reduce((acc, user, i) => acc + amounts[i] * BigInt(user.length), 0n);
            await expect(instance.MultiSendERC20IndirectGrouped(token.getAddress(), total + 1n, userGroups, amounts)).to.be.revertedWithCustomError(instance, "TotalMismatch").withArgs(total + 1n, total)
            await token.connect(deployer).transfer(instance, 1n); // manually sending tokens to contract to increase its balance
            await expect(instance.MultiSendERC20IndirectGrouped(token.getAddress(), total - 1n, userGroups, amounts)).to.be.revertedWithCustomError(instance, "TotalMismatch").withArgs(total - 1n, total)
        })

        it("should revert ETH transfer when total higher than sum", async () => {
            const amount = 10000n;
            const users = allUsers.slice(0,100).map((user) => ({
                user: user.address,
                amount: amount,
            }));
            const total = amount * BigInt(users.length);
            await expect(instance.MultiSendETH(users, { value: total + 1n })).to.be.revertedWithCustomError(instance, "TotalMismatch").withArgs(total + 1n, total)
            await expect(instance.MultiSendETH(users, { value: total - 1n })).to.be.revertedWithCustomError(instance, "ETHTransferFail")
        })

        it("should revert ETH transfer of same value when Total Mismatch", async () => {
            const users = allUsers.slice(100,200).map((user) => (user.address));
            const amount = 10000n;
            const total = amount * BigInt(users.length);
            await expect(instance.MultiSendETHSameValue(users, amount, { value: total + 1n })).to.be.revertedWithCustomError(instance, "TotalMismatch").withArgs(total + 1n, total)
            await expect(instance.MultiSendETHSameValue(users, amount, { value: total - 1n })).to.be.revertedWithCustomError(instance, "TotalMismatch").withArgs(total - 1n, total)
        })

        it("should revert ETH Grouped transfer when Total Mismatch", async () => {
            const userGroups: string[][] = []
            userGroups.push(
                allUsers.slice(200, 250).map((acc) => acc.address),
                allUsers.slice(250, 300).map((acc) => acc.address),
                allUsers.slice(300, 350).map((acc) => acc.address),
                allUsers.slice(350, 400).map((acc) => acc.address),
                allUsers.slice(400, 450).map((acc) => acc.address),
            )
            const amounts = [10000n, 20000n, 30000n, 40000n, 50000n]
            const total = userGroups.reduce((acc, user, i) => acc + amounts[i] * BigInt(user.length), 0n);
            await expect(instance.MultiSendETHGrouped(userGroups, amounts, { value: total + 1n })).to.be.revertedWithCustomError(instance, "TotalMismatch").withArgs(total + 1n, total)
            await expect(instance.MultiSendETHGrouped(userGroups, amounts, { value: total - 1n })).to.be.revertedWithCustomError(instance, "ETHTransferFail")
        })
    })

    describe("MultiManageable", () => {
        it("should pause/unpause contract", async () => {
            await instance.Pause()
            expect(await instance.paused()).to.be.true
            const failString = "Pausable: paused"
            await expect(instance.MultiSendETH([])).to.be.revertedWith(failString)
            await expect(instance.MultiSendERC20Direct(token.getAddress(), [])).to.be.revertedWith(failString)
            await expect(instance.MultiSendERC20Indirect(token.getAddress(), 0, [])).to.be.revertedWith(failString)
            await expect(instance.MultiSendETHSameValue([], 100)).to.be.revertedWith(failString)
            await expect(instance.MultiSendERC20DirectSameValue(token.getAddress(), [], 100)).to.be.revertedWith(failString)
            await expect(instance.MultiSendERC20IndirectSameValue(token.getAddress(), [], 100)).to.be.revertedWith(failString)
            await expect(instance.MultiSendETHGrouped([], [])).to.be.revertedWith(failString)
            await expect(instance.MultiSendERC20DirectGrouped(token.getAddress(), [], [])).to.be.revertedWith(failString)
            await expect(instance.MultiSendERC20IndirectGrouped(token.getAddress(), 0, [], [])).to.be.revertedWith(failString)
            await instance.Unpause()
            expect(await instance.paused()).to.be.false
        })
    })
})
