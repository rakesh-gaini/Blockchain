// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./MainCCTrading.sol";
import "./CarbonCreditTrading.sol";

contract BridgeCarbonCreditTrading {

    address public owner;

    MainCCTrading public mainChain;
    CarbonCreditTrading public sideChain;

    // Initialize contract
    constructor(address mainChAddr, address sideChAddr) {
        mainChain = MainCCTrading(mainChAddr);
        sideChain = CarbonCreditTrading(sideChAddr);
        owner = msg.sender;
    }

    function stakeCredits(address from, uint stake) public {
        sideChain.stakeCryptocurrency(from, stake);
    }

    function unstakeCryptocurrency(address from, uint stake) public {
        sideChain.stakeCryptocurrency(from, stake);
    }

    function balanceUpdates(address _to) public {
        sideChain.updateBalance(_to);
    }

    function mintCCredits() public {
        require(msg.sender == owner, "Only owner can mint carbon credits");
        sideChain.mintCarbonCredits();
    }

    function buyCarbonCredits(address to, uint amount) public payable {
        sideChain.buyCarbonCredits(to, amount);
        mainChain.buyTransferCurrency(to, owner);
    }

    function sellCarbonCredits(address from, address payable to, uint amount) public payable {
        sideChain.sellCarbonCredits(from, to, amount);
        mainChain.sellTransferCurrency(from, to);
    }

    function withdraw() public {
        require(msg.sender == owner, "Only owner can withdraw ether");
        uint amount = address(this).balance;
        payable(msg.sender).transfer(amount);
    }

    function performance(address user) public view{
        sideChain.calculatePerformance(user);
    }
}