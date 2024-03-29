import { ethers } from "hardhat"
import { ERC20, MultiSenderV2 } from "../typechain-types"
import { expect } from "chai"
const ZERO_ADDRESS: string = '0x0000000000000000000000000000000000000000';

describe("MultiSenderV2", () => {
    let instance: MultiSenderV2
    let token: ERC20
    const amount = 1000

    beforeEach(async () => {
        instance = await ethers.deployContract("MultiSenderV2")
        token = await ethers.deployContract("ERC20Token", ["TestToken", "TEST"])
    })

    it("should transfer ETH to multiple accounts", async function () {
        const [deployer, ...accounts] = await ethers.getSigners();
        const addresses = accounts.map(acc => acc.address).splice(0, 10);
        const eth = ethers.parseEther("1");
        const users = Array(10).fill(eth).map((amount, index) => ({
            user: accounts[index].address,
            amount: amount,
        }))
        const defaultBal = await ethers.provider.getBalance(accounts[0].address);
        await instance.MultiSendEth(users,  { value: ethers.parseEther("10") });
        for (let i = 0; i < addresses.length; i++) {
          let bal = await ethers.provider.getBalance(accounts[i].address);
          expect(bal).to.equal(defaultBal + eth);
        }
    });

    it("should transfer ERC20 tokens to multiple accounts directly", async function () {
        const [deployer, ...accounts] = await ethers.getSigners();    
        const amount = ethers.parseUnits("1", 18); 
        await token.connect(deployer).approve(instance.getAddress(), amount * BigInt(accounts.length) );
        const users = accounts.map((acc, index) => ({
            user: acc.address,
            amount: amount,
        }));
        const total = users.reduce((acc, user) => acc + user.amount, 0n);
        await instance.connect(deployer).MultiSendERC20Direct(token.getAddress(), users );
    
        for (let account of accounts) {
          let bal = await token.balanceOf(account.address);
          expect(bal).to.equal(amount);
        }
    });

    it("should transfer ERC20 tokens to multiple accounts indirectly", async function () {
        const [deployer, ...accounts] = await ethers.getSigners();    
        const amount = ethers.parseUnits("1", 18); 
        await token.connect(deployer).approve(instance.getAddress(), amount * BigInt(accounts.length) );
        const users = accounts.map((acc) => ({
            user: acc.address,
            amount: amount,
        }));
        const total = users.reduce((acc, user) => acc + user.amount, 0n);
        await instance.connect(deployer).MultiSendERC20Indirect(token.getAddress(), total, users );
    
        for (let account of accounts) {
          let bal = await token.balanceOf(account.address);
          expect(bal).to.equal(amount);
        }
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
