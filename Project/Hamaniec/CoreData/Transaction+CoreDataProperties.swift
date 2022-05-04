//
//  Transaction+CoreDataProperties.swift
//  Hamaniec
//
//  Created by Ales Krot on 3.05.22.
//
//

import Foundation
import CoreData


extension Transaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }

    @NSManaged public var category: String?
    @NSManaged public var date: Date?
    @NSManaged public var type: Int16
    @NSManaged public var value: Float

}

extension Transaction : Identifiable {

}
