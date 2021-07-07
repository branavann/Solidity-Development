// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

contract StructExample {
    
    struct Payment {
        uint amount;
        uint timestamp;
    }
    
    struct Balance {
        uint totalBalance;
        uint numPayments;
        // Mapping payments to counter (unsigned integer)
        mapping(uint => Payment) payments;
    }
    
    // Each address is mapped to it's individual Balance struct
    mapping(address => Balance) public balanceReceived;
    
    function getBalance() public view returns(uint) {
        // Required to cast this to the address type in order to check the balance
        return address(this).balance;
    }
    
    // Must be declared as payable
    function sendMoney() public payable{
        balanceReceived[msg.sender].totalBalance += msg.value;
        
        Payment memory payment = Payment(msg.value, block.timestamp);
        // numPayment serves as the index / key value for each individual payment struct that is created
        balanceReceived[msg.sender].payments[balanceReceived[msg.sender].numPayments] = payment;
        
        balanceReceived[msg.sender].numPayments += 1;
    }
    
    function withdrawAllMoney(address payable _to) public {
        // Checks and balances are completed prior to the transfer to protect against reentrancy bugs 
        uint balanceToSend = balanceReceived[msg.sender].totalBalance;
        balanceReceived[msg.sender].totalBalance = 0;
        // Interaction comes last
        _to.transfer(balanceToSend);
    }
    
    function withdrawMoney(address payable _to, uint _amount) public {
        require(balanceReceived[msg.sender].totalBalance >= _amount, "Your withdrawal request is greater than your deposit.");
        balanceReceived[msg.sender].totalBalance -= _amount;
        _to.transfer(_amount);
    }
    
}