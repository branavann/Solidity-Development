pragma solidity^0.8.1;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Allowance is Ownable {
    
    mapping(address => uint) public allowance;
    
    event allowanceChange(address indexed _forWho, address indexed _byWhom, uint _previousAmount, uint _newAmount);
    
    modifier isAuthorized(uint _amount) {
        require(isOwner() || allowance[msg.sender] >= _amount, "Unable to authorize transaction");
        _;
    }
    
    function isOwner() internal view returns(bool) {
        // owner() is a function within OpenZeppelin's Ownable contract
        return owner() == msg.sender;
    }
    
    function setAllowance(address payable _recipient, uint _amount) public onlyOwner {
        // Emit information regarding the allowance change
        emit allowanceChange(_recipient, msg.sender, allowance[_recipient], _amount);
        // Update the allowance mapping
        allowance[_recipient] = _amount;
    }
    
    function reduceAllowance(address payable _recipient, uint _amount) internal {
        // Checking the transaction
        require(isOwner() || msg.sender == _recipient, "Not authorized to change this recipient's allowance");
        // Emit information regarding the allowance change
        emit allowanceChange(_recipient, msg.sender, allowance[_recipient], allowance[_recipient]-_amount);
        // Update the allowance mapping
        allowance[_recipient] -= _amount;
    }
    
}

contract SharedWallet is Allowance {
    
    event MoneyRecieved(address indexed _from, uint _amount);
    event MoneySent(address indexed _to, uint _amount);
    
    function getBalance() public view returns(uint) {
        return address(this).balance;
    }
    
    // Removes the renounceOwnership() function inherited from Ownable
    function renounceOwnership() public view override onlyOwner {
        revert("Unable to renounce ownership");
    }
    
    function withdrawMoney(address payable _to, uint _amount) public isAuthorized(_amount) {
        
        // Transfer of funds
        _to.transfer(_amount);
        
        // Updating the mapping and emitting an event
        emit MoneySent(_to, _amount);
        reduceAllowance(_to, _amount);
    }
    
    function terminateContract(address payable _to) public onlyOwner {
        selfdestruct(_to);
    } 
    
    receive() external payable {
        emit MoneyRecieved(msg.sender, msg.value);
    }
}