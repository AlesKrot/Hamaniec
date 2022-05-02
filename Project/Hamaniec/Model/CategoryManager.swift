//
//  CategoriesManager.swift
//  Hamaniec
//
//  Created by Ales Krot on 29.04.22.
//

import Foundation
import UIKit

class CategoryManager: EditCategoriesHandler {
    
    var container = [Category]()

    init() {
        addBaseCategories()
    }
    
    func addBaseCategories() {
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
        container = [categoryFood, categoryPurchases, categoryAccommodation, categoryTransport, categoryEntertainment, categoryCommunication, categorySalary]
    }
    
    func add(category: Category) {
        container.append(category)
    }
    
    func remove(category index: Int) {
        container.remove(at: index)
    }
}
