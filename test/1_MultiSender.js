const MultiSender = artifacts.require("MultiSender")
const TestToken = artifacts.require("ERC20Token")
const { assert } = require("chai")
const BigNumber = require("bignumber.js")

contract("MultiSender", (accounts) => {
    let instance, token

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
        const amount = 1000
        const amounts = [amount, amount, amount, amount, amount, amount, amount, amount, amount, amount]
        await token.approve(instance.address, 1000 * 10)
        await instance.MultiSendERC20(token.address, accounts, amounts)
        for (let i = 1; i < accounts.length; i++) {
            let bal = await token.balanceOf(accounts[i])
            assert.equal(bal.toString(), amount, "invalid balance!")
        }
    })
})
