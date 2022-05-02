//
//  CategoriesTransactionsViewController.swift
//  Hamaniec
//
//  Created by Ales Krot on 28.04.22.
//

import UIKit

protocol CategoriesTransactionViewControllerDelegate: AnyObject {
    func categoriesTransactionViewController(_ controller: CategoriesTransactionsViewController, add category: Category)
    func categoriesTransactionViewController(_ controller: CategoriesTransactionsViewController,removeCategoryAt index: Int)
}

class CategoriesTransactionsViewController: UIViewController {
    @IBOutlet weak var categoriesTableView: UITableView! {
        didSet {
            categoriesTableView.delegate = self
            categoriesTableView.dataSource = self
        }
    }
    
    var containerForCategories: [Category]?
    weak var delegate: CategoriesTransactionViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Categories"
        addRightBarButtonItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        categoriesTableView.reloadData()
    }
    
    func addRightBarButtonItem() {
        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBarButtonItem))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    @objc func addBarButtonItem() {
        alertAddCategory()
    }
    
    func alertAddCategory() {
        let alert = UIAlertController(title: "Add", message: "Write new category in text field", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { _ in
            let textField = alert.textFields![0] as UITextField
            guard let text = textField.text else { return }
            let newCategory = Category(name: text)
            self.dismiss(animated: true, completion: {
                self.delegate?.categoriesTransactionViewController(self, add: newCategory)
            })
            textField.resignFirstResponder()
            self.categoriesTableView.reloadData()
        }
        alert.addTextField { textField in
            textField.textColor = .black
        }
        alert.addAction(action)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension CategoriesTransactionsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let categories = containerForCategories else { return 0 }
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = "categoryCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: id) as? CategoryTableViewCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("CategoryTableViewCell", owner: nil, options: nil)?[0] as? CategoryTableViewCell
        }
        
        let currentCategoryCell = containerForCategories![indexPath.row]
        cell?.nameCategoryLabel.text = currentCategoryCell.name
        cell?.imageCategoryView.image = UIImage(systemName: currentCategoryCell.icon ?? "tag.circle")
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ViewConfig.kCellHeight
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        categoriesTableView.beginUpdates()
        
        let allertController = UIAlertController(title: "Remove category", message: "Are you sure?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Remove", style: .destructive) { _ in
            self.delegate?.categoriesTransactionViewController(self, removeCategoryAt: indexPath.row)
            allertController.dismiss(animated: true, completion: nil)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            allertController.dismiss(animated: true, completion: nil)
        }
        
        allertController.addAction(deleteAction)
        allertController.addAction(cancelAction)
        present(allertController, animated: true, completion: nil)
        
        categoriesTableView.endUpdates()
    }
}
