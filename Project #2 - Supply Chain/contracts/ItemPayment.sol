// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "./ItemManager.sol";

// This contract is responsible for payments
contract ItemPayment {
    
    uint public priceInWei;
    uint public pricePaid;
    uint public index;
    
    ItemManager parentContract;
    
    constructor(ItemManager _parentContract, uint _priceInWei, uint _index) public {
        // Initalizing the values for ItemPayment from the values passed in from createItem()
        priceInWei = _priceInWei;
        index = _index;
        parentContract = _parentContract;
    }
    
    receive() external payable {
        // Checking conditions before accepting the payment
        require(pricePaid == 0, "The item has already been paid for");
        require(priceInWei == msg.value, "Only full payments allowed");
        // Updating the pricePaid value
        pricePaid += msg.value;
        // Sending money to the ItemManager contract; call function provides enough gas to update the Item struct and triggerPayment()
        (bool success, ) = address(parentContract).call.value(msg.value)(abi.encodeWithSignature("triggerPayment(uint256)", index));
        // .Call is a low-level interaction, therefore, we must listen for whether the transaction was successful
        require(success, "The transaction has failed");
    }
    
    fallback() external {
    }
}