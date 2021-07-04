// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

contract Owned {
    
    address owner;
    
    constructor() public {
        owner = payable(msg.sender);
    }
    
    // Modifers don't require public declaration
    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner of this contract");
        _;
    }
}

contract InheritanceModifierExample is Owned {
    
    mapping(address => uint) public tokenBalance;
    uint tokenPrice = 1 ether;
    
    constructor() public {
        tokenBalance[owner] = 100;
    }
    
    function createNewToken() public onlyOwner {
        tokenBalance[owner]++;
    }
    
    function burnToken() public onlyOwner {
        tokenBalance[owner]--;
    }
    
    function purchaseToken() public payable {
        require((msg.value/tokenPrice) <= tokenBalance[owner], "Not enough tokens");
        tokenBalance[owner] -= msg.value / tokenPrice;
        tokenBalance[msg.sender] += msg.value / tokenPrice;
    }
}