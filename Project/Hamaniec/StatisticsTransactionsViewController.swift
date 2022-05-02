//
//  StatisticsTransactionsViewController.swift
//  Hamaniec
//
//  Created by Ales Krot on 28.04.22.
//

import UIKit

class StatisticsTransactionsViewController: UIViewController {
    @IBOutlet weak var periodStatisticsSegmentControl: UISegmentedControl!
    @IBOutlet weak var expensesStatisticsLabel: UILabel!
    
    private var expenses: Float = 0
    private let date = Date()
    private let calendar = Calendar.current
    var containerForTransactions: [Transaction]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Statistics"
        dailyExpensesStatistics()
        periodStatisticsSegmentControl.addTarget(self, action: #selector(changeExpensesStatistics), for: .valueChanged)
    }
    
    func dailyExpensesStatistics() {
        let currentDay = calendar.component(.day, from: date)
        let currentMonth = calendar.component(.month, from: date)
        let currentYear = calendar.component(.year, from: date)
        
        var dateComponentsOfDay = DateComponents()
        dateComponentsOfDay.hour = 00
        dateComponentsOfDay.minute = 00
        dateComponentsOfDay.day = currentDay
        dateComponentsOfDay.month = currentMonth
        dateComponentsOfDay.year = currentYear
        
        guard let startDay = calendar.date(from: dateComponentsOfDay) else { return }
        let spentTransactionArray = containerForTransactions!.filter{ $0.type == 0 }

        for transaction in spentTransactionArray {
            if transaction.date >= startDay {
                expenses += transaction.value
            }
        }
        expensesStatisticsLabel.text = String(format: "-%.2f BYN", expenses)
        expenses = 0
    }
    
    @objc func changeExpensesStatistics() {
        let currentDay = calendar.component(.day, from: date)
        let currentDayOfWeek = calendar.component(.weekday, from: date)
        let currentMonth = calendar.component(.month, from: date)
        let currentYear = calendar.component(.year, from: date)
        
        if periodStatisticsSegmentControl.selectedSegmentIndex == 0 {
            var dateComponentsOfDay = DateComponents()
            dateComponentsOfDay.hour = 00
            dateComponentsOfDay.minute = 00
            dateComponentsOfDay.day = currentDay
            dateComponentsOfDay.month = currentMonth
            dateComponentsOfDay.year = currentYear
            
            guard let startDay = calendar.date(from: dateComponentsOfDay) else { return }
            let spentTransactionArray = containerForTransactions!.filter{ $0.type == 0 }
            
            for transaction in spentTransactionArray {
                if transaction.date >= startDay {
                    expenses += transaction.value
                }
            }
        } else if periodStatisticsSegmentControl.selectedSegmentIndex == 1 {
            var dateComponentsOfWeek = DateComponents()
            dateComponentsOfWeek.hour = 00
            dateComponentsOfWeek.minute = 00
            dateComponentsOfWeek.day = currentDay - currentDayOfWeek
            dateComponentsOfWeek.month = currentMonth
            dateComponentsOfWeek.year = currentYear
            
            guard let startWeek = calendar.date(from: dateComponentsOfWeek) else { return }
            let spentTransactionArray = containerForTransactions!.filter{ $0.type == 0 }
            
            for transaction in spentTransactionArray {
                if transaction.date >= startWeek {
                    expenses += transaction.value
                }
            }
        } else if periodStatisticsSegmentControl.selectedSegmentIndex == 2 {
            var dateComponentsOfMonth = DateComponents()
            dateComponentsOfMonth.hour = 00
            dateComponentsOfMonth.minute = 00
            dateComponentsOfMonth.day = 1
            dateComponentsOfMonth.month = currentMonth
            dateComponentsOfMonth.year = currentYear
            
            guard let startMonth = calendar.date(from: dateComponentsOfMonth) else { return }
            let spentTransactionArray = containerForTransactions!.filter{ $0.type == 0 }
            
            for transaction in spentTransactionArray {
                if transaction.date >= startMonth {
                    expenses += transaction.value
                }
            }
        } else if periodStatisticsSegmentControl.selectedSegmentIndex == 3 {
            var dateComponentsOfYear = DateComponents()
            dateComponentsOfYear.hour = 00
            dateComponentsOfYear.minute = 00
            dateComponentsOfYear.day = 1
            dateComponentsOfYear.month = 1
            dateComponentsOfYear.year = currentYear
            
            guard let startYear = calendar.date(from: dateComponentsOfYear) else { return }
            let spentTransactionArray = containerForTransactions!.filter{ $0.type == 0 }
            
            for transaction in spentTransactionArray {
                if transaction.date >= startYear {
                    expenses += transaction.value
                }
            }
        }
        expensesStatisticsLabel.text = String(format: "-%.2f BYN", expenses)
        expenses = 0
    }
}
