// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.1;

contract SendMoneyExample {
    
    uint public balanceRecieved;
    uint public lockedUntil;
    
    function recieveMoney() public payable {
        balanceRecieved += msg.value;
        lockedUntil = block.timestamp + 1 minutes;
    }
    
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
    
    function withdrawMoney() public {
        if(block.timestamp > lockedUntil) {
            // Convert to type address payable
            address payable to = payable(msg.sender);
            // This transfers the uint of wei within the contract
            to.transfer(getBalance());
        }
    }
    
    function withdrawMoneyTo(address payable _to) public {
        if(block.timestamp > lockedUntil) {
            _to.transfer(getBalance());
        }
    }
    
}