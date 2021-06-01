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
        })
        it("Returns the beneficiary's URL", async() => {
            const beneficiaryURL = await contractInstance.url();
            expect(beneficiaryURL).to.equal(url);
        })
        it("Returns the beneficiary's image", async() => {
            const beneficiaryImage = await contractInstance.imageURL();
            expect(beneficiaryImage).to.equal(imageURL);
        })
        it("Returns the beneficiary's description", async() => {
            const beneficiaryDescription = await contractInstance.description();
            expect(beneficiaryDescription).to.equal(description);
        })
        it("Returns the beneficiary's address", async() => {
            const beneficiaryAddress = await contractInstance.beneficiary();
            expect(beneficiaryAddress).to.equal(beneficiary);
            console.log(beneficiaryAddress);
        })
        it("Returns the owner's address", async() => {
            const ownerAddress = await contractInstance.owner();
            expect(ownerAddress).to.equal(owner);
            console.log(ownerAddress);
            console.log("-------");
            console.log(accounts[0]);
        })
    })
    context("setBeneficiary", () => {
        const newBeneficary = accounts[2];

        it("Function called by the contract owner", async() => {
            await contractInstance.setBeneficiary(newBeneficary, {from: owner});
            const actualBeneficary = await contractInstance.beneficiary();
            expect(actualBeneficary).to.equal(newBeneficary);
        })

        it("Function called by a non-owner address", async() => {
            try {
                await contractInstance.setBeneficiary(newBeneficary, {from: accounts[3]});
                assert(false);
            } catch(err) {
                console.log(err.reason);
                assert(err);   
            }
        })
    })

    context("Making a donation", () => {
        const value = web3.utils.toWei("0.02");
        const donor = accounts[3];

        it("Increases myDonationsCount", async() =>{
            const previousDonationsCount = await contractInstance.myDonationsCount({from: donor});
            await contractInstance.donate({from: donor, value});
            const currentDonationsCount = await contractInstance.myDonationsCount({from: donor});
            const difference = currentDonationsCount - previousDonationsCount;
            expect(1).to.equal(difference);
        })

        it("Includes our donation in myDonations", async() => {
            await contractInstance.donate({from: donor, value});
            const {values, dates} = await contractInstance.myDonations({from: donor});
            assert.equal(value, values[0], "Values should match");
            assert(dates[0], "Date should be returned");
        })

        it("Updates the donation counter", async() => {
            const initalCount = await contractInstance.totalDonationCount();
            await contractInstance.donate({from: donor, value});
            const currentCount = await contractInstance.totalDonationCount();
            const difference = currentCount - initalCount;
            expect(difference).to.equal(1);
        })

        it("Updates the totals donation value", async() => {
            const initalValue = await contractInstance.totalDonationValue();
            await contractInstance.donate({from: donor, value});
            const currentValue = await contractInstance.totalDonationValue();
            const difference = currentValue - initalValue;
            assert.equal(difference, value, "Donation value didn't update");
        })

        it("Emits the DonationRecieved event", async() => {
            const transaction = await contractInstance.donate({from: donor, value});
            const expectedEvent = "DonationRecieved";
            const actualEvent = transaction.logs[0].event;
            expect(expectedEvent).to.equal(actualEvent);
            console.log(transaction);
        })

    })

})
