//
//  EditTransactionViewController.swift
//  Hamaniec
//
//  Created by Ales Krot on 25.04.22.
//

import UIKit

protocol EditTransactionViewControllerDelegate: AnyObject {
    func editTransactionViewController(_ controller: EditTransactionViewController, didCreate: Transaction, didRemove: Transaction)
}

class EditTransactionViewController: UIViewController {
    @IBOutlet weak var editTransactionTypeSegmentControl: UISegmentedControl!
    @IBOutlet weak var editTransactionValueTextField: UITextField!
    @IBOutlet weak var editTransactionCategoryTextField: UITextField!
    @IBOutlet weak var editTransactionDateTextField: UITextField!
    @IBOutlet weak var editButton: UIButton!
    
    var currentTransaction: Transaction?
    weak var transactionHandler: AddTransactionHandler?
    weak var editTransactionDelegate: EditTransactionViewControllerDelegate?
    
    private let categoryPicker = UIPickerView()
    private var categories = CategoriesList()
    private let datePicker = UIDatePicker()
    private var selectedDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let currentTransaction = currentTransaction else { return }
        editTransactionTypeSegmentControl.selectedSegmentIndex = currentTransaction.type
        editTransactionValueTextField.text = currentTransaction.formattedValueToString
        editTransactionCategoryTextField.text = currentTransaction.category
        editTransactionDateTextField.text = currentTransaction.formattedDate
        editTransactionValueTextField.delegate = self
        editTransactionCategoryTextField.delegate = self
        editTransactionCategoryTextField.inputView = categoryPicker
        categoryPicker.dataSource = self
        categoryPicker.delegate = self
        editTransactionDateTextField.inputView = datePicker
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .wheels
        addButtonDoneToToolbar()
        addCategoryButtonToToolbar()
        selectedDate = currentTransaction.date
        datePicker.addTarget(self, action: #selector(onDatePickerValueChanged(sender:)), for: .valueChanged)
        editButton.isEnabled = false
    }
    
    func addCategoryButtonToToolbar() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAction))
        toolbar.setItems([add], animated: false)
        editTransactionCategoryTextField.inputAccessoryView = toolbar
    }
    
    @objc func addAction() {
        alertAddCategory()
    }
    
    func alertAddCategory() {
        let alert = UIAlertController(title: "Add new category", message: "Write new category in text field", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { _ in
            let textField = alert.textFields![0] as UITextField
            
            guard let text = textField.text else { return }
            let newCategory = Category(name: text)
            self.categories.add(category: newCategory)
            self.editTransactionCategoryTextField.resignFirstResponder()
        }
        alert.addTextField { textField in
            textField.textColor = .black
        }
        alert.addAction(action)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func addButtonDoneToToolbar() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
        toolbar.setItems([done], animated: false)
        editTransactionDateTextField.inputAccessoryView = toolbar
    }
    
    @objc func doneAction() {
        editTransactionDateTextField.resignFirstResponder()
    }
    
    @objc func onDatePickerValueChanged(sender: UIDatePicker) {
        let date = sender.date
        selectedDate = date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy, HH:mm"
        let dateString = dateFormatter.string(from: date)
        editTransactionDateTextField.text = dateString
    }

    @IBAction func didTapEditButton(_ sender: UIButton) {
        print("Button works")
        guard let transactionType = editTransactionTypeSegmentControl?.selectedSegmentIndex,
              let transactionValue = Float(editTransactionValueTextField.text ?? ""),
              let transactionCategory = editTransactionCategoryTextField.text,
              let transactionDate = selectedDate else { return }
        
        let newTransaction = Transaction(type: transactionType, value: transactionValue, category: transactionCategory, date: transactionDate)
        
        guard let oldTransaction = currentTransaction else { return }
        transactionHandler?.updateTotalFunds()
        dismiss(animated: true, completion: {
            self.editTransactionDelegate?.editTransactionViewController(self, didCreate: newTransaction, didRemove: oldTransaction)
        })
    }
}

extension EditTransactionViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.container.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories.container[row].name
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        editTransactionCategoryTextField.text = categories.container[row].name
    }
}

extension EditTransactionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if !(editTransactionValueTextField.text?.isEmpty ?? false) && !(editTransactionCategoryTextField.text?.isEmpty ?? false) && !(editTransactionDateTextField.text?.isEmpty ?? false) {
            editButton.isEnabled = true
        } else {
            editButton.isEnabled = false
        }
    }
}
