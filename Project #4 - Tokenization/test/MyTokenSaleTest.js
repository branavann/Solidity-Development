const MyToken = artifacts.require("MyToken");
const MyTokenSale = artifacts.require("MyTokenSale");
require("dotenv").config({path : "../.env"});

const chai = require('./setupchai.js');
const BN = web3.utils.BN;
const expect = chai.expect;


contract("BKN TokenSale Test", async (accounts) => {

    const [ initialHolder, recipient, anotherAccount ] = accounts;

    it("No tokens should remain within initialHolder account", async() => {

        let instance = await MyToken.deployed();
        return expect(instance.balanceOf(initialHolder)).to.eventually.be.a.bignumber.equal(new BN(0));
    })

    it("TokenSale smart contract possesses all of the tokens", async() => {

        let instance = await MyToken.deployed();
        return expect(instance.balanceOf(MyTokenSale.address)).to.eventually.be.a.bignumber.equal(new BN(process.env.INITIAL_TOKENS));
    });

    it("Successfully purchase tokens", async() => {

        let tokenInstance = await MyToken.deployed();
        let saleInstance = await MyTokenSale.deployed();

        // Initial token balance of receipient
        let initialRecipientBalance = await tokenInstance.balanceOf(recipient);
        
        // Low level interaction to the recieve() function which triggers buyTokens()
        await expect(saleInstance.sendTransaction({from: recipient, value: 10})).to.be.fulfilled;
        return expect(tokenInstance.balanceOf(recipient)).to.eventually.be.a.bignumber.equal(initialRecipientBalance.add(new BN(10)));
    
    })

});