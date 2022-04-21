//
//  ViewController.swift
//  Hamaniec
//
//  Created by Ales Krot on 13.04.22.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var totalMoneyAmountLabel: UILabel!
    @IBOutlet weak var totalSpentsAmountLabel: UILabel!
    
    private let transationManager = TransactionManager()
    private let addTransactionViewController = AddTransactionViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transationManager.delegate = self
    }
    
    @IBAction func didTapAddTransaction(_ sender: UIButton) {
        addTransactionViewController.modalPresentationStyle = .automatic
        addTransactionViewController.transactionHandler = transationManager
        present(addTransactionViewController, animated: true)
    }
}

extension MainViewController: TransactionManagerDelegate {
    func didUpdateTotal(funds: Int) {
        totalMoneyAmountLabel.text = "\(funds)"
    }
    
    func didUpdateSpent(funds: Int) {
        totalSpentsAmountLabel.text = "\(funds)"
    }
}
