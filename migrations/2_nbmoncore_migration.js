const NBMonCore = artifacts.require("implementation/NBMonCore");

module.exports = function (deployer) {
  deployer.deploy(NBMonCore);
};
