//
//  Transaction.swift
//  Hamaniec
//
//  Created by Ales Krot on 20.04.22.
//

import Foundation

struct Transaction: Equatable {
    var type: Int
    var value: Float
    var category: String?
    var date: Date
    
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy, HH:mm"
        return dateFormatter.string(from: date)
    }
    
    var formattedValueToString: String {
        return (String(format:"%.2f", value))
    }
    
    init(type: Int, value: Float, category: String, date: Date) {
        self.type = type
        self.value = value
        self.category = category
        self.date = date
    }
}
