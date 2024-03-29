const MultiSender = artifacts.require("MultiSender")

module.exports = function (deployer) {
  deployer.deploy(MultiSender)
}
