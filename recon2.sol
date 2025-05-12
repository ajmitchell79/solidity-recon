// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Reconciliation {

    struct Transaction {
        uint256 id;
        uint256 amount;
        bool isSettled;
    }

    mapping(uint256 => Transaction) public transactions;

    event Reconciled(uint256 transactionId, uint256 amount);

    function addTransaction(uint256 _id, uint256 _amount) public {
        transactions[_id] = Transaction(_id, _amount, false);
    }

    function reconcile(uint256 _id, uint256 _amount) public {
        require(transactions[_id].amount == _amount, "Discrepancy detected");
        transactions[_id].isSettled = true;
        emit Reconciled(_id, _amount);
    }

}
