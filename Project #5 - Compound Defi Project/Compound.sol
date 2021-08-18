// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

interface cETH {
    
    // Deposit tokens on Compound
    function mint() external payable;
    // Withdraw from Compound
    function redeem(uint redeemTokens) external returns (uint);
    // Calculates the exchange rate from the underlying to the CToken
    // The calculated exchange rate is scaled by 1e18
    function exchangeRateStored() external view returns (uint);
    // EIP20.sol defines this function: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md 
    function balanceOf(address owner) external view returns (uint256);
        
}

contract SmartBankAccount is Ownable{

    // Global variables
    uint totalContractBalance = 0;
    bool initialized = false;
    
    // Compound variable
    address public ROPSTEN_COMPOUND_CETH_ADDRESS = 0x859e9d8a4edadfEDb5A2fF311243af80F85A91b8;
    cETH ceth;
    
    // Events
    event accountDeposit(address _from, uint _amount, uint _timestamp);
    event contractDeposit(address _from, uint _amount, uint _timestamp);
    event accountWithdrawal(address _from, uint _amount, uint _timestamp);
    event compoundAddressChange(address _newAddress, uint _timestamp);
    
    // Mappings
    mapping(address => uint) balance; // Stores cETH balances

    
    // Updates the compound address
    function setCompoundAddress(address COMPOUND_CETH_ADDRESS) external onlyOwner{
        ceth = cETH(COMPOUND_CETH_ADDRESS);
        initialized = true;
        emit compoundAddressChange(COMPOUND_CETH_ADDRESS, block.timestamp);
    }
    
    function addBalance() public payable {
        
        require(initialized, "Please set the Compound address");
        
        // Balance before the deposit is made
        uint beforeBalance = ceth.balanceOf(address(this));
        
        // Sending deposit to compound
        ceth.mint{value: msg.value}();
        
        // Updating the user's balance
        uint afterBalance = ceth.balanceOf(address(this));
        uint userBalance = afterBalance - beforeBalance;
        require(userBalance >= 0, "Insufficient balance");
        balance[msg.sender] = userBalance; // Balance is stored in cETH
        
        // Emitting an event
        emit accountDeposit(msg.sender, msg.value, block.timestamp);
    }
    
    function getcETHBalance(address _address) public view returns(uint){
        return balance[_address];
    }
    
    function getExchangeRate() public view returns(uint){
        return ceth.exchangeRateStored();
    }
    
    function getBalance(address _address) public view returns(uint){
        return (balance[_address] * getExchangeRate() / 1e18);
    }
    
    
    function getContractBalance() public view returns(uint){
        return totalContractBalance;
    }
    
    // Doesn't need to be payable beacuse we're not sending money directly to this function
    function withdraw() public {
        // Setting and defining our variables
        address payable _depositAddress = payable(msg.sender);
        uint _withdrawCETH = balance[msg.sender];
        
        // Updating the mappings
        delete balance[msg.sender];

        // Transfer the funds
        ceth.redeem(_withdrawCETH);
        uint _withdrawETH = (_withdrawCETH * ceth.exchangeRateStored() / 1e18);
        _depositAddress.transfer(_withdrawETH);
        
        // Emit an event
        emit accountWithdrawal(msg.sender, _withdrawETH, block.timestamp);
    }
    
    function fundContract() public payable{
        totalContractBalance += msg.value;
        emit contractDeposit(msg.sender, msg.value, block.timestamp);
    }
    
    function getBaseFee() public view returns(uint) {
        return block.basefee;
    }
    
    receive() external payable{
    }
    
}