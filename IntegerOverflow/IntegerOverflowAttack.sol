// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract IntegerOverflow {

    uint8 public remainingBalance;

    function deposit(uint8 depositAmount) public payable{
        remainingBalance += depositAmount;
    }

    function withdraw(uint8 withdrawAmount) public payable{
        require(withdrawAmount <= remainingBalance, "Insufficient balance");
        remainingBalance -= withdrawAmount;
    }
}