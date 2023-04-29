// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;



contract MainCCTrading {
    
    address public owner;
    address public mainAddr;

    mapping (address => uint) public etherBalance;

    uint public startTime; 
    uint public endTime;
    uint public minStakeVal;

    event Transfer(address indexed from, address indexed to, uint256 value);
    
    constructor() {
        owner = msg.sender;
        mainAddr=address(this);
    }

    // Define function for putting carbon credits on sale
    function buyTransferCurrency(address from, address to) public payable {
        startTime = block.timestamp;
        
        require(msg.value > 0, "Ether value must be greater than 0");

        // Transfer cryptocurrency to the smart contract
        etherBalance[to] += msg.value;

        emit Transfer(from, to, msg.value);
    
        endTime = block.timestamp;
    }

    // Define function for selling carbon credits
    function sellTransferCurrency(address from, address payable to) public payable{
        startTime = block.timestamp;
        
        require(msg.value > 0, "Ether value must be greater than 0");

        // Transfer cryptocurrency to the smart contract
        etherBalance[to] += msg.value;

        emit Transfer(from, to, msg.value);
    
        endTime = block.timestamp;
    }

    
}
