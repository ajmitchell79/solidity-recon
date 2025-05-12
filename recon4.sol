

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Reconciliation {

    struct TransactionRecord {
        uint256 id;
        address submitter;
        bytes32 dataHash;  // Hash of the transaction data
        bool reconciled;
    }

    mapping(uint256 => TransactionRecord) public records;
    uint256 public recordCount;

    event RecordSubmitted(uint256 recordId, address indexed submitter, bytes32 dataHash);
    event ReconciliationResult(uint256 recordId, bool reconciled);

    /**
     * @dev Submit a transaction record.
     * @param _dataHash The hash of the transaction data.
     */
    function submitRecord(bytes32 _dataHash) external {
        recordCount++;
        records[recordCount] = TransactionRecord(recordCount, msg.sender, _dataHash, false);
        emit RecordSubmitted(recordCount, msg.sender, _dataHash);
    }

    /**
     * @dev Reconcile two records by comparing their hashes.
     * @param _recordId1 The first record ID.
     * @param _recordId2 The second record ID.
     */
    function reconcileRecords(uint256 _recordId1, uint256 _recordId2) external {
        TransactionRecord storage record1 = records[_recordId1];
        TransactionRecord storage record2 = records[_recordId2];

        require(record1.id != 0 && record2.id != 0, "Invalid record IDs");
        require(!record1.reconciled && !record2.reconciled, "Records already reconciled");

        // Check if the data hashes match
        if (record1.dataHash == record2.dataHash) {
            record1.reconciled = true;
            record2.reconciled = true;
            emit ReconciliationResult(_recordId1, true);
            emit ReconciliationResult(_recordId2, true);
        } else {
            emit ReconciliationResult(_recordId1, false);
            emit ReconciliationResult(_recordId2, false);
        }
    }
}
