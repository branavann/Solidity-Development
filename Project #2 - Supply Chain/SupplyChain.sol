pragma solidity ^0.6.0;

contract ItemManager{
    
    enum SupplyChainState{Created, Paid, Delivered}
    
    struct Item {
        string _id;
        uint _price;
        ItemManager.SupplyChainState _state;
    }
    
    mapping(uint => Item) public items;
    uint itemIndex;
    
    // For _step we need uint values -- 0: Create, 1: Paid, and 2: Delivered
    event SupplyChainStep(uint _itemIndex, uint _step);
    
    function createItem(string memory _id, uint _price) public {
        
        // Initalizing the struct values for the new item
        items[itemIndex]._id = _id;
        items[itemIndex]._price = _price;
        items[itemIndex]._state = SupplyChainState.Created;
        
        // Emit an event
        emit SupplyChainStep(itemIndex, uint(items[itemIndex]._state));
        
        // Updating the index value for the items mapping
        itemIndex++;
    }
    
    function triggerPayment(uint _itemIndex) public payable {
        
        // Item must be paid for within a single transaction; only full payments 
        require(items[_itemIndex]._price == msg.value, "Only fully payments accepted. Please try again.");
        // Checking to ensure item hasn't already been paid for
        require(items[_itemIndex]._state == SupplyChainState.Created, "Items has already been paid for");
        
        // Update the SupplyChainState of the item
        items[_itemIndex]._state = SupplyChainState.Paid;
        
        // Emitting an event
        emit SupplyChainStep(_itemIndex, uint(items[_itemIndex]._state));
    }
    
    function triggerDelivery(uint _itemIndex) public {
        
        // Ensuring the item hasn't been shipped already
        require(items[_itemIndex]._state == SupplyChainState.Paid, "The item requires payment or it has already been shipped");
        
        // Updating the SupplyChainState of the item
        items[_itemIndex]._state = SupplyChainState.Delivered;
        
        // Emitting an event
        emit SupplyChainStep(_itemIndex, uint(items[_itemIndex]._state));
    }
    
}