// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;
// Define the smart contract
contract CarbonCreditTrading {

    address public owner;

    mapping (address => uint) public etherBalance;

    // Define variables for tracking staking
    mapping (address => uint) public stakeBal;
    mapping(address => uint256) public balanceOf;
    mapping (address => uint) public stakeTime;
    mapping (address => uint) public unStakeTime;
    mapping (address => uint) public buyTime;
    mapping (address => uint) public sellTime;
    uint public totalStake;
    uint public minStakeVal;

    // Define variables for tracking performance
    mapping (address => uint) public carbonCredits;
    uint public totalCarbonCredits;
    uint public startTime; 
    uint public endTime;
    uint public blockGasLimit;
    uint public cpuFrequency;

    // Define variables for tracking buy and sell transactions
    mapping (address => uint) public buyTransactions;
    mapping (address => uint) public sellTransactions;

    // events to store in transaction log data
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Stake(address indexed staker, uint256 value);
    event Unstake(address indexed staker, uint256 value);

    // Initialize contract
    constructor(uint256 initialCredits,uint minStake) {
        owner = msg.sender;
        balanceOf[owner] = initialCredits;   
        minStakeVal=minStake;
    }

    //only once
    function mintCarbonCredits() public {
        
        carbonCredits[owner] += balanceOf[owner];
        totalCarbonCredits += carbonCredits[owner];
       
    }

    function updateBalance(address toAddr) public {
        
       //updating a balance of 20 in accounts for them to be able to stake
       balanceOf[toAddr] += 20;
       
    }

    // function for staking cryptocurrency
    function stakeCryptocurrency(address fromAddr, uint stake) public {
        startTime = gasleft();
        blockGasLimit = block.gaslimit;
        cpuFrequency = 2^256 / block.timestamp; 

        require(stake > 0, "Amount must be greater than 0");
        require(stake <= balanceOf[fromAddr], "Insufficient balance");

        // Adding stake into transaction logs
        emit Stake(fromAddr, stake);

        // Update the stake and totalStake variables
        stakeBal[fromAddr] += stake;
        balanceOf[fromAddr] -=stake;
        totalStake += stake;
        endTime=block.timestamp;
        stakeTime[fromAddr] = endTime - startTime;
    }

    // function for unstaking cryptocurrency
    function unstakeCryptocurrency(address fromAddr, uint stake) public {
        startTime = block.timestamp;
        require(stake > 0, "Amount must be greater than 0");
        require(stake <= stakeBal[fromAddr], "No tokens staked");

        // Transfer cryptocurrency back to the user
        emit Unstake(fromAddr, stake);

        // Update the stake and totalStake variables
        stakeBal[fromAddr] -= stake;
        endTime = block.timestamp;
        unStakeTime[fromAddr] = endTime - startTime;
    }


    // function to buy carbon credits on sale
    function buyCarbonCredits(address payable toAddr, uint amount) public payable {
        startTime = block.timestamp;

        require(msg.value > 0, "Ether value must be greater than 0");
        require(amount > 0, "Amount must be greater than 0");
        require(stakeBal[toAddr] > minStakeVal,"Need minimum stake invested");
        require(amount <= carbonCredits[owner], "Insufficient balance");

        // Update the cryptocurrency balance of owner
        etherBalance[owner] += msg.value;

        // Update the carbonCredits variable
        carbonCredits[owner] -= amount;
        carbonCredits[toAddr] += amount;
        
        // Adding transfers in transaction logs
        emit Transfer(toAddr, owner, msg.value);
        emit Transfer(owner, toAddr, amount);
        

        // Update the buyTransactions variable
        buyTransactions[msg.sender]++;
        sellTransactions[owner]++;
        endTime = block.timestamp;
        buyTime[toAddr]=endTime-startTime;
    }

    // function to sell carbon credits
    function sellCarbonCredits(address fromAddr, address toAddr, uint amount) public payable{
        startTime = block.timestamp;
        
        require(msg.value > 0, "Ether value must be greater than 0");
        require(amount > 0, "Amount must be greater than 0");
        require(amount <= carbonCredits[fromAddr], "Insufficient balance");
        require(stakeBal[toAddr] > minStakeVal,"Need minimum stake invested");
       // uint eth = amount / 1 ether;

        // Transfer cryptocurrency to the seller
        etherBalance[fromAddr] += msg.value;

        // Update the carbonCredits variable
        carbonCredits[fromAddr] -= amount;
        carbonCredits[toAddr] += amount;

        // Adding transfer of carbon credits and ethers in transaction logs
        emit Transfer(fromAddr, toAddr, amount);
        emit Transfer(toAddr, fromAddr, msg.value);
        //totalCarbonCredits += amount;

        // Update the buyTransactions variable
        buyTransactions[msg.sender]++;
        sellTransactions[fromAddr]++;
        endTime = block.timestamp;
        sellTime[toAddr]=endTime-startTime;
    }

    // function for calculating performance
    function calculatePerformance(address user) public view returns (uint) {
        // Calculate the user's buy and sell transaction ratios
        //uint buySellRatio = buyTransactions[user] / sellTransactions[user]; //1

        // Calculate the user's carbon credit balance as a percentage of the total carbon credits
       // uint carbonCreditPercentage = (carbonCredits[user] / totalCarbonCredits) * 100; //20

        // Calculate the user's stake as a percentage of the total stake
        //uint stakePercentage = (stakeBal[user] / totalStake) * 100; //37.5

        // Calculate the user's performance score
       // uint performance = (buySellRatio * 50/100) + (carbonCreditPercentage * 30/100) + (stakePercentage * 20/100);
        uint performance = stakeTime[user]+buyTime[user]+sellTime[user];
        return performance;
    }
    
}