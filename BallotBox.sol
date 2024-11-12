//SPDX-License-Identifier: GPL
pragma solidity  <= 0.9.0;


contract BallotBox {
    // Verifies validity of the hashed credentials
    mapping (bytes32 => bool) private  eligibleToVote;
    // Vote counting
    mapping (string => uint128) private voteCount;
    // List of candidates
    string[] private candidates;
    // Flag that signals the start of the election
    bool private electionStarted = false;
    // FLag that signas the end of the election
    bool private electionFinished= false;

    // Struct used to return the results of the election
    struct Result{
        string candidate;
        uint128 votes;
    }

    // Modifiers used to validate transactions

    // After election started and before it ended
    modifier electionIsActive() {
        require(electionStarted == true && electionFinished == false, "ELection is not active in this moment.");
        _;
    }
    // Before election started
    modifier registerFase() {
        require(electionStarted == false, "Unable to alter election data after it has started");
        _;
    }
    // Voter is valid
    modifier canVote(bytes32 _hashedCPF) {
        require(eligibleToVote[_hashedCPF] == true, "Already voted or has not been registered");
        _;
    }
    // After the election finished
    modifier electionIsFinished() {
        require(electionFinished == true, "Election must be over before results are releaed.");
        _;
    }

    // Registering functions

    // Register a candidate 
    function registerCandidate(string calldata _candidate) external registerFase {
        voteCount[_candidate] = 0;
        candidates.push(_candidate);
    }
    // Register a voter and saves the hash of his credentials
    function registerVoter(string calldata _cpf) external registerFase {
        eligibleToVote[keccak256(abi.encode(_cpf))] = true;
    }

    // Flag setting functions

    // Sets the electionStarted flag and initiaites the election
    function startElection() external registerFase {
        electionStarted = true;
    }
    // Sets the electionFinished flag and finishes the election
    function endElection() external electionIsActive {
        electionFinished = true;
    }

    // Voting function


    // Sends the vote and sets the hashed credential as invalid to vote again
    function sendVote(string calldata _cpf, string calldata _candidate) external electionIsActive canVote(keccak256(abi.encode(_cpf))) {
        voteCount[_candidate] += 1;
        eligibleToVote[keccak256(abi.encode(_cpf))] = false;
    }

    // Result returning


    // Returns the results as an array of structs
    function getResults() external view electionIsFinished returns(Result[] memory) {
        Result[] memory results =  new Result[](candidates.length);
        for (uint i = 0; i < candidates.length; i++){
            results[i] = (Result(candidates[i], voteCount[candidates[i]]));
        }
        return results; 

    }

}

