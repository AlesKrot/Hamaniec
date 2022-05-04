//
//  Transaction+CoreDataClass.swift
//  Hamaniec
//
//  Created by Ales Krot on 3.05.22.
//
//

import Foundation
import CoreData

@objc(Transaction)
public class Transaction: NSManagedObject {
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy, HH:mm"
        return dateFormatter.string(from: date!)
    }
    
    var formattedValueToString: String {
        return (String(format:"%.2f", value))
    }
}
