import React, { Component } from "react";
import ItemManager from "./contracts/ItemManager.json";
import ItemPayment from "./contracts/ItemPayment.json";
import getWeb3 from "./getWeb3";

import "./App.css";

class App extends Component {
  state = { cost: 0, itemName: "exampleItem1", loaded:false };

  componentDidMount = async () => {
    try {
      // Get network provider and web3 instance.
      this.web3 = await getWeb3();

      // Use web3 to get the user's accounts.
      this.accounts = await this.web3.eth.getAccounts();

      // Get the contract instance.
      this.networkId = await this.web3.eth.net.getId();
      this.itemManager= new this.web3.eth.Contract(
        ItemManager.abi,
        ItemManager.networks[this.networkId] && ItemManager.networks[this.networkId].address,
      );

      this.itemPayment = new this.web3.eth.Contract(
        ItemPayment.abi,
        ItemPayment.networks[this.networkId] && ItemPayment.networks[this.networkId].address,
      );
      

      // Set web3, accounts, and contract to the state, and then proceed with an
      // example of interacting with the contract's methods.
      this.listenToPaymentEvent();
      this.setState({loaded: true});
    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`,
      );
      console.error(error);
    }
  };

  listenToPaymentEvent = () => {
    let self = this;
    // Listens to the SupplyChainEvent from ItemManager
    this.itemManager.events.SupplyChainStep().on("data", async function(evt) {
      if(evt.returnValues._step ==1) {
        let itemObject = await self.itemManager.methods.items(evt.returnValues._itemIndex).call(); // Returns the struct and associated values for the item
        console.log(itemObject);
        alert("Item: " + itemObject._id + " has successfully been paid for");
      };
      console.log(evt); // Returns the return values from the SupplyChainEvent 
    });
  }

  handleInputChange = (event) => {
    const target = event.target;
    const value = target.type == "checkbox" ? target.checked : target.value;
    const name = target.name;
    this.setState({
      [name]: value
    });
  }

  handleSubmit = async() => {
    const {cost, itemName} = this.state;
    console.log(cost. itemName, this.itemManager);
    let result = await this.itemManager.methods.createItem(itemName, cost).send({from: this.accounts[0]});
    console.log(result);
    alert("Send "+cost+" Wei to "+result.events.SupplyChainStep.returnValues._itemAddress);
  }

  render() {
    if (!this.state.loaded) {
      return <div>Loading Web3, accounts, and contract...</div>;
    }
    return (
      <div className="App">
        <h1>Supply Chain</h1>
        <h2>Items</h2>
        <h2>Add Items</h2>
        Cost in Wei: <input type="text" name="cost" value={this.state.cost} onChange={this.handleInputChange} />
        Item Identifier: <input type="text" name="itemName" value={this.state.itemName} onChange={this.handleInputChange} />
        <button type="button" onClick={this.handleSubmit}>Create new Item</button>
      </div>
    );
  }
}

export default App;
