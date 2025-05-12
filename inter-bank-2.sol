// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract InterbankSettlement {

    enum SettlementStatus { Pending, Confirmed, Reconciled, Settled, Disputed }

    struct Transaction {
        uint256 id;
        address senderBank;
        address receiverBank;
        uint256 amount;
        SettlementStatus status;
    }

    mapping(uint256 => Transaction) public transactions;
    uint256 public nextTransactionId = 1;

    event TransactionInitiated(uint256 id, address senderBank, address receiverBank, uint256 amount);
    event TransactionConfirmed(uint256 id, address bank);
    event SettlementCompleted(uint256 id, uint256 amount);
    event DisputeRaised(uint256 id, string reason);

    modifier onlyBanks() {
        require(msg.sender == tx.origin, "Only banks can call this function");
        _;
    }

    function initiateTransaction(address _receiverBank, uint256 _amount) public onlyBanks {
        uint256 txId = nextTransactionId;
        transactions[txId] = Transaction(txId, msg.sender, _receiverBank, _amount, SettlementStatus.Pending);
        nextTransactionId++;

        emit TransactionInitiated(txId, msg.sender, _receiverBank, _amount);
    }

    function confirmTransaction(uint256 _id) public onlyBanks {
        Transaction storage txn = transactions[_id];
        require(msg.sender == txn.receiverBank, "Only the receiving bank can confirm");
        require(txn.status == SettlementStatus.Pending, "Transaction is not pending");

        txn.status = SettlementStatus.Confirmed;
        emit TransactionConfirmed(_id, msg.sender);
    }

    function reconcileTransaction(uint256 _id, uint256 _expectedAmount) public onlyBanks {
        Transaction storage txn = transactions[_id];
        require(txn.status == SettlementStatus.Confirmed, "Transaction not confirmed");
       
        if (txn.amount == _expectedAmount) {
            txn.status = SettlementStatus.Settled;
            emit SettlementCompleted(_id, txn.amount);
        } else {
            txn.status = SettlementStatus.Disputed;
            emit DisputeRaised(_id, "Amount mismatch");
        }
    }
}
