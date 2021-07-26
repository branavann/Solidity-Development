const MyToken = artifacts.require("MyToken");
require("dotenv").config({path : "../.env"});

const chai = require('./setupchai.js');
const BN = web3.utils.BN;
const expect = chai.expect;


contract("BKN Token Test", async (accounts) => {

    // Global variables 
    const [ initialHolder, recipient, anotherAccount ] = accounts;

    beforeEach(async() => {
        // Creating a class variable
        this.MyToken = await MyToken.new(process.env.INITIAL_TOKENS);
    })

    it("Deposits 100 BKN token within the Owner's address", async () => {
        
        let instance = this.MyToken;
        let _totalSupply = await instance.totalSupply();
        return await expect(instance.balanceOf(initialHolder)).to.eventually.be.a.bignumber.equal(_totalSupply);

    });

    it("Transfers the correct number of BKN tokens", async () => {

        let instance = this.MyToken;
        let _totalSupply = await instance.totalSupply();

        // Specifying the amount to transfer
        const transferAmount = 10;
 
        // Checking if the transaction was successful
        await expect(instance.balanceOf(initialHolder)).to.eventually.be.a.bignumber.equal(_totalSupply);
        await expect(instance.transfer(recipient, transferAmount)).to.eventually.be.fulfilled;

        // Checking account balances after the transaction
        await expect(instance.balanceOf(initialHolder)).to.eventually.be.a.bignumber.equal(_totalSupply.sub(new BN(transferAmount)));
        return await expect(instance.balanceOf(recipient)).to.eventually.be.a.bignumber.equal(new BN(transferAmount));
    });

    it("Prevents transferring more tokens than the amount available in an account", async () => {

        let instance = this.MyToken;
        let _totalSupply = await instance.totalSupply();

        // Checking the initial balance of the initialHolder account
        const initialHolderBalance = await instance.balanceOf(initialHolder);
        const transferAmount = initialHolderBalance + 10;

        // Checking if the transaction failed
        await expect(instance.transfer(recipient, transferAmount)).to.eventually.be.rejected;

        // Checking if the balance of the initialHolder remained the same
        return await expect(instance.balanceOf(initialHolder)).to.eventually.be.a.bignumber.equal(_totalSupply);


    });
    
});