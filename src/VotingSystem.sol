//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title VotingSystem
 * @notice A smart contract for managing a simple voting system.
 */
contract VotingSystem is Ownable(msg.sender) {
    // Struct representing a candidate
    struct Candidate {
        string name;
        uint256 voteCount;
    }

    // Struct representing a voter
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint256 votedCandidateId;
        uint256 registrationTime;
    }

    // Storage for winner information
    string private winner;
    uint256 public winnerId;

    /// @notice Start time for the voting system
    uint256 public startTime;

    // Mapping of voters
    mapping(address => Voter) public voters;

    // Array of candidates
    Candidate[] public candidates;

    uint256 public candidateSelectionPeriod = 36000; // 1 hour
    uint256 public registrationPeriod = 36000; // 1 hour
    uint256 public votingPeriod = 86400; // 1 day

    // Events
    event VoterRegistered(address indexed voterAddress);
    event CandidateAdded(uint256 indexed candidateId, string name);
    event VoteCasted(address indexed voterAddress, uint256 indexed candidateId);
    event WinnerAnnounced(string indexed candidateName, uint256 votes);

    // Errors
    error Duplicate_Registration();
    error Not_Register();
    error Invalid_CandidateId();
    error Voting_Started();
    error Voters_Registration_Started();
    error Voting_Inprogress();
    error Already_Voted();
    error Only_EOA();
    error Zero_Votes();

    /**
     * @notice Modifier to allow only externally owned accounts (EOA)
     */
    modifier onlyEOA() {
        if(msg.sender != tx.origin){
            revert Only_EOA();
        }
        _;
    }

    /**
     * @notice Modifier to ensure that voter registration is not started
     */
    modifier votersRegistrationNotStarted() {
        if (block.timestamp > startTime + candidateSelectionPeriod && candidates.length > 0) {
            startTime += block.timestamp;
        } else if (block.timestamp > startTime + candidateSelectionPeriod) {
            revert Voters_Registration_Started();
        }

        _;
    }

    /**
     * @notice Modifier to ensure that voting is not started
     */
    modifier votingNotStarted() {
        if (block.timestamp > startTime + candidateSelectionPeriod + registrationPeriod) {
            revert Voting_Started();
        }

        _;
    }

    /**
     * @notice Contract constructor, initializes the start time.
     */
    constructor() {
        startTime = block.timestamp;
    }

    /**
     * @notice Adds a new candidate to the list.
     * @param _name The name of the candidate.
     */
    function addCandidate(string memory _name) external votersRegistrationNotStarted onlyOwner {
        uint256 candidateId = candidates.length;
        candidates.push(Candidate(_name, 0));
        emit CandidateAdded(candidateId, _name);
    }

    /**
     * @notice Allows a voter to register for voting.
     */
    function registerToVote() external votingNotStarted onlyEOA {
        if (voters[msg.sender].isRegistered) revert Duplicate_Registration();

        voters[msg.sender].isRegistered = true;
        voters[msg.sender].registrationTime = block.timestamp;

        emit VoterRegistered(msg.sender);
    }

    /**
     * @notice Allows a registered voter to cast a vote for a candidate.
     * @param _candidateId The ID of the candidate being voted for.
     */
    function vote(uint256 _candidateId) external votingNotStarted {
        if (!voters[msg.sender].isRegistered) revert Not_Register();
        if (voters[msg.sender].hasVoted) revert Already_Voted();
        if(_candidateId >= candidates.length) revert Invalid_CandidateId();

        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedCandidateId = _candidateId;
        candidates[_candidateId].voteCount++;

        emit VoteCasted(msg.sender, _candidateId);
    }

    /**
     * @notice Picks the winner based on the maximum votes received by a candidate.
     */
    function pickWinner() external onlyOwner {
        if (block.timestamp < startTime + candidateSelectionPeriod + registrationPeriod + votingPeriod ) revert Voting_Inprogress();

        uint256 winnerId_;
        string memory winnerName;
        uint256 maxVotes = 0;

        for (uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > maxVotes) {
                maxVotes = candidates[i].voteCount;
                winnerId_ = i;
                winnerName = candidates[i].name;
            }
        }

        if(maxVotes != 0) {
            winnerId = winnerId_;
            winner = winnerName;
            emit WinnerAnnounced(candidates[winnerId].name, maxVotes);
        } else {
            revert Zero_Votes();
        }
    }

    /**
     * @notice Retrieves the count of candidates.
     * @return The number of candidates.
     */
    function getCandidateCount() external view returns (uint256) {
        return candidates.length;
    }

    /**
     * @notice Retrieves details of a specific candidate.
     * @param _candidateId The ID of the candidate.
     * @return The name and vote count of the candidate.
     */
    function getCandidateDetails(uint256 _candidateId) external view returns (string memory, uint256) {
        if (_candidateId >= candidates.length) revert Invalid_CandidateId();
        return (candidates[_candidateId].name, candidates[_candidateId].voteCount);
    }

    /**
     * @notice Retrieves the name of the winner.
     * @return The name of the winner.
     */
    function getWinner() external view returns (string memory) {
        return winner;
    }

    /**
     * @notice Checks if a voter has registered.
     * @param _voterAddress The address of the voter.
     * @return A boolean indicating whether the voter is registered.
     */
    function hasVoterRegistered(address _voterAddress) external view returns (bool) {
        return voters[_voterAddress].isRegistered;
    }

    /**
     * @notice Checks if a voter has voted.
     * @param _voterAddress The address of the voter.
     * @return A boolean indicating whether the voter has voted.
     */
    function hasVoterVoted(address _voterAddress) external view returns (bool) {
        return voters[_voterAddress].hasVoted;
    }
}