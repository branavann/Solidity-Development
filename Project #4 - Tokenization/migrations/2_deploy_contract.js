var MyToken = artifacts.require("./MyToken.sol");
var MyTokenSale = artifacts.require("./MyTokenSale.sol");
var MyKycContract = artifacts.require("./KycContract.sol");
require('dotenv').config({path : '../.env'});

module.exports = async function(deployer) {
    let _address = await web3.eth.getAccounts();
    await deployer.deploy(MyToken, process.env.INITIAL_TOKENS);
    await deployer.deploy(MyKycContract);
    await deployer.deploy(MyTokenSale, 1, _address[0], MyToken.address, MyKycContract.address); // address for MyToken is stored within the artifacts 
    let instance = await MyToken.deployed();
    // Transfers the tokens to the MyTokenSale address
    await instance.transfer(MyTokenSale.address, process.env.INITIAL_TOKENS);

}
