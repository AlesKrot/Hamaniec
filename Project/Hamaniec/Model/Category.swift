//
//  Category.swift
//  Hamaniec
//
//  Created by Ales Krot on 23.04.22.
//

import Foundation
import UIKit

class Category {
    var name: String
    var icon: String?
    
    init(name: String) {
        self.name = name
    }
}

struct CategoriesList {
    var container = [Category]()

    init() {
        addBaseCategories()
    }
    
    mutating func addBaseCategories() {
        let categoryFood = Category(name: "Food")
        categoryFood.icon = "fork.knife.circle"
        let categoryPurchases = Category(name: "Purchases")
        categoryPurchases.icon = "bag.circle"
        let categoryAccommodation = Category(name: "Accommodation")
        categoryAccommodation.icon = "building.2.crop.circle"
        let categoryTransport = Category(name: "Transport")
        categoryTransport.icon = "car.circle"
        let categoryEntertainment = Category(name: "Entertainment")
        categoryEntertainment.icon = "theatermasks.circle"
        let categoryCommunication = Category(name: "Communication")
        categoryCommunication.icon = "phone.circle"
        let categorySalary = Category(name: "Salary")
        categorySalary.icon = "creditcard.circle"
        add(category: categoryFood)
        add(category: categoryPurchases)
        add(category: categoryAccommodation)
        add(category: categoryTransport)
        add(category: categoryEntertainment)
        add(category: categoryCommunication)
        add(category: categorySalary)
    }
    
    mutating func add(category: Category) {
        container.append(category)
    }
    
    mutating func remove(category index: Int) {
        container.remove(at: index)
    }
}
