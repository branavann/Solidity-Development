const FundraiserContract = artifacts.require('Fundraiser');
var expect = require('chai').expect;
var assert = require('chai').assert;

contract("Fundraiser Factory: Deployment", (accounts) => {
    it("Contract deployment", async() => {
        const contractInstance = FundraiserContract.deployed();
        assert(contractInstance, "Contract was not deployed");
    });
});

