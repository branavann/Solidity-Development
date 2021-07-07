// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

contract ExceptionExample {
    
    mapping(address => uint64) public balanceRecieved;
    
    function receiveMoney() public payable {
        // Protects against overflow errors
        assert(balanceRecieved[msg.sender] + uint64(msg.value) >= balanceRecieved[msg.sender]);
        balanceRecieved[msg.sender] += uint64(msg.value);
    }
    
    function withdrawMoney(address payable _to, uint64 _amount) public {
        // Require statements help with input validation; require returns remaining gas
        require(balanceRecieved[msg.sender] >= _amount);
        // Protects against underflow errors; assert consumes all gas
        assert(balanceRecieved[msg.sender] >= balanceRecieved[msg.sender] - _amount);
        balanceRecieved[msg.sender] -= _amount;
        _to.transfer(_amount);
    }
}