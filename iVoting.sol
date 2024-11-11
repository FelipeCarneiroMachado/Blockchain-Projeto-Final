//SPDX-License-Identifier: GPL
pragma solidity  <= 0.9.0;


contract iVoting {
    mapping (bytes32 => bool) private  eligibleToVote;
    mapping (string => uint128) private voteCount;
    string[] private candidates;
    bool private electionStarted = false;
    bool private electionFinished= false;

    struct Result{
        string candidate;
        uint128 votes;
    }


    modifier electionIsActive() {
        require(electionStarted == true && electionFinished == false, "ELection is not active in this moment.");
        _;
    }
    modifier registerFase() {
        require(electionStarted == false, "Unable to alter election data after it has started");
        _;
    }
    modifier canVote(bytes32 _hashedCPF) {
        require(eligibleToVote[_hashedCPF] == true, "Already voted or has not been registered");
        _;
    }
    modifier electionIsFinished() {
        require(electionFinished == true, "Election must be over before results are releaed.");
        _;
    }
    function registerCandidate(string calldata _candidate) external registerFase {
        voteCount[_candidate] = 0;
        candidates.push(_candidate);
    }
    function registerVoter(string calldata _cpf) external registerFase {
        eligibleToVote[keccak256(abi.encode(_cpf))] = true;
    }
    function startElection() external registerFase {
        electionStarted = true;
    }
    function endElection() external electionIsActive {
        electionFinished = true;
    }
    function sendVote(string calldata _cpf, string calldata _candidate) external electionIsActive canVote(keccak256(abi.encode(_cpf))) {
        voteCount[_candidate] += 1;
        eligibleToVote[keccak256(abi.encode(_cpf))] = false;
    }
    function getResults() external view electionIsFinished returns(Result[] memory) {
        Result[] memory results =  new Result[](candidates.length);
        for (uint i = 0; i < candidates.length; i++){
            results[i] = (Result(candidates[i], voteCount[candidates[i]]));
        }
        return results; 

    }

}

