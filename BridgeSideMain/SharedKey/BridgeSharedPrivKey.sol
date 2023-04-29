// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./MainSharedPrivKey.sol";
import "./SideSharedPrivKey.sol";

contract BridgeSharedPrivKey {

    address public owner;

    MainSharedPrivKey public mainChain;
    SideSharedPrivKey public sideChain;

    bytes32 public encryptedPrivateKey;
    uint public partsRequired;
    uint public partsSubmitted;
    mapping(address => bool) public validators;

    // Initialize contract
    constructor(address mainChAddr, address sideChAddr, bytes32 _encryptedPrivateKey, uint _partsRequired, address[] memory _validators) {
        mainChain = MainSharedPrivKey(mainChAddr);
        sideChain = SideSharedPrivKey(sideChAddr);
        owner = msg.sender;
        encryptedPrivateKey = _encryptedPrivateKey;
        partsRequired = _partsRequired;
        for(uint i=0; i<_validators.length; i++) {
            validators[_validators[i]] = true;
        }
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

    function buyCarbonCredits(address to, uint amount, bytes32 lockId, uint[] memory _parts, bytes32[] memory _hashes) public payable {
        sideChain.buyCarbonCredits(to, amount);
        sideChain.lockAsset(lockId, amount);
        mainChain.buyTransferCurrency(to, owner);
        mainChain.unlockAsset(lockId, _parts, _hashes);
    }

    function sellCarbonCredits(address from, address payable to, uint amount, bytes32 lockId,uint[] memory _parts, bytes32[] memory _hashes) public payable {
        sideChain.sellCarbonCredits(from, to, amount);
        sideChain.lockAsset(lockId, amount);
        mainChain.sellTransferCurrency(from, to);
        mainChain.unlockAsset(lockId, _parts, _hashes);
    }

    function performance(address user) public view{
        sideChain.calculatePerformance(user);
    }
}