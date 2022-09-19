const MultiSender = artifacts.require("MultiSender")
const TestToken = artifacts.require("ERC20Token")
const { assert } = require("chai")
const BigNumber = require("bignumber.js")
const truffleAssert = require("truffle-assertions")
const constants = require("@openzeppelin/test-helpers/src/constants.js")

contract("MultiSender", (accounts) => {
    let instance, token
    const amount = 1000
    const amounts = [amount, amount, amount, amount, amount, amount, amount, amount, amount, amount]

    before(async () => {
        instance = await MultiSender.new()
        token = await TestToken.new("TestToken", "TEST")
    })

    it("multi eth transfer", async () => {
        const eth = web3.utils.toWei("1", "ether")
        const amounts = [eth, eth, eth, eth, eth, eth, eth, eth, eth, eth]
        const defaultBal = await web3.eth.getBalance(accounts[1])
        await instance.MultiSendEth(accounts, amounts, { value: web3.utils.toWei("10", "ether") })
        for (let i = 1; i < accounts.length; i++) {
            let bal = await web3.eth.getBalance(accounts[i])
            assert.equal(bal.toString(), BigNumber.sum(defaultBal, eth).toString(), "invalid balance!")
        }
    })

    it("multi erc20 transfer", async () => {
        await token.approve(instance.address, amount * 10)
        await instance.MultiSendERC20(token.address, accounts, amounts)
        for (let i = 1; i < accounts.length; i++) {
            let bal = await token.balanceOf(accounts[i])
            assert.equal(bal.toString(), amount, "invalid balance!")
        }
    })

    describe("transfer failure", () => {
        it("should revert when array length does not match", async () => {
            const amounts = [amount, amount, amount, amount, amount, amount, amount, amount, amount]
            await truffleAssert.reverts(
                instance.MultiSendEth(accounts, amounts, { value: amount * 10 }),
                "invalid input data"
            )
            await token.approve(instance.address, amount * 10)
            await truffleAssert.reverts(instance.MultiSendERC20(token.address, accounts, amounts), "invalid input data")
        })

        it("should revert when invalid user limit", async () => {
            const userLimit = 5
            const oldUserLimit = await instance.UserLimit()
            await instance.setUserLimit(userLimit)
            await truffleAssert.reverts(
                instance.MultiSendEth(accounts, amounts, { value: amount * 10 }),
                "Invalid user limit"
            )
            await token.approve(instance.address, amount * 10)
            await truffleAssert.reverts(instance.MultiSendERC20(token.address, accounts, amounts), "Invalid user limit")
            await instance.setUserLimit(oldUserLimit)
        })

        it("should revert zero address erc transfer", async () => {
            await truffleAssert.reverts(
                instance.MultiSendERC20(constants.ZERO_ADDRESS, accounts, amounts),
                "Invalid token address"
            )
        })

        it("insufficient eth value sent", async () => {
            await truffleAssert.reverts(
                instance.MultiSendEth(accounts, amounts, { value: amount * 9 }),
                "Insufficient eth value sent!"
            )
        })

        it("should revert zero length array", async () => {
            await truffleAssert.reverts(
                instance.MultiSendEth([], [], { value: amount * 10 }),
                "array can't be zero length"
            )
            await token.approve(instance.address, amount * 10)
            await truffleAssert.reverts(
                instance.MultiSendERC20(token.address, [], []),
                "array can't be zero length"
            )
        })
    })

    describe("MultiManageable", () => {
        it("should set user limit", async () => {
            const oldUserLimit = await instance.UserLimit()
            const newUserLimit = 501
            await instance.setUserLimit(newUserLimit)
            const userLimit = await instance.UserLimit()
            assert.equal(userLimit, newUserLimit, "invalid user limit amount")
            assert.notEqual(userLimit, oldUserLimit)
        })

        it("should set whitelist address", async () => {
            const oldWhiteList = await instance.WhiteListAddress()
            const newWhiteList = accounts[7]
            await instance.setWhiteListAddress(newWhiteList)
            const whiteList = await instance.WhiteListAddress()
            assert.equal(whiteList, newWhiteList, "invalid whitelist address")
            assert.notEqual(whiteList, oldWhiteList)
            await instance.setWhiteListAddress(oldWhiteList)
        })

        it("should set whitelist id", async () => {
            const oldWhiteListId = await instance.WhiteListId()
            const newwhiteListId = 5
            await instance.setWhiteListId(newwhiteListId)
            const whiteListId = await instance.WhiteListId()
            assert.equal(whiteListId, newwhiteListId, "invalid whiteList id")
            assert.notEqual(whiteListId, oldWhiteListId)
        })

        it("should pause/unpause contract", async () => {
            await instance.Pause()
            await truffleAssert.reverts(
                instance.MultiSendEth(accounts, amounts, { value: amount * 10 }),
                "Pausable: paused"
            )
            await token.approve(instance.address, amount * 10)
            await truffleAssert.reverts(instance.MultiSendERC20(token.address, accounts, amounts), "Pausable: paused")
            await instance.Unpause()
            await instance.MultiSendEth(accounts, amounts, { value: amount * 10 })
            await instance.MultiSendERC20(token.address, accounts, amounts)
        })
    })
})
