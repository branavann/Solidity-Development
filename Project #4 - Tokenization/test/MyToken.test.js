const MyToken = artifacts.require("MyToken");

var chai = require("chai");

// Require bigNumber library to operate on numbers outside the safe range of values for Javascript
const BN = web3.utils.BN;
const chaiBN = require("chai-bn")(BN);
chai.use(chaiBN);

// Enables use to assert something about a promise instead of using .then()
var chaiAsPromised = require("chai-as-promised");
const { assert } = require("console");
chai.use(chaiAsPromised);

const expect = chai.expect;

contract("BKN Token Test", async (accounts) => {
    it("Deposits 100 BKN token within the Owner's address", async () => {
        const instance = await MyToken.deployed();
        const balance = await instance.totalSupply();
        assert(balance, 100, "Incorrect number of tokens were deposited");
    });
});