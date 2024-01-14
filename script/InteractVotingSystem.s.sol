// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {VotingSystem} from "../src/VotingSystem.sol";
import {console} from "forge-std/console.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {DeployVotingSystem} from "./DeployVotingSystem.s.sol";

contract InteractVotingSystem is Script {
    VotingSystem votingSystemContract;
    HelperConfig helperConfig;
    uint256 public startTime;

    function run() public {
        DeployVotingSystem deploy = new DeployVotingSystem();
        startTime = block.timestamp;
        (votingSystemContract, helperConfig) = deploy.run();

        (,uint256 deployerKey) = helperConfig.activeNetworkConfig();

        vm.warp(startTime + 1);
        addCandidate(deployerKey);

        vm.warp(votingSystemContract.candidateSelectionPeriod());
        registerToVote();

        vm.warp(votingSystemContract.registrationPeriod());
        console.log("3. Voting");
        vote();

        vm.warp(votingSystemContract.votingPeriod() + 86000);
        pickWinner(deployerKey);
    }

    function addCandidate(uint256 _deployerKey) public {
        vm.startBroadcast(_deployerKey);
        for(uint256 i; i < 5; ++i) {
            votingSystemContract.addCandidate(
                string(abi.encodePacked("candidate", Strings.toString(i)))
            );
        }
        vm.stopBroadcast();

        console.log("1. Candidates count: ", votingSystemContract.getCandidateCount());
    }

    function registerToVote() public {
        uint votersRegistered;
        for(uint256 i; i < 10; ++i) {
            vm.startBroadcast(makeAddr(string(abi.encodePacked("voter", Strings.toString(i)))));
            votingSystemContract.registerToVote();
            vm.stopBroadcast();
            votersRegistered++;
        }

        console.log("2. Voters Registered: ", votersRegistered);
    }

    function vote() public {
        for(uint256 i; i < 10; ++i) {
            string memory voter = string(abi.encodePacked("voter", Strings.toString(i)));
            vm.startBroadcast(makeAddr(voter));
            uint256 _candidateId = uint256(keccak256(abi.encodePacked(i, block.timestamp, msg.sender))) % 5;
            votingSystemContract.vote(_candidateId);
            vm.stopBroadcast();
            console.log(voter, "->", _candidateId);
        }
    }

    function pickWinner(uint256 _deployerKey) public {
        console.log("4. Pick winner");

        vm.broadcast(_deployerKey);
        votingSystemContract.pickWinner();

        uint256 winnerId = votingSystemContract.winnerId();
        (string memory winnerName, uint256 votesCnt) = votingSystemContract.getCandidateDetails(winnerId);
        console.log(winnerName, "with Votes", votesCnt);
    }
}