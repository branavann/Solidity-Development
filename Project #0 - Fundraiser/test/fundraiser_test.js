const FundraiserContract = artifacts.require("Fundraiser");
var expect = require('chai').expect;
var assert = require('chai').assert;

contract("Fundraiser Contract", (accounts) => {
    let contractInstance;
    const name = "Beneficiary Name";
    const url = "beneficiaryname.com";
    const imageURL = "https://placeholder.com/600/350";
    const description = "Beneficiary description";
    const beneficiary = accounts[1];
    const owner = accounts[0];
    
    beforeEach(async () => {
        contractInstance = await FundraiserContract.new(
            name,
            url,
            imageURL,
            description,
            beneficiary,
            owner
            )
    });

    context("Initializes the correct values", () => {
        it("Returns the beneficiary's name", async() => {
            const beneficiaryName = await contractInstance.name();
            expect(beneficiaryName).to.equal(name);
        });
        it("Returns the beneficiary's URL", async() => {
            const beneficiaryURL = await contractInstance.url();
            expect(beneficiaryURL).to.equal(url);
        });
        it("Returns the beneficiary's image", async() => {
            const beneficiaryImage = await contractInstance.imageURL();
            expect(beneficiaryImage).to.equal(imageURL);
        });
        it("Returns the beneficiary's description", async() => {
            const beneficiaryDescription = await contractInstance.description();
            expect(beneficiaryDescription).to.equal(description);
        });
        it("Returns the beneficiary's address", async() => {
            const beneficiaryAddress = await contractInstance.beneficiary();
            expect(beneficiaryAddress).to.equal(beneficiary);
            // console.log(beneficiaryAddress);
        });
        it("Returns the owner's address", async() => {
            const ownerAddress = await contractInstance.owner();
            expect(ownerAddress).to.equal(owner);
            // console.log(ownerAddress);
            // console.log(accounts[0]);
        });
    });

    context("setBeneficiary", () => {
        const newBeneficiary = accounts[2];

        it("Function called by the contract owner", async() => {
            await contractInstance.setBeneficiary(newBeneficiary, {from: owner});
            const actualBeneficiary = await contractInstance.beneficiary();
            expect(actualBeneficiary).to.equal(newBeneficiary);
        });

        it("Function called by a non-owner address", async() => {
            try {
                await contractInstance.setBeneficiary(newBeneficiary, {from: accounts[3]});
                assert(false);
            } catch(err) {
                // console.log(err.reason);
                assert(err);   
            }
        });
    });

    context("Making a donation", () => {
        const value = web3.utils.toWei("0.02");
        const donor = accounts[3];

        it("Increases myDonationsCount", async() =>{
            const previousDonationsCount = await contractInstance.myDonationsCount({from: donor});
            await contractInstance.donate({from: donor, value});
            const currentDonationsCount = await contractInstance.myDonationsCount({from: donor});
            const difference = currentDonationsCount - previousDonationsCount;
            expect(1).to.equal(difference);
        });

        it("Includes our donation in myDonations", async() => {
            await contractInstance.donate({from: donor, value});
            const {values, dates} = await contractInstance.myDonations({from: donor});
            assert.equal(value, values[0], "Values should match");
            assert(dates[0], "Date should be returned");
        });

        it("Updates the donation counter", async() => {
            const initalCount = await contractInstance.totalDonationCount();
            await contractInstance.donate({from: donor, value});
            const currentCount = await contractInstance.totalDonationCount();
            const difference = currentCount - initalCount;
            expect(difference).to.equal(1);
        });

        it("Updates the total donation value", async() => {
            const initialValue = await contractInstance.totalDonationValue();
            await contractInstance.donate({from: donor, value});
            const currentValue = await contractInstance.totalDonationValue();
            const difference = currentValue - initialValue;
            assert.equal(difference, value, "Donation value didn't update");
        });

        it("Emits the DonationRecieved event", async() => {
            const transaction = await contractInstance.donate({from: donor, value});
            const expectedEvent = "DonationRecieved";
            const actualEvent = transaction.logs[0].event;
            expect(expectedEvent).to.equal(actualEvent);
            // console.log(transaction);
        });
    });

    describe("Withdrawing funds to the beneficiary's address", () => {
        beforeEach(async () => {
            await contractInstance.donate({from: accounts[2], value: web3.utils.toWei("0.2")});
        });

        it("Error when called from a non-owner account", async() => {
            try {
                await contractInstance.withdraw({from: accounts[3]});
                assert(false, "Withdraw function was not restricted to the owner")
            } catch(err) {
                // console.log(err.reason);
                assert(err);
            }
        });

        it("Permits the owner to called the function", async() => {
            try {
                await contractInstance.withdraw({from: owner});
                assert(true, "No errors were thrown");
            } catch(err) {
                asssert(false, "Owner should be able to call the withdraw function")
            }
        });

        it("Transfers contract balance to the beneficiary", async () => {
            const initialContractBalance = await web3.eth.getBalance(contractInstance.address);
            const initialBeneficiaryBalance = await web3.eth.getBalance(beneficiary);

            await contractInstance.withdraw({from: owner});

            const newContractBalance = await web3.eth.getBalance(contractInstance.address);
            const newBeneficiaryBalance = await web3.eth.getBalance(beneficiary);

            const difference = newBeneficiaryBalance - initialBeneficiaryBalance;

            assert.equal(newContractBalance, 0, "Contract should have a 0 balance");
            assert.equal(difference, initialContractBalance, "Beneficiary should recieve all the funds");
        })

        it("Emits a Withdraw event", async() => {
            const transaction = await contractInstance.withdraw({from: owner});
            const expected = "Withdraw";
            expect(transaction.logs[0].event).to.equal(expected);
        })
    });

    describe("Fallback function", () => {
        const value = web3.utils.toWei("0.2");
        
        it("Updates the donation counter", async() => {
            const initialCount = await contractInstance.totalDonationCount();
            // Fallback function
            await web3.eth.sendTransaction({to: contractInstance.address, from: accounts[5], value});
            const currentCount = await contractInstance.totalDonationCount();
            const difference = currentCount - initialCount;
            expect(difference).to.equal(1);

        });

        it("Updates the total donation value", async() => {
            const initialValue = await contractInstance.totalDonationValue();
            // Fallback function
            await web3.eth.sendTransaction({to: contractInstance.address, from: accounts[5], value});
            const currentValue = await contractInstance.totalDonationValue();
            const difference = currentValue - initialValue;
            assert.equal(difference, value, "Difference should match the donation value");
        });
    
    })
});
