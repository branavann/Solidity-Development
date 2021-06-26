// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.1;

contract MappingExample {
    
    mapping(address => uint) public amountWithdrawn;
    mapping(address => uint) public amountDeposit;
    
    function getBalance() public view returns(uint) {
        // Required to cast this to the address type in order to check the balance
        return address(this).balance;
    }
    
    // Must be declared as payable
    function sendMoney() public payable{
        amountDeposit[msg.sender] += msg.value;
    }
    
    function withdrawAllMoney(address payable _to) public {
        // Checks and effects occur first to protect against reentrancy bugs
        amountWithdrawn[_to] += address(this).balance;
        // Interactions come last
        _to.transfer(address(this).balance);
        
    }
    
    function withdrawMyDeposit(address payable _to) public {
        uint withdrawal = amountDeposit[msg.sender];
        amountWithdrawn[msg.sender] += withdrawal;
        _to.transfer(withdrawal);
    }
    
    function withdrawMoney(address payable _to, uint _amount) public {
        require(amountDeposit[msg.sender] >= _amount, "Your withdrawal request is greater than your deposit.");
        amountDeposit[msg.sender] -= _amount;
        amountWithdrawn[msg.sender] += _amount;
        _to.transfer(_amount);
    }
    
}