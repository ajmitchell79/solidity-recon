// inter bank settlement #1
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract InterbankSettlement {

    struct Settlement {
        uint256 id;
        address bankA;
        address bankB;
        uint256 amount;
        bool confirmedByA;
        bool confirmedByB;
        bool isSettled;
    }

    mapping(uint256 => Settlement) public settlements;
    uint256 public nextId = 1;

    event SettlementInitiated(uint256 id, address bankA, address bankB, uint256 amount);
    event SettlementConfirmed(uint256 id, address bank, uint256 amount);
    event SettlementCompleted(uint256 id, uint256 amount);

    function initiateSettlement(address _bankB, uint256 _amount) public {
        settlements[nextId] = Settlement(nextId, msg.sender, _bankB, _amount, true, false, false);
        emit SettlementInitiated(nextId, msg.sender, _bankB, _amount);
        nextId++;
    }

    function confirmSettlement(uint256 _id) public {
        Settlement storage s = settlements[_id];
        require(s.bankB == msg.sender, "Only receiving bank can confirm");
        require(!s.isSettled, "Settlement already completed");

        s.confirmedByB = true;
        emit SettlementConfirmed(_id, msg.sender, s.amount);

        if (s.confirmedByA && s.confirmedByB) {
            s.isSettled = true;
            emit SettlementCompleted(_id, s.amount);
        }
    }
}
