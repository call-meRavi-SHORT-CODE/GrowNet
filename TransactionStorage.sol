// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

contract TransactionStorage {

    address public owner;

    struct Transaction {
        uint256 id;
        address payable SME;
        address payable investor;
        uint256 amount;
        bool isCompleted;
    }

    Transaction[] public transactions;
    mapping(uint256 => Transaction) public idToTransaction;
    uint256 public transactionCounter;

    event TransactionCreated(uint256 id, address SME, address investor, uint256 amount);
    event TransactionCompleted(uint256 id, address SME, address investor, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createTransaction(address payable _SME, address payable _investor, uint256 _amount) public onlyOwner {
        transactionCounter++;
        transactions.push(Transaction(transactionCounter, _SME, _investor, _amount, false));
        idToTransaction[transactionCounter] = transactions[transactions.length - 1];
        emit TransactionCreated(transactionCounter, _SME, _investor, _amount);
    }

    function completeTransaction(uint256 _id) public onlyOwner {
        Transaction storage transaction = idToTransaction[_id];
        require(!transaction.isCompleted, "Transaction already completed");
        require(address(this).balance >= transaction.amount, "Insufficient funds");

        transaction.SME.transfer(transaction.amount);
        transaction.isCompleted = true;
        emit TransactionCompleted(_id, transaction.SME, transaction.investor, transaction.amount);
    }

    function fundContract() public payable onlyOwner {}

    function getTransaction(uint256 _id) public view returns (uint256, address, address, uint256, bool) {
        Transaction memory transaction = idToTransaction[_id];
        return (transaction.id, transaction.SME, transaction.investor, transaction.amount, transaction.isCompleted);
    }
}