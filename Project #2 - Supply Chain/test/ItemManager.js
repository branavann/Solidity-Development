// Parses the .json file and provides specific functions (e.g. deploy() which provides the on-chain instance of this smart contract)
const ItemManager = artifacts.require("ItemManager");

contract("ItemManager Test", async accounts => {
  
  it("Adding an item", async () => {

    // Parameters for our example item
    const itemName = "Example";
    const itemPrice = 100;

    // Creating an instance of the ItemManager contract
    const instance = await ItemManager.deployed();
    const result = await instance.createItem(itemName, itemPrice, {from: accounts[0]});
    // console.log(result);

    // Gathering information from the result variable
    const index = result.logs[0].args._itemIndex;
    const itemInformation = await instance.items(index, {from: accounts[0]});

    // Assert statements 
    assert.equal(itemInformation._id, itemName, "The name of the item is wrong");
    assert.equal(itemInformation._price, itemPrice, "The price of the item is wrong");
    assert.equal(result.logs[0].args._itemIndex, 0, "It's not the first item in the list");
  })
  
  it("Updates the _state variable after recieving payment for the item", async () => {
    
    // Parameters for our example item
    const itemName = "Example";
    const itemPrice = 100;

    // Creating an instance of the ItemManager contract
    const instance = await ItemManager.deployed();
    const result = await instance.createItem(itemName, itemPrice, {from: accounts[0]});

    // Payment for the item
    const itemAddress = result.logs[0].args._itemAddress;
    const payment = await web3.eth.sendTransaction({from: accounts[1], to: itemAddress, value: 100});
    
    // Information about our item
    const index = result.logs[0].args._itemIndex;
    const itemInformation = await instance.items(index, {from: accounts[0]});

    // Checking if the value for _state updated from 0 (creation) to 1 (payment)
    assert.equal(itemInformation._state, 1, "The _state counter has not incremented");

  })
});