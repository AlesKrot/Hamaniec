//
//  TransactionManager.swift
//  Hamaniec
//
//  Created by Ales Krot on 20.04.22.
//

import Foundation

protocol TransactionManagerDelegate: AnyObject {
    func didUpdateTotal(funds: Float)
    func didUpdateSpent(funds: Float)
}

class TransactionManager: AddTransactionHandler {
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
    
    private var isDebtEnabled: Bool = true
    private var creditLimit: Float = -100
    var transactions = [Transaction]()
    
    weak var delegate: TransactionManagerDelegate?
    
    init() {
        let transaction1 = Transaction(type: 0, value: 15, category: "Food", date: Date.now)
        let transaction2 = Transaction(type: 1, value: 50, category: "Salary", date: Date.init(timeInterval: -100000.00, since: .now))
        let transaction3 = Transaction(type: 0, value: 20, category: "Transport", date: Date.init(timeInterval: -150000.00, since: .now))
        save(transaction: transaction1)
        save(transaction: transaction2)
        save(transaction: transaction3)
    }
    
    func add(income: Float) {
        totalFunds += income
    }
    
    func add(spent: Float) throws {
        if !isDebtEnabled && totalFunds < spent { throw TransactionManagerError.insufficientFunds }

        if isDebtEnabled && (totalFunds - spent) < creditLimit  { throw TransactionManagerError.insufficientCreditFunds }
        
        totalFunds -= spent
        totalSpentFunds += spent
    }
    
    func save(transaction: Transaction) {
        transactions.append(transaction)
    }
    
    func edit(oldTransaction: Transaction, newTransaction: Transaction) {
        guard let index = transactions.firstIndex(of: oldTransaction) else { return }
        transactions[index] = newTransaction
    }
    
    func loadRemoteTransactions(count: Int, completion: @escaping ([Int]) -> Void) {
        guard count <= 10 else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            var transactions = [Int]()
            for _ in 0..<count {
                transactions.append(Int.random(in: 4...20))
            }
            
            completion(transactions)
        }
    }
}

enum TransactionManagerError: Error {
    case insufficientFunds
    case insufficientCreditFunds
}
