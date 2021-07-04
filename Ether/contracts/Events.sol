// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

contract EventExample {
    
    event TokenTransfer(address _from, address _to, uint _amount);
    
    mapping(address => uint) public tokenBalance;
    
    constructor() public {
        tokenBalance[msg.sender] = 100;
    }
    // Javascript VM returns a bool within the decoded output section
    // Deploying to the blockchain only returns values within the log section if you use events and emit
    function sendToken(address _to, uint _amount) public returns(bool) {
        require(_amount <= tokenBalance[msg.sender], "You don't have enough tokens");
        assert(tokenBalance[msg.sender] - _amount <= tokenBalance[msg.sender]);
        assert(tokenBalance[_to] + _amount >= tokenBalance[_to]);
        tokenBalance[msg.sender] -= _amount;
        tokenBalance[_to] += _amount;
        
        emit TokenTransfer(msg.sender, _to, _amount);
        return true;
    }
}