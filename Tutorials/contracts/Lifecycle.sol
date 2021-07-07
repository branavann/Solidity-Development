// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.1;

contract SendMoneyExample {
    
    address public owner;
    bool public paused;
    
    // Constructor function is only called once. It doesn't require public or private declaration
    constructor() {
        // Owner is set as the person/address that deployed the contract
        owner = msg.sender;
    }

    // Restricts interactions with a contract 
    function setPaused(bool _paused) public {
        require(msg.sender == owner, "Must be called by the owner of this contract");
        require(!paused, "Contract is already paused");
        paused = _paused;
    }

    function sendMoney() public payable {
        require(!paused, "Contract is paused. Users are unable to interact with it.");
    }
    
    function withdrawAllMoney(address payable _to) public {
        require(msg.sender == owner, "Must be called by the owner of this contract");
        require(!paused, "Contract is paused. Users are unable to interact with it");
        _to.transfer(address(this).balance);
    }
    
    // Destroys the contract and sends the remaining funds to the specified address
    function killSmartContract(address payable _to) public {
        require(msg.sender == owner, "Must be called by the owner of this contract");
        selfdestruct(_to);
    }
    
}