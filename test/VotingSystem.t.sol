//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";
import {VotingSystem} from "../src/VotingSystem.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract VotingSystemTest is Test {
    VotingSystem public votingContract;
    address public owner = makeAddr("owner");
    address public voter1 = makeAddr("voter1");
    address public voter2 = makeAddr("voter2");
    uint256 public startTime;

    // constants
    uint256 public candidateSelectionPeriod = 36000; // 1 hour
    uint256 public registrationPeriod = 36000; // 1 hour
    uint256 public votingPeriod = 86400; // 1 day


    function setUp() public {
        vm.startPrank(owner);
        votingContract = new VotingSystem();
        startTime = block.timestamp;
        vm.stopPrank();
    }

    modifier addCandidates() {
        vm.startPrank(owner);
        vm.warp(startTime + 1);
        for(uint256 i; i < 5; ) {
            votingContract.addCandidate(
                string(abi.encodePacked("candidate", Strings.toString(i)))
            );
            unchecked {
                i = i+1;
            }
        }

        vm.stopPrank();
        _;
    }

    modifier registerVoters() {
        vm.warp(candidateSelectionPeriod);

        for(uint256 i; i < 5; ) {
            vm.startBroadcast(makeAddr(string(abi.encodePacked("voter", Strings.toString(i)))));
            votingContract.registerToVote();
            vm.stopBroadcast();
            unchecked {
                i = i+1;
            }
        }

        _;
    }

    function test_startTime() public {
        assertEq(votingContract.startTime(), startTime);
    }

    function test_addCandidates() public addCandidates {
        (string memory _name, uint256 _voteCount) = votingContract.getCandidateDetails(0);
        assertEq(_name, "candidate0");
        assertEq(_voteCount, 0);
    }

    function testFail_registerToVote() public {
        vm.prank(voter1);
        votingContract.registerToVote();
    }

    function test_registerToVote() public addCandidates  {
        vm.warp(candidateSelectionPeriod);

        vm.startBroadcast(voter1);
        votingContract.registerToVote();
        vm.stopBroadcast();

        assertEq(votingContract.hasVoterRegistered(voter1), true);
    }

    function testFail_registerToVoteTwice() public addCandidates  {
        vm.warp(candidateSelectionPeriod);

        vm.startBroadcast(voter1);
        votingContract.registerToVote();
        votingContract.registerToVote();
        vm.stopBroadcast();

        assertEq(votingContract.hasVoterRegistered(voter1), true);
    }

    function testFail_voteByNonRegisteredVoter() public addCandidates {
        vm.warp(candidateSelectionPeriod + registrationPeriod);

        vm.startPrank(voter1);
        votingContract.vote(1);
    }

    function test_vote() public addCandidates {
        register(voter1);

        vm.warp(registrationPeriod);

        vm.startPrank(voter1);
        votingContract.vote(1);

        assertEq(votingContract.hasVoterVoted(voter1), true);
    }

    function testFail_voteTwice() public addCandidates {
        register(voter1);
        vote(voter1,1);
        vote(voter1,1);
    }

    function testFail_voteTwice2() public addCandidates {
        register(voter1);
        vote(voter1,1);
        vote(voter1,2);
    }

    function testFail_voteInvalidCandidateId() public addCandidates {
        register(voter1);
        vote(voter1, 5);
    }

    function test_candidateVotesCount() public addCandidates registerVoters {
        vote(makeAddr("voter0"), 1);
        vote(makeAddr("voter1"), 1);
        vote(makeAddr("voter2"), 0);
        vote(makeAddr("voter3"), 2);
        vote(makeAddr("voter4"), 2);

        (, uint256 _voteCount) = votingContract.getCandidateDetails(0);
        assertEq(_voteCount, 1);
        (, _voteCount) = votingContract.getCandidateDetails(1);
        assertEq(_voteCount, 2);
        (, _voteCount) = votingContract.getCandidateDetails(2);
        assertEq(_voteCount, 2);
        (, _voteCount) = votingContract.getCandidateDetails(3);
        assertEq(_voteCount, 0);
        (, _voteCount) = votingContract.getCandidateDetails(4);
        assertEq(_voteCount, 0);
    }

    function test_pickWinner() public addCandidates registerVoters {
        vote(makeAddr("voter0"), 1);
        vote(makeAddr("voter1"), 1);
        vote(makeAddr("voter2"), 0);
        vote(makeAddr("voter3"), 2);
        vote(makeAddr("voter4"), 2);

        vm.warp(startTime + candidateSelectionPeriod + registrationPeriod + votingPeriod + 1);
        vm.prank(owner);
        votingContract.pickWinner();

        assertEq(votingContract.getWinner(), "candidate1");
    }

    /* Helper Functions */
    function testFail_zeroVotes() public {
        vm.warp(startTime + candidateSelectionPeriod + registrationPeriod + votingPeriod + 1);
        vm.prank(owner);
        votingContract.pickWinner();
    }

    function vote(address _voter, uint256 _candidateId) internal {
        vm.warp(registrationPeriod);

        vm.prank(_voter);
        votingContract.vote(_candidateId);
    }

    function register(address _voter) internal {
        vm.warp(candidateSelectionPeriod);

        vm.startBroadcast(_voter);
        votingContract.registerToVote();
        vm.stopBroadcast();
    }
}

