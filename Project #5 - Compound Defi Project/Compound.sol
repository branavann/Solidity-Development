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

interface IERC20 {
    
    // Returns the totalSupply of an ERC20 contract
    function totalSupply() external view returns (uint256);
    // Returns the balance of a particular address
    function balanceOf(address who) external view returns (uint256);
    // Transfer ERC20 token
    function transfer(address to, uint value) external returns(bool);
    // Returns the remaining numbers of tokens the spender can spend on behalf of the owner
    // Default value of 0, change the allowance by calling approve()
    // Value changes once transferFrom(), deducts the amount spent by the spender
    function allowance(address owner, address spender) external view returns (uint);
    // Using the allowance function, transfers specific value of ERC20 tokens from owner's address to the spender's address
    function transferFrom(address from, address to, uint value) external returns(bool);
    // Owner of an account can set the allowance for the spender to use on their behalf; returns true if successful
    // For changing allowance change previousValue to 0 then 0 to newValue to prevent spender from gaining access to previousValue + newValue
    function approve(address spender, uint value) external returns(bool);
    
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
    
    function approveERC20Balance(address _contractAddress, uint _amount) public returns(bool) {
        // Instantiate the ERC20 contract
        IERC20 erc20 = IERC20(_contractAddress);
        // Msg.sender approves our contract to spend a specified amount of ERC20 tokens on their behalf
        return erc20.approve(address(this), _amount);
    }
    
    function depositERC20Balance(address _contractAddress, uint _amount) public {
        // Instantiate the ERC20 contract
        IERC20 erc20 = IERC20(_contractAddress);
        // Check if the user has sufficient amount to approve
        require(erc20.balanceOf(msg.sender) > _amount, "Insufficient ERC20 Tokens");
        // Approves our smart contract to use the provided balance
        uint _allowance = getERC20Allowance(_contractAddress);
        // Performing a Check 
        require(_allowance > 0, "No ERC20 tokens have been authorized. Please use the approveERC20Balance() to specify the amount of ERC20 tokens you'd like to authorize.");
        // Transfer ERC20 token from msg.sender to our contract's address
        erc20.transferFrom(msg.sender, address(this), _allowance);
    }
    
    function getERC20Allowance(address erc20SmartContractAddress) public view returns(uint) {
        // Instantiate the ERC20 contract
        IERC20 erc20 = IERC20(erc20SmartContractAddress);
        // Returns the amount of ERC20 tokens msg.sender has approved for our contract to use
        return erc20.allowance(msg.sender, address(this));
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
    function withdrawAll() public {
        // Setting and defining our variables
        address payable _depositAddress = payable(msg.sender);
        uint _withdrawCETH = balance[msg.sender];
        
        // Updating the mappings to prevent a re-entrancy attack
        delete balance[msg.sender];

        // Transfer the funds
        ceth.redeem(_withdrawCETH);
        uint _withdrawETH = (_withdrawCETH * getExchangeRate() / 1e18);
        _depositAddress.transfer(_withdrawETH);
        
        // Emit an event
        emit accountWithdrawal(msg.sender, _withdrawETH, block.timestamp);
    }
    
    function withdrawPartial(uint _amount) public {
        
        // Validating if the user has a sufficient balance; uint only allows positive numbers
        require(balance[msg.sender] - _amount >= 0, "Insufficient balance within your account");
        
        // Casting address to payable type
        address payable _depositAddress = payable(msg.sender);
        
        // Updating the users balance
        balance[msg.sender] = balance[msg.sender] - _amount;
        
        // Retrieving cETH 
        ceth.redeem(_amount);
        // Converting cETH into ether
        uint partialETHAmount = _amount * getExchangeRate() / 1e18;
        // Depositing the funds to the user
        _depositAddress.transfer(partialETHAmount);
        
        // Emitting an event
         emit accountWithdrawal(msg.sender, partialETHAmount, block.timestamp);
    }
    
    function fundContract() public payable{
        totalContractBalance += msg.value;
        emit contractDeposit(msg.sender, msg.value, block.timestamp);
    }
    
    // Compound sends ETH once we redeem cETH
    receive() external payable{
    }
    
}
