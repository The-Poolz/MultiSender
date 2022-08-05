const MultiSender = artifacts.require("MultiSender")
const TestToken = artifacts.require("ERC20Token")

contract("MultiSender", (accounts) => {
    let instance, Token

    before(async () => {
        instance = await MultiSender.new()
        Token = await TestToken.new('TestToken', 'TEST')
    })
    
    it('test', async () => {

    })
})
