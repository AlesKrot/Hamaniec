//
//  ViewController.swift
//  Hamaniec
//
//  Created by Ales Krot on 13.04.22.
//

import UIKit
import CoreData

protocol TransactionsHandler: AnyObject {
    func save(transaction: Transaction)
    func remove(at index: Int)
    func updateTotalFunds()
}

protocol EditCategoriesHandler: AnyObject {
    func add(category: Category)
    func remove(category index: Int)
}

class MainViewController: UIViewController {

    @IBOutlet weak var titleTotalMoneyAmountLabel: UILabel!
    @IBOutlet weak var totalMoneyAmountLabel: UILabel!
    @IBOutlet weak var titleTotalSpentsAmountLabel: UILabel!
    @IBOutlet weak var totalSpentsAmountLabel: UILabel!
    @IBOutlet weak var lastTransactionsTableView: UITableView! {
        didSet {
            lastTransactionsTableView.delegate = self
            lastTransactionsTableView.dataSource = self
        }
    }
    
    @IBOutlet weak var statisticsButton: UIButton!
    @IBOutlet weak var addTransactionButton: UIButton!
    @IBOutlet weak var categoriesButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    
    private var whiteColorTextViewController = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
    private var backgroundColorViewController = UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1)
    private var redColorTextViewController = UIColor(red: 249/255, green: 135/255, blue: 112/255, alpha: 1)
    private var greenColorTextViewController = UIColor(red: 117/255, green: 189/255, blue: 185/255, alpha: 1)
    
    var container: NSPersistentContainer!
    
    var transactionManager = TransactionManager()
    let categoryManager = CategoryManager()
    
    weak var transactionHandlerDelegate: TransactionsHandler?
    weak var categoriesHandlerDelegate: EditCategoriesHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        container = AppDelegate.shared.persistentContainer
        
        guard container != nil else {
            fatalError("This view needs a persistent container.")
        }
        
        transactionManager.delegate = self
        transactionManager.updateTotalFunds()
        self.transactionHandlerDelegate = transactionManager
        self.categoriesHandlerDelegate = categoryManager
        
        prepareColorsMainVC()
//        navigationController?.navigationItem.titleView?.tintColor = whiteColorTextViewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let context = container.viewContext

        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()

        do {
            transactionManager.transactions = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        transactionManager.transactions.sort(by: { $0.date! > $1.date! })
    }
    
    func prepareColorsMainVC() {
        self.view.backgroundColor = backgroundColorViewController
        titleTotalMoneyAmountLabel.textColor = whiteColorTextViewController
        titleTotalSpentsAmountLabel.textColor = whiteColorTextViewController
        totalSpentsAmountLabel.textColor = redColorTextViewController
        lastTransactionsTableView.backgroundColor = backgroundColorViewController
        lastTransactionsTableView.separatorColor = whiteColorTextViewController
        
//        statisticsButton.imageView?.tintColor = whiteColorTextViewController
//        addTransactionButton.imageView?.tintColor = whiteColorTextViewController
//        categoriesButton.imageView?.tintColor = whiteColorTextViewController
//        infoButton.imageView?.tintColor = whiteColorTextViewController
    }
    
    @IBAction func didTapStatistics(_ sender: UIButton) {
        let statisticsTransactionsViewController = StatisticsTransactionsViewController()
        statisticsTransactionsViewController.containerForTransactions = transactionManager.transactions
        navigationController?.pushViewController(statisticsTransactionsViewController, animated: true)
    }
    
    @IBAction func didTapAddTransaction(_ sender: UIButton) {
        let newTransactionViewController = NewTransactionViewController()
        newTransactionViewController.modalPresentationStyle = .automatic
        newTransactionViewController.delegate = self
        newTransactionViewController.containerForCategories = categoryManager.container
        newTransactionViewController.container = container
        present(newTransactionViewController, animated: true)
    }
    
    @IBAction func didTapCategories(_ sender: Any) {
        let categoriesTransactions = CategoriesTransactionsViewController()
        categoriesTransactions.containerForCategories = categoryManager.container
        categoriesTransactions.delegate = self
        categoriesTransactions.container = container
        navigationController?.pushViewController(categoriesTransactions, animated: true)
    }
    
    @IBAction func didTapInfo(_ sender: UIButton) {
        let infoViewController = InfoViewController()
        navigationController?.pushViewController(infoViewController, animated: true)
    }
}

