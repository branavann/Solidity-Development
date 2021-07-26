// Use strict has global scope, converts mistakes into errors

"use strict";

var chai = require("chai");

// Require bigNumber library to operate on numbers outside the safe range of values for Javascript
const BN = web3.utils.BN;
const chaiBN = require("chai-bn")(BN);
chai.use(chaiBN);

// Enables use to assert something about a promise instead of using .then()
var chaiAsPromised = require("chai-as-promised");
chai.use(chaiAsPromised);

const expect = chai.expect;

module.exports = chai;