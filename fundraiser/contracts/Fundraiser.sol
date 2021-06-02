// SPDX-License-Identifier: MIT
pragma solidity^0.8.0;

import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";

contract Fundraiser is Ownable {

    // Prevents overflow issues, espeically for donation amount 
    using SafeMath for uint256;

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

    uint256 public totalDonationCount = 0;
    uint256 public totalDonationValue = 0;

    mapping(address => Donation[]) private _donations;

    event DonationRecieved(address indexed donor, uint256 value);
    event Withdraw(uint256 amount);

    // transferOwnership ensures the contract is controlled by the custodian
    constructor(string memory _name, string memory _url, string memory _imageURL, string memory _description, address payable _beneficiary, address _custodian) {
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
        // This syntax enables us to avoid integer overflow issues 
        totalDonationCount = totalDonationCount.add(1);
        totalDonationValue = totalDonationValue.add(msg.value);

        emit DonationRecieved(msg.sender, msg.value);
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

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        beneficiary.transfer(balance);
        emit Withdraw(balance);
    }

 }