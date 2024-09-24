// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

struct Candidate{
    string candidate_name;
    string candidateParty;
    uint voteCount;
}

contract Voting {
    
    mapping (string => Candidate) candidateDetails;
    mapping (address => bool) voters;
    mapping (address => string) voterToCandidate;
    event VoteRight (address indexed _voter, string _candidate);
    event WinnerDeclared(string winnerName, uint voteCount);

    Candidate public winner;
    Candidate candidate; 
   
    address blockAdmin;  
    uint totalCandidates;
    bool state;
    uint256 voteUpdatedCount;
    string[] candidateNames;
    address[] votersList;

    constructor() {
        blockAdmin = msg.sender;
    
        candidateDetails["vinay"] = Candidate("vinay k", "Red Party", 0);
        candidateDetails["jayesh"] = Candidate("jayesh d", "Green Party", 0);
        candidateDetails["kunal"] = Candidate("kunal d", "Blue Party", 0);
        candidateDetails["sharan"] = Candidate("sharan w", "Yellow Party", 0);
        candidateDetails["NOTA"] = Candidate("NOTA", "None", 0);

        
        candidateNames.push("vinay");
        candidateNames.push("jayesh");
        candidateNames.push("kunal");
        candidateNames.push("sharan");
        candidateNames.push("NOTA");
        state = true;
        totalCandidates = candidateNames.length;
    }

    modifier checkBlockAdmin() {
        require(blockAdmin == msg.sender, "Not valid USER");
        _;
    }

    modifier isVoted() {
        require(!voters[msg.sender], "You have already voted");
        _;
    }
     
    modifier votingState() {
        require(state, "Voting Period is Ended");
        _;
    }
     modifier votingEnded() {
        require(!state, "Voting period has not ended yet");
        _;
    }


    function vote(string memory _candidateName) public isVoted votingState {
        require(bytes(candidateDetails[_candidateName].candidate_name).length != 0, "Candidate does not exist");
        voters[msg.sender] = true;  
        voterToCandidate[msg.sender] = _candidateName;  
        votersList.push(msg.sender);  
        candidateDetails[_candidateName].voteCount++;  
        emit VoteRight(msg.sender, _candidateName);
    }

    function viewBlockAdmin() public view checkBlockAdmin returns (address) {
        return blockAdmin;
    }

    function endVoting() public checkBlockAdmin {
        state = false;
    }

    
    function voteCountAndResult() public checkBlockAdmin votingEnded {
        uint maxCount = 0;
        for (uint i = 0; i < totalCandidates; i++) {
            string memory candidateName = candidateNames[i];
            if (candidateDetails[candidateName].voteCount > maxCount) {
                winner = candidateDetails[candidateName];
                maxCount = candidateDetails[candidateName].voteCount;
            }
        }
        emit WinnerDeclared (winner.candidate_name ,winner.voteCount);

    }

    function revokeVote(address _voter) public checkBlockAdmin {
        require(voters[_voter], "This address has not voted yet");

        string memory candidateName = voterToCandidate[_voter];

        candidateDetails[candidateName].voteCount--;
        
        voters[_voter] = false;
        delete voterToCandidate[_voter];
        voteUpdatedCount++;
    }

    function getVoteCount(string memory _name) checkBlockAdmin votingEnded public view returns(uint256) {
       require(bytes(candidateDetails[_name].candidate_name).length != 0, "Candidate does not exist");
       return candidateDetails[_name].voteCount;
    }

    function totalVotesCasted() public view checkBlockAdmin votingEnded returns (uint256) {
        return votersList.length-voteUpdatedCount;
    }
}
// vinay  1+1+1
//jayesh 
// sharan 1+
// NOTA  1+
// Kunal 1+1
