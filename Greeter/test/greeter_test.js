const GreeterContract = artifacts.require("Greeter");
var expect = require('chai').expect;

contract("Greeter", (accounts) => {
    let contractInstance;

    beforeEach(async() => {
        contractInstance = await GreeterContract.deployed();
    });

    it("Returns 'Hello, World!' ", async () => {
        const expected = 'Hello, World!';
        const actual = await contractInstance.greet();
        expect(actual).to.equal(expected);
    });

    it("Returns the address of the owner", async () => {
        const owner = await contractInstance.owner();
        expect(owner);
    });

    it("Address matches the address that originally deployed the contract", async() => {
        const owner = await contractInstance.owner();
        const expected = accounts[0];
        expect(owner).to.equal(expected);
    });

    context("Updating the greeter", () => {
        it("Greeting is set by the owner", async () => {
            expected = "The owner has changed the message";
            const greeter = await contractInstance.setGreeting(expected);
            const actual = await contractInstance.greet();
            expect(actual).to.equal(expected);
        });
        it("Greeting is set by someone other than the owner", async() => {
            try {
                await contractInstance.setGreeting("Not the owner", {from: accounts[1]});
                assert(false);
            } catch(err) {
                assert(err);
            }
        })
    })

});

/*

// Deploys a new instance of our contract; prevents errors from changing state variables 
contract("Greeter: update greeting", (accounts) => {
    describe("setGreeting(string)", () => {
      describe("when message is sent by the owner", () => {
        it("sets greeting to passed in string", async () => {
          const greeter = await GreeterContract.deployed()
          const expected = "The owner changed the message";
  
          await greeter.setGreeting(expected);
          const actual = await greeter.greet();
  
          assert.equal(actual, expected, "greeting updated");
        });
      });
  
    describe("when message is sent by another account", () => {
      it("does not set the greeting", async () => {
        const greeter = await GreeterContract.deployed()
        const expected = await greeter.greet();
  
        try {
          await greeter.setGreeting("Not the owner", { from: accounts[1] });
        } catch(err) {
          const errorMessage = "Ownable: caller is not the owner"
          assert.equal(err.reason, errorMessage, "greeting should not update");
          return;
        }
        assert(false, "greeting should not update");
      });
    });
  });
})

*/