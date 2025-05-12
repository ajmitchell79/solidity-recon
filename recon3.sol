// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FinancialReconciliation {

    struct Transaction {
        uint256 id;
        address payer;
        address payee;
        uint256 amount;
        bool isReconciled;
    }

    mapping(uint256 => Transaction) public transactions;

    event TransactionAdded(uint256 transactionId, address payer, address payee, uint256 amount);
    event TransactionReconciled(uint256 transactionId, uint256 amount);
    event DiscrepancyDetected(uint256 transactionId, uint256 expectedAmount, uint256 actualAmount);

    function addTransaction(uint256 _id, address _payer, address _payee, uint256 _amount) public {
        transactions[_id] = Transaction(_id, _payer, _payee, _amount, false);
        emit TransactionAdded(_id, _payer, _payee, _amount);
    }

    function reconcileTransaction(uint256 _id, uint256 _actualAmount) public {
        Transaction storage txn = transactions[_id];

        if (txn.amount == _actualAmount) {
            txn.isReconciled = true;
            emit TransactionReconciled(_id, _actualAmount);
        } else {
            emit DiscrepancyDetected(_id, txn.amount, _actualAmount);
        }
    }
}
