// SPDX-License-Identifier: MIT
pragma solidity^0.8.0;

import "openzeppelin-solidity/contracts/access/Ownable.sol";

contract Fundraiser is Ownable {

    struct Donation {
        uint256 value;
        uint256 date;
    }

    string public name;
    string public url;
    string public imageURL;
    string public description;
    address payable public beneficiary;
    address private _owner;

    mapping(address => Donation[]) private _donations;

    // transferOwnership ensures the contract is controlled by the custodian
    constructor(string memory _name, string memory _url, string memory _imageURL, string memory _description, address payable _beneficiary, address _custodian) public {
        name = _name;
        url = _url;
        imageURL = _imageURL;
        description = _description;
        beneficiary = _beneficiary;
        _owner = _custodian;
    }

    function setBeneficiary(address payable _address) public onlyOwner {
        beneficiary = _address;
    }

    function donate() public payable{
        Donation memory donation = Donation({value: msg.value, date: block.timestamp});
        _donations[msg.sender].push(donation);
    }

    function myDonationsCount() public view returns(uint) {
        return _donations[msg.sender].length;
    }

    function myDonations() public view returns(uint256[] memory values, uint256[] memory dates) {
        // Gathers the length of values and dates arrays 
        uint256 count = myDonationsCount();
        // Initalizes the array 
        values = new uint256[](count);
        dates = new uint256[](count);

        // Looping through _donations 
        for (uint256 i = 0; i < count; i++) {
            // Creates a struct to store information from the _donations mapping 
            Donation storage donation = _donations[msg.sender][i];
            values[i] = donation.value;
            dates[i] = donation.date;
        }

        return(values, dates);
    }

 }