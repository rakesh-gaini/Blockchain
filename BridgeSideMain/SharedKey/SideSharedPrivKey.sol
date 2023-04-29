// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract SideSharedPrivKey {

    address public owner;

    // Define variables for tracking staking
    mapping (address => uint) public stakeBal;
    mapping(address => uint256) public balanceOf;
    mapping (address => uint) public stakeTime;
    mapping (address => uint) public buyTime;
    mapping (address => uint) public sellTime;

    uint public startTime; 
    uint public endTime;
    uint public blockGasLimit;
    uint public cpuFrequency;
    uint public totalStake;
    uint public minStakeVal;

    // Define variables for tracking performance
    mapping (address => uint) public carbonCredits;
    uint public totalCarbonCredits;
    
    struct Asset {
        address owner;
        uint amount;
        bool locked;
    }

    address public addr;

    // Define variables for tracking buy and sell transactions
    mapping (address => uint) public buyTransactions;
    mapping (address => uint) public sellTransactions;

    
    mapping(bytes32 => Asset) public assets;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Stake(address indexed staker, uint256 value);
    event Unstake(address indexed staker, uint256 value);
    event AssetLocked(bytes32 lockId, address owner, uint amount);

    // Initialize contract
    constructor(uint256 initialCredits, uint minStake) {
        owner = msg.sender;
        balanceOf[owner] = initialCredits;   
        minStakeVal = minStake;
        addr = address(this);
        
    }

    // Define function for putting carbon credits on sale
    function buyCarbonCredits(address to, uint amount) public {
        startTime = block.timestamp;
        
        require(amount > 0, "Amount must be greater than 0");
        require(stakeBal[to] > minStakeVal,"Need minimum stake invested");
        require(amount <= carbonCredits[owner], "Insufficient balance");

        // Update the carbonCredits and totalCarbonCredits variables
        carbonCredits[owner] -= amount;
        carbonCredits[to] += amount;
        
        //emit Transfer(to, owner, msg.value);
        emit Transfer(owner, to, amount);
        
        // Update the buyTransactions variable
        buyTransactions[to]++;
        sellTransactions[owner]++;
        endTime = block.timestamp;
        buyTime[to] = endTime - startTime;

    }

    // Define function for selling carbon credits
    function sellCarbonCredits(address from, address to, uint amount) public payable{
        startTime = block.timestamp;
        
        require(amount > 0, "Amount must be greater than 0");
        require(amount <= carbonCredits[from], "Insufficient balance");
        require(stakeBal[to] > minStakeVal,"Need minimum stake invested");

        // Update the carbonCredits and totalCarbonCredits variables
        carbonCredits[from] -= amount;
        carbonCredits[to] += amount;

        emit Transfer(from, to, amount);
    
        // Update the buyTransactions variable
        buyTransactions[msg.sender]++;
        sellTransactions[from]++;
        endTime = block.timestamp;
        sellTime[to] = endTime - startTime;
    }

    // function for staking cryptocurrency
    function stakeCryptocurrency(address from, uint stake) public {
        startTime = gasleft();
        blockGasLimit = block.gaslimit;
        cpuFrequency = 2^256 / block.timestamp; 
        //startTime = block.timestamp;
        
        require(stake > 0, "Amount must be greater than 0");
        require(stake <= balanceOf[from], "Insufficient balance");

        // Transfer cryptocurrency to the smart contract
        emit Stake(from, stake);

        // Update the stake and totalStake variables
        stakeBal[from] += stake;
        balanceOf[from] -=stake;
        totalStake += stake;
        endTime = block.timestamp;
        stakeTime[from] = endTime - startTime;
    }

    // function for unstaking cryptocurrency
    function unstakeCryptocurrency(address from, uint stake) public {
        startTime = block.timestamp;
        require(stake > 0, "Amount must be greater than 0");
        require(stake <= stakeBal[from], "No tokens staked");

        // Transfer cryptocurrency back to the user
        emit Unstake(from, stake);


        // Update the stake and totalStake variables
        stakeBal[from] -= stake;
        endTime = block.timestamp;
    }

    //only once
    function mintCarbonCredits() public {
        carbonCredits[owner] += balanceOf[owner];
        totalCarbonCredits += balanceOf[owner]; 
    }

    //only once
    function updateBalance(address to) public {  
        //updating a balance of 20 in all accounts for them to be able to stake
        balanceOf[to] += 20;
    }
    
    // Define function for calculating performance
    function calculatePerformance(address user) public view returns (uint) {
        uint performance = stakeTime[user]+buyTime[user]+sellTime[user];
        return performance;
    }

    function lockAsset(bytes32 _lockId, uint _amount) public {
        require(!assets[_lockId].locked, "Asset already locked");

        assets[_lockId] = Asset({
            owner: msg.sender,
            amount: _amount,
            locked: true
        });

        emit AssetLocked(_lockId, msg.sender, _amount);
    }
}