const MyToken = artifacts.require("MyToken");

var chai = require("chai");

// Require bigNumber library to operate on numbers outside the safe range of values for Javascript
const BN = web3.utils.BN;
const chaiBN = require("chai-bn")(BN);
chai.use(chaiBN);

// Enables use to assert something about a promise instead of using .then()
var chaiAsPromised = require("chai-as-promised");
chai.use(chaiAsPromised);

const expect = chai.expect;

contract("BKN Token Test", async (accounts) => {

    // Global variables 
    const [ initialHolder, recipient, anotherAccount ] = accounts;

    it("Deposits 100 BKN token within the Owner's address", async () => {
        
        let instance = await MyToken.new(100);
        let _totalSupply = await instance.totalSupply();

        await expect(instance.balanceOf(initialHolder)).to.eventually.be.a.bignumber.equal(_totalSupply);

    });

    it("Transfers the correct number of BKN tokens", async () => {

        let instance = await MyToken.new(100);
        let _totalSupply = await instance.totalSupply();

        // Specifying the amount to transfer
        const transferAmount = 10;
 
        // Checking if the transaction was successful
        await expect(instance.balanceOf(initialHolder)).to.eventually.be.a.bignumber.equal(_totalSupply);
        await expect(instance.transfer(recipient, transferAmount)).to.eventually.be.fulfilled;

        // Checking account balances after the transaction
        await expect(instance.balanceOf(initialHolder)).to.eventually.be.a.bignumber.equal(_totalSupply.sub(new BN(transferAmount)));
        await expect(instance.balanceOf(recipient)).to.eventually.be.a.bignumber.equal(new BN(transferAmount));
    });

    it("Prevents transferring more tokens than the amount available in an account", async () => {

        let instance = await MyToken.new(100);
        let _totalSupply = await instance.totalSupply();

        // Checking the initial balance of the initialHolder account
        const initialHolderBalance = await instance.balanceOf(initialHolder);
        const transferAmount = initialHolderBalance + 10;

        // Checking if the transaction failed
        await expect(instance.transfer(recipient, transferAmount)).to.eventually.be.rejected;

        // Checking if the balance of the initialHolder remained the same
        await expect(instance.balanceOf(initialHolder)).to.eventually.be.a.bignumber.equal(_totalSupply);


    });
    
});