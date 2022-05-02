//
//  TransactionManager.swift
//  Hamaniec
//
//  Created by Ales Krot on 20.04.22.
//

import Foundation
import UIKit

protocol TransactionManagerDelegate: AnyObject {
    func didUpdateTotal(funds: Float)
    func didUpdateSpent(funds: Float)
}

class TransactionManager: TransactionsHandler {
    private(set) var totalFunds: Float = 0 {
        didSet {
            delegate?.didUpdateTotal(funds: totalFunds)
        }
    }
    
    private(set) var totalSpentFunds: Float = 0 {
        didSet {
            delegate?.didUpdateSpent(funds: totalSpentFunds)
        }
    }
    
    var transactions = [Transaction]()
    weak var delegate: TransactionManagerDelegate?
    
    init() {
        createTestTransactions()
    }
    
    func createTestTransactions() {
        let transaction1 = Transaction(type: 0, value: 15, category: "Food", date: Date.now)
        let transaction2 = Transaction(type: 1, value: 50, category: "Salary", date: Date.init(timeInterval: -100000.00, since: .now))
        let transaction3 = Transaction(type: 0, value: 20, category: "Transport", date: Date.init(timeInterval: -150000.00, since: .now))
        let transaction4 = Transaction(type: 0, value: 10, category: "Communication", date: Date.init(timeInterval: -5184000, since: .now))
        save(transaction: transaction1)
        save(transaction: transaction2)
        save(transaction: transaction3)
        save(transaction: transaction4)
    }
    
    func updateTotalFunds() {
        let totalSpentTransactions = transactions.filter { $0.type == 0 }
        let totalIncomeTransactions = transactions.filter { $0.type == 1 }
        let totalSpentTransactionsValue = totalSpentTransactions.map { $0.value }
        let totalIncomeTransactionsValue = totalIncomeTransactions.map { $0.value }
        
        totalSpentFunds = totalSpentTransactionsValue.reduce(0, +)
        let totalIncomeAmount = totalIncomeTransactionsValue.reduce(0, +)
        
        totalFunds = totalIncomeAmount - totalSpentFunds
    }
    
    func save(transaction: Transaction) {
        transactions.append(transaction)
    }
    
    func edit(oldTransaction: Transaction, newTransaction: Transaction) {
        guard let index = transactions.firstIndex(of: oldTransaction) else { return }
        transactions[index] = newTransaction
    }
    
    func remove(at index: Int) {
        transactions.remove(at: index)
    }
}

//enum TransactionManagerError: Error {
//    case insufficientFunds
//    case insufficientCreditFunds
//}
