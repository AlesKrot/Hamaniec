//
//  Transaction.swift
//  Hamaniec
//
//  Created by Ales Krot on 20.04.22.
//

import Foundation

class Transaction {
    let category: Categories
    let date: Date
    
    init(category: Categories, date: Date){
        self.category = category
        self.date = date
    }
}

struct Categories {
    var container: [String] = ["Food", "Purchases", "Accommodation", "Transport", "Car", "Entertainment", "Communication"]
    
    mutating func add(category: String){
        container.append(category)
    }
    
    mutating func remove(category: String){
        
    }
}
