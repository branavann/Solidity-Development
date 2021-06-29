// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

contract FallbackExample {
    
    mapping(address => uint) public balanceRecieved;
    
    address payable owner;
    
    constructor() public {
        // Need to typecase msg.sender to avoid type errors
        owner = payable(msg.sender);
    }
    
    // View functions don't cost any gas
    function getOwner() public view returns(address) {
        return owner;
    }
    
    // Pure functions don't access any storage variables (e.g. balanceRecieved, owner)
    function convertWeiToEther(uint _amountInWei) public pure returns(uint) {
        return _amountInWei / 1 ether;
    }
    
    function destroySmartContract() public {
        require(msg.sender == owner, "Only the owner can call this function");
        selfdestruct(owner);
    }
    
    function receiveMoney() public payable {
        // Protects against overflow errors
        assert(balanceRecieved[msg.sender] + msg.value >= balanceRecieved[msg.sender]);
        balanceRecieved[msg.sender] += msg.value;
    }
    
    function withdrawMoney(address payable _to, uint _amount) public {
        // Require statements help with input validation; require returns remaining gas
        require(balanceRecieved[msg.sender] >= _amount);
        // Protects against underflow errors; assert consumes all gas
        assert(balanceRecieved[msg.sender] >= balanceRecieved[msg.sender] - _amount);
        balanceRecieved[msg.sender] -= _amount;
        _to.transfer(_amount);
    }
    
    // Fallback function; any call with non-empty calldata
    fallback() external payable {
    }
    
    // Used for Ether transfer; calls with empty data 
    receive() external payable {
    }
}