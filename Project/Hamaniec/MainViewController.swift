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
    @IBOutlet weak var lastTransactionsTableView: UITableView! {
        didSet {
            lastTransactionsTableView.delegate = self
            lastTransactionsTableView.dataSource = self
        }
    }
    
    private let transationManager = TransactionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transationManager.delegate = self
        lastTransactionsTableView.separatorStyle = .none
    }
    
    @IBAction func didTapAddTransaction(_ sender: UIButton) {
        let newTransactionViewController = NewTransactionViewController()
        newTransactionViewController.newTransactionDelegate = self
        newTransactionViewController.modalPresentationStyle = .automatic
        newTransactionViewController.transactionHandler = transationManager
        present(newTransactionViewController, animated: true)
    }
}

extension MainViewController: TransactionManagerDelegate {
    func didUpdateTotal(funds: Float) {
        totalMoneyAmountLabel.text = "\(funds)"
    }
    
    func didUpdateSpent(funds: Float) {
        totalSpentsAmountLabel.text = "\(funds)"
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transationManager.transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = "lastTransactionCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: id) as? LastTransactionsTableViewCell
        if cell == nil {
        cell = Bundle.main.loadNibNamed("LastTransactionsTableViewCell", owner: nil, options: nil)?[0] as? LastTransactionsTableViewCell
        }
        
        let currentTransactionCell = transationManager.transactions[indexPath.row]
        cell?.nameCategoryTransactionLabel.text = currentTransactionCell.category
        if currentTransactionCell.type == 0 {
            cell?.valueTransactionLabel.textColor = .red
            cell?.valueTransactionLabel.text = "-\(currentTransactionCell.formattedValueToString) BYN"
        } else {
            cell?.valueTransactionLabel.textColor = .green
            cell?.valueTransactionLabel.text = "+\(currentTransactionCell.formattedValueToString) BYN"
        }
        cell?.dateTransactionLabel.text = currentTransactionCell.formattedDate
        
        let valueCategory = currentTransactionCell.category
        var iconCategory = ""
        switch valueCategory {
        case "Food":
            iconCategory = "fork.knife.circle"
        case "Purchases":
            iconCategory = "bag.circle"
        case "Accommodation":
            iconCategory = "building.2.crop.circle"
        case "Transport":
            iconCategory = "car.circle"
        case "Entertainment":
            iconCategory = "theatermasks.circle"
        case "Communication":
            iconCategory = "phone.circle"
        case "Salary":
            iconCategory = "creditcard.circle"
        default:
            iconCategory = "t.circle"
        }
        cell?.imageCategoryTransaction.image = UIImage(systemName: iconCategory)
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ViewConfig.kCellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTransaction = transationManager.transactions[indexPath.row]
        let editTransactionViewController = EditTransactionViewController()
        editTransactionViewController.editTransactionDelegate = self
        editTransactionViewController.modalPresentationStyle = .automatic
        editTransactionViewController.currentTransaction = selectedTransaction
        present(editTransactionViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        lastTransactionsTableView.beginUpdates()
        
        let allertController = UIAlertController(title: "Delete transaction with value \(transationManager.transactions[indexPath.row].formattedValueToString)", message: "Are you sure?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.transationManager.transactions.remove(at: indexPath.row)
            allertController.dismiss(animated: true, completion: nil)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            allertController.dismiss(animated: true, completion: nil)
        }
        
        allertController.addAction(deleteAction)
        allertController.addAction(cancelAction)
        present(allertController, animated: true, completion: nil)
        
        lastTransactionsTableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: ViewConfig.kCellHeight))
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.frame.size.width, height: ViewConfig.kCellHeight))
        label.font = UIFont.systemFont(ofSize: 25)
        label.text = "Last transactions"
        view.addSubview(label)
        view.backgroundColor = UIColor.gray
        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "Last transactions"
//    }
}

extension MainViewController: NewTransactionViewContollerDelegate {
    func newTransactionViewController(_ controller: NewTransactionViewController, didCreate transaction: Transaction) {
        transationManager.save(transaction: transaction)
        transationManager.transactions.sort(by: { $0.date > $1.date })
        guard let index = transationManager.transactions.firstIndex(of: transaction) else { return }
        let indexPath = IndexPath(row: index, section: 0)
        lastTransactionsTableView.insertRows(at: [indexPath], with: .fade)
    }
}

extension MainViewController: EditTransactionViewControllerDelegate {
    func editTransactionViewController(_ controller: EditTransactionViewController, didCreate: Transaction, didRemove: Transaction) {
        transationManager.edit(oldTransaction: didRemove, newTransaction: didCreate)
        transationManager.transactions.sort(by: { $0.date > $1.date })
        lastTransactionsTableView.reloadData()
    }
}
