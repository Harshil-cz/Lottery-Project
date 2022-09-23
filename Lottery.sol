// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract Lottery is VRFConsumerBaseV2 {
    VRFCoordinatorV2Interface COORDINATOR;

    // Your subscription ID
    uint64 s_subscriptionId;

    // Goerli coordinator. For other networks
    address vrfCoordinator = 0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D;

    bytes32 keyHash = 0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15;

    uint32 callbackGasLimit = 100000;

    uint16 requestConfirmations = 3;

    // retrieve 2 random values in one request.
    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    uint32 numWords =  1;

    uint256[] public s_randomWords;
    uint256 public s_requestId;
    address lotteryInitiator;

    address[] participants;
    mapping(address=>bool) public appliedForParticipation;
    mapping(address=>bool) public whitelistedForParticipation;

    constructor(uint64 subscriptionId) VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        lotteryInitiator = msg.sender;
        s_subscriptionId = subscriptionId;
    }

    modifier onlyOwner() {
        require(msg.sender == lotteryInitiator);
        _;
    }

    function applyForParticipation() external{
        require(appliedForParticipation[msg.sender]==false,"You have already applied.");
        appliedForParticipation[msg.sender]=true;
    }  

    function whitelistForParticipation(address participant) external onlyOwner{
        require(appliedForParticipation[participant]==true,"You have not aplied.");
        require(whitelistedForParticipation[participant]==false,"Participant is already whilisted");
        whitelistedForParticipation[participant]=true;
        participants.push(participant);
    }

    function requestRandomWords() external onlyOwner {
        s_requestId = COORDINATOR.requestRandomWords(
        keyHash,
        s_subscriptionId,
        requestConfirmations,
        callbackGasLimit,
        numWords
        );
    }

    function fulfillRandomWords(
        uint256, /* requestId */
        uint256[] memory randomWords
    ) internal override {
        s_randomWords = randomWords;
    }

    function declareWinner() external view onlyOwner returns(address){
        uint index=s_randomWords[0]%participants.length;
        return participants[index];
    }  
}
