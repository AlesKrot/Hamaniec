//
//  TransactionManager.swift
//  Hamaniec
//
//  Created by Ales Krot on 20.04.22.
//

import UIKit
import CoreData

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
    
    //    init() {
    //        createTestTransactions()
    //    }
    //
    //    func createTestTransactions() {
    //        let transaction1 = Transaction(type: 0, value: 15, category: "Food", date: Date.now)
    //        let transaction2 = Transaction(type: 1, value: 50, category: "Salary", date: Date.init(timeInterval: -100000.00, since: .now))
    //        let transaction3 = Transaction(type: 0, value: 20, category: "Transport", date: Date.init(timeInterval: -150000.00, since: .now))
    //        let transaction4 = Transaction(type: 0, value: 10, category: "Communication", date: Date.init(timeInterval: -5184000, since: .now))
    //        save(transaction: transaction1)
    //        save(transaction: transaction2)
    //        save(transaction: transaction3)
    //        save(transaction: transaction4)
    //    }
    
    func updateTotalFunds() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        
        do {
            transactions = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        transactions.sort(by: { $0.date! > $1.date! })
        
        let totalSpentTransactions = transactions.filter { $0.type == 0 }
        let totalIncomeTransactions = transactions.filter { $0.type == 1 }
        let totalSpentTransactionsValue = totalSpentTransactions.map { $0.value }
        let totalIncomeTransactionsValue = totalIncomeTransactions.map { $0.value }
        
        totalSpentFunds = totalSpentTransactionsValue.reduce(0, +)
        let totalIncomeAmount = totalIncomeTransactionsValue.reduce(0, +)
        
        totalFunds = totalIncomeAmount - totalSpentFunds
    }
    
    func save(transaction: Transaction) {
        //    func save(type: Int16, value: Float, category: String, date: Date) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        do {
            try context.save()
        } catch let error as NSError {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
        transactions.append(transaction)
        transactions.sort(by: { $0.date! > $1.date! })
    }
    
//    func edit(oldTransaction: Transaction, newTransaction: Transaction) {
//    func edit(oldTransaction: Transaction, newTransaction: Transaction) {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        let context = appDelegate.persistentContainer.viewContext
//
////                guard let entity = NSEntityDescription.entity(forEntityName: "Transaction", in: context) else { return }
////                let transactionObject = Transaction(entity: entity, insertInto: context)
//
//        context.delete(oldTransaction)
//        do {
//            try context.save()
//        } catch let error as NSError {
//            print("Error While Deleting Note: \(error.userInfo)")
//        }
////        guard let index = transactions.firstIndex(of: oldTransaction) else { return }
////        transactions[index] = newTransaction
//    }
    
    func remove(at index: Int) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let transaction = transactions[index]
        context.delete(transaction)
        do {
            try context.save()
        } catch let error as NSError {
            print("Error While Deleting Note: \(error.userInfo)")
        }
        transactions.remove(at: index)
    }
}
