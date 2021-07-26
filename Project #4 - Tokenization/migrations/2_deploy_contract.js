var MyToken = artifacts.require("./MyToken.sol");
var MyTokenSale = artifacts.require("./MyTokenSale.sol");

module.exports = async function(deployer) {
    let _address = await web3.eth.getAccounts();
    await deployer.deploy(MyToken, 100);
    await deployer.deploy(MyTokenSale, 1, _address[0], MyToken.address); // address for MyToken is stored within the artifacts 
    let instance = await MyToken.deployed();
    // Transfers the tokens to the MyTokenSale address
    await instance.transfer(MyTokenSale.address, 100);

}
