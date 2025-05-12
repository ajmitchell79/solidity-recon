// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Reconciliation {
    struct Record {
        uint256 id;
        address party;
        uint256 amount;
        uint256 timestamp;
        bytes32 hash;
        bool reconciled;
    }

    struct Dispute {
        uint256 id;
        address initiator;
        address counterparty;
        string reason;
        bool resolved;
    }

    mapping(uint256 => Record) public records;
    mapping(uint256 => Dispute) public disputes;

    uint256 public recordCount = 0;
    uint256 public disputeCount = 0;

    event RecordSubmitted(uint256 id, address party);
    event DisputeRaised(uint256 id, address initiator);
    event ReconciliationCompleted(uint256 recordId);

    function submitRecord(uint256 _id, uint256 _amount, bytes32 _hash) external {
        records[_id] = Record(_id, msg.sender, _amount, block.timestamp, _hash, false);
        emit RecordSubmitted(_id, msg.sender);
    }

    function reconcile(uint256 _id, bytes32 _hash) external {
        Record storage record = records[_id];

        require(record.reconciled == false, "Record already reconciled");
        require(record.hash == _hash, "Hash mismatch");

        record.reconciled = true;
        emit ReconciliationCompleted(_id);
    }

    function raiseDispute(uint256 _id, string calldata _reason) external {
        disputes[disputeCount] = Dispute(_id, msg.sender, records[_id].party, _reason, false);
        emit DisputeRaised(disputeCount, msg.sender);
        disputeCount++;
    }
}
