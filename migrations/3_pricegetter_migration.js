const PriceGetter = artifacts.require("PriceGetter");

module.exports = async function (deployer) {
  await deployer.deploy(PriceGetter);
  let tokenInstance = await PriceGetter.deployed();
};