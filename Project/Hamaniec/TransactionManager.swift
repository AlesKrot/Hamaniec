//
//  TransactionManager.swift
//  Hamaniec
//
//  Created by Ales Krot on 20.04.22.
//

import Foundation

protocol TransactionManagerDelegate: AnyObject {
    func didUpdateTotal(funds: Int)
    func didUpdateSpent(funds: Int)
}

class TransactionManager: AddTransactionHandler {
    private(set) var totalFunds = 0 {
        didSet {
            delegate?.didUpdateTotal(funds: totalFunds)
        }
    }
    
    private(set) var totalSpentFunds = 0 {
        didSet {
            delegate?.didUpdateSpent(funds: totalSpentFunds)
        }
    }
    
    private var creditLimit = -50
    var isDebtEnabled = true
    
    weak var delegate: TransactionManagerDelegate?
    
    func add(income: Int) {
        totalFunds += income
    }
    
    func add(spent: Int) throws {
        if !isDebtEnabled && totalFunds < spent { throw TransactionManagerError.insufficientFunds }

        if isDebtEnabled && (totalFunds - spent) < creditLimit  { throw TransactionManagerError.insufficientCreditFunds }
        
        totalFunds -= spent
        totalSpentFunds += spent
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
