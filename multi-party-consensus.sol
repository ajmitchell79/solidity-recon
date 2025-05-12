//HOW IT WORKS
//Submitting Records:

//Participants submit transaction records using the submitRecord() function, which records the data hash.

//Initiating Reconciliation:

//The startReconciliation() function initiates the reconciliation process, specifying a set of validators and a consensus threshold.

//Voting:

//Validators cast votes using castVote() with either a positive or negative vote.

//Consensus Evaluation:

//Once a sufficient number of votes are collected:

//If approvals meet the threshold, the record is marked as reconciled.

//If rejections exceed the allowable limit, the record is marked as not reconciled.

//Finalizing Reconciliation:

//The contract finalizes the reconciliation based on the voting outcome and updates the record status.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ReconciliationConsensus {

    struct TransactionRecord {
        uint256 id;
        address submitter;
        uint256 amount;
        bytes32 dataHash;
        bool reconciled;
    }

    struct ConsensusVote {
        address validator;
        bool vote;
    }

    struct Reconciliation {
        uint256 recordId;
        address[] validators;
        mapping(address => bool) hasVoted;
        uint256 approvals;
        uint256 rejections;
        uint256 threshold;
        bool finalized;
    }

    mapping(uint256 => TransactionRecord) public records;
    mapping(uint256 => Reconciliation) public reconciliations;

    uint256 public recordCount;
    uint256 public reconciliationCount;

    event RecordSubmitted(uint256 indexed id, address indexed submitter);
    event ReconciliationStarted(uint256 indexed reconciliationId, uint256 recordId);
    event VoteCast(uint256 indexed reconciliationId, address indexed validator, bool vote);
    event ReconciliationFinalized(uint256 indexed reconciliationId, bool outcome);

    // Submit a transaction record
    function submitRecord(uint256 _amount, bytes32 _dataHash) external {
        recordCount++;
        records[recordCount] = TransactionRecord(recordCount, msg.sender, _amount, _dataHash, false);
        emit RecordSubmitted(recordCount, msg.sender);
    }

    // Start a reconciliation process with a set of validators
    function startReconciliation(uint256 _recordId, address[] calldata _validators, uint256 _threshold) external {
        require(records[_recordId].id != 0, "Record does not exist");
        require(_threshold > 0 && _threshold <= _validators.length, "Invalid threshold");

        reconciliationCount++;
        Reconciliation storage rec = reconciliations[reconciliationCount];
        rec.recordId = _recordId;
        rec.validators = _validators;
        rec.threshold = _threshold;

        emit ReconciliationStarted(reconciliationCount, _recordId);
    }

    // Cast a vote on a reconciliation
    function castVote(uint256 _reconciliationId, bool _vote) external {
        Reconciliation storage rec = reconciliations[_reconciliationId];
        require(rec.finalized == false, "Reconciliation already finalized");
        require(rec.hasVoted[msg.sender] == false, "Validator already voted");

        // Ensure the sender is a validator
        bool isValidator = false;
        for (uint i = 0; i < rec.validators.length; i++) {
            if (rec.validators[i] == msg.sender) {
                isValidator = true;
                break;
            }
        }
        require(isValidator, "Not a validator");

        // Register the vote
        rec.hasVoted[msg.sender] = true;
        if (_vote) {
            rec.approvals++;
        } else {
            rec.rejections++;
        }

        emit VoteCast(_reconciliationId, msg.sender, _vote);

        // Check for consensus
        if (rec.approvals >= rec.threshold) {
            finalizeReconciliation(_reconciliationId, true);
        } else if (rec.rejections > rec.validators.length - rec.threshold) {
            finalizeReconciliation(_reconciliationId, false);
        }
    }

    // Finalize the reconciliation based on consensus
    function finalizeReconciliation(uint256 _reconciliationId, bool _outcome) internal {
        Reconciliation storage rec = reconciliations[_reconciliationId];
        rec.finalized = true;
        records[rec.recordId].reconciled = _outcome;

        emit ReconciliationFinalized(_reconciliationId, _outcome);
    }
}
