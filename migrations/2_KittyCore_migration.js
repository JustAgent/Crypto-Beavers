const BeaverCore = artifacts.require("./BeaverCore");

module.exports = function(deployer) {
  deployer.deploy(BeaverCore);
};
