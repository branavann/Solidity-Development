pragma solidity ^0.6.0;

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

contract ItemManager{
    
    enum SupplyChainState{Created, Paid, Delivered}
    
    struct Item {
        ItemPayment _item; // Tracks payment contract associated with the item
        string _id;
        uint _price;
        ItemManager.SupplyChainState _state;
    }
    
    mapping(uint => Item) public items;
    uint itemIndex;
    
    // For _step we need uint values -- 0: Create, 1: Paid, and 2: Delivered
    event SupplyChainStep(uint _itemIndex, uint _step, address _itemAddress);
    
    function createItem(string memory _id, uint _price) public {
        
        // Initalizing constructor function of ItemPayment contract
        ItemPayment _item = new ItemPayment(this, _price, itemIndex);
    
        // Initalizing the struct values for the new item
        items[itemIndex]._item = _item;
        items[itemIndex]._id = _id;
        items[itemIndex]._price = _price;
        items[itemIndex]._state = SupplyChainState.Created;
        
        // Emit an event
        emit SupplyChainStep(itemIndex, uint(items[itemIndex]._state), address(_item));
        
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
        emit SupplyChainStep(_itemIndex, uint(items[_itemIndex]._state), address(items[_itemIndex]._item));
    }
    
    function triggerDelivery(uint _itemIndex) public {
        
        // Ensuring the item hasn't been shipped already
        require(items[_itemIndex]._state == SupplyChainState.Paid, "The item requires payment or it has already been shipped");
        
        // Updating the SupplyChainState of the item
        items[_itemIndex]._state = SupplyChainState.Delivered;
        
        // Emitting an event
        emit SupplyChainStep(_itemIndex, uint(items[_itemIndex]._state), address(items[_itemIndex]._item));
    }
    
}