extension MainViewController: TransactionManagerDelegate {
    func didUpdateTotal(funds: Float) {
        let fundsToString = String(format:"%.2f", funds)
        switch funds {
        case 0.01...:
            totalMoneyAmountLabel.text = "+\(fundsToString) BYN"
            totalMoneyAmountLabel.textColor = greenColorTextViewController
        case 0:
            totalMoneyAmountLabel.text = "\(fundsToString) BYN"
            totalMoneyAmountLabel.textColor = .white
        default:
            totalMoneyAmountLabel.text = "\(fundsToString) BYN"
            totalMoneyAmountLabel.textColor = redColorTextViewController
        }
    }

    func didUpdateSpent(funds: Float) {
        let fundsToString = String(format:"%.2f", funds)
        totalSpentsAmountLabel.text = "-\(fundsToString) BYN"
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactionManager.transactions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = "lastTransactionCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: id) as? TransactionsTableViewCell
        if cell == nil {
        cell = Bundle.main.loadNibNamed("TransactionsTableViewCell", owner: nil, options: nil)?[0] as? TransactionsTableViewCell
        }

        let currentTransactionCell = transactionManager.transactions[indexPath.row]
        cell?.nameCategoryTransactionLabel.text = currentTransactionCell.category
        if currentTransactionCell.type == 0 {
            cell?.valueTransactionLabel.textColor = redColorTextViewController
            cell?.valueTransactionLabel.text = "-\(currentTransactionCell.formattedValueToString) BYN"
        } else {
            cell?.valueTransactionLabel.textColor = UIColor(red: 117/255, green: 189/255, blue: 185/255, alpha: 1)
            cell?.valueTransactionLabel.text = "+\(currentTransactionCell.formattedValueToString) BYN"
        }
        cell?.dateTransactionLabel.text = currentTransactionCell.formattedDate
        cell?.nameCategoryTransactionLabel.textColor = whiteColorTextViewController
        cell?.dateTransactionLabel.textColor = whiteColorTextViewController
        cell?.imageCategoryTransaction.tintColor = whiteColorTextViewController
        cell?.backgroundColor = backgroundColorViewController
        
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
            iconCategory = "tag.circle"
        }
        cell?.imageCategoryTransaction.image = UIImage(systemName: iconCategory)

        return cell!
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ViewConfig.kCellHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTransaction = transactionManager.transactions[indexPath.row]
        let editTransactionViewController = EditTransactionViewController()
        editTransactionViewController.delegate = self
        editTransactionViewController.modalPresentationStyle = .automatic
        editTransactionViewController.containerForCategories = categoryManager.container
        editTransactionViewController.currentTransaction = selectedTransaction
        editTransactionViewController.container = container
        present(editTransactionViewController, animated: true)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        lastTransactionsTableView.beginUpdates()

        let allertController = UIAlertController(title: "Remove transaction with value \(transactionManager.transactions[indexPath.row].formattedValueToString)", message: "Are you sure?", preferredStyle: .alert)

        let deleteAction = UIAlertAction(title: "Remove", style: .destructive) { _ in
            self.transactionHandlerDelegate?.remove(at: indexPath.row)
            allertController.dismiss(animated: true, completion: nil)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.transactionHandlerDelegate?.updateTotalFunds()
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
        label.textColor = whiteColorTextViewController
        view.addSubview(label)
        view.backgroundColor = backgroundColorViewController
        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
}

extension MainViewController: NewTransactionViewContollerDelegate {
    func newTransactionViewController(_ controller: NewTransactionViewController, didCreate: Transaction) {
        transactionHandlerDelegate?.save(transaction: didCreate)
        guard let index = transactionManager.transactions.firstIndex(of: didCreate) else { return }
        let indexPath = IndexPath(row: index, section: 0)
        lastTransactionsTableView.insertRows(at: [indexPath], with: .fade)
        transactionHandlerDelegate?.updateTotalFunds()
    }
}

extension MainViewController: EditTransactionViewControllerDelegate {
    func editTransactionViewController(_ controller: EditTransactionViewController) {
        transactionHandlerDelegate?.updateTotalFunds()
        lastTransactionsTableView.reloadData()
    }
}

extension MainViewController: CategoriesTransactionViewControllerDelegate {
    func categoriesTransactionViewController(_ controller: CategoriesTransactionsViewController, add category: Category) {
        categoriesHandlerDelegate?.add(category: category)
        controller.containerForCategories = categoryManager.container
        lastTransactionsTableView.reloadData()
    }
    
    func categoriesTransactionViewController(_ controller: CategoriesTransactionsViewController, removeCategoryAt index: Int) {
        categoriesHandlerDelegate?.remove(category: index)
        controller.containerForCategories = categoryManager.container
        lastTransactionsTableView.reloadData()
    }
}
