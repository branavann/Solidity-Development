// SPDX-License-Identifier: GPL-3.0

// Resizing arrays using .length works with Solidity 0.5.11 and below

pragma solidity^0.5.11;

contract Arrays {
    uint[] public myArray;
    
    function addElement(uint _num) public {
        myArray.length++;
        myArray[myArray.length-1] = _num;
    }
    
    function removeElement() public {
        myArray.length--;
    }
}

// Within Solidity 0.6.0 no longer able to resize arrays using the length feature
// Use .push() and .pop()

contract newArray {
    
    uint[] public myArray;
    
    function addElement(uint _num) public {
        myArray.push(_num);
    }
    
    function removeElement() public {
        myArray.pop();
    }
}