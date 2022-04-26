//
//  AddTransactionViewController.swift
//  Hamaniec
//
//  Created by Ales Krot on 20.04.22.
//

import UIKit

protocol AddTransactionHandler: AnyObject {
    func add(income: Float)
    func add(spent: Float) throws
}

protocol NewTransactionViewContollerDelegate: AnyObject {
    func newTransactionViewController(_ controller: NewTransactionViewController, didCreate transaction: Transaction)
}

class NewTransactionViewController: UIViewController {
    @IBOutlet weak var newTransactionValueTextField: UITextField!
    @IBOutlet weak var newTransactionTypeSegmentControl: UISegmentedControl!
    @IBOutlet weak var newTransactionCategoryTextField: UITextField!
    @IBOutlet weak var newTransactionDateTextField: UITextField!
    private let categoryPicker = UIPickerView()
    private var categories = CategoriesList()
    private let datePicker = UIDatePicker()
    private var selectedDate: Date?
    
    weak var transactionHandler: AddTransactionHandler?
    weak var newTransactionDelegate: NewTransactionViewContollerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newTransactionValueTextField.placeholder = "Write your spent or income"
        newTransactionValueTextField.delegate = self
        
        newTransactionCategoryTextField.placeholder = "Category of transaction"
        newTransactionCategoryTextField.delegate = self
        newTransactionCategoryTextField.inputView = categoryPicker
        categoryPicker.dataSource = self
        categoryPicker.delegate = self
        
        newTransactionDateTextField.inputView = datePicker
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .wheels
        addButtonDoneToToolbar()
        
        insertDateNow(to: newTransactionDateTextField)
        
        datePicker.addTarget(self, action: #selector(onDatePickerValueChanged(sender:)), for: .valueChanged)
    }
    
    func insertDateNow(to textField: UITextField) {
        selectedDate = Date(timeIntervalSinceNow: 0)
        guard let date = selectedDate else { return }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy, HH:mm"
        let dateString = dateFormatter.string(from: date)
        textField.text = dateString
    }
    
    func addButtonDoneToToolbar() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
        toolbar.setItems([done], animated: false)
        newTransactionDateTextField.inputAccessoryView = toolbar
    }
    
    @objc func doneAction() {
        newTransactionDateTextField.resignFirstResponder()
    }
    
    @objc func onDatePickerValueChanged(sender: UIDatePicker) {
        let date = sender.date
        selectedDate = date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy, HH:mm"
        let dateString = dateFormatter.string(from: date)
        newTransactionDateTextField.text = dateString
    }
    
//    func handleFundsTextField(text: String?) throws {
//        guard let funds = Int(text ?? "") else { throw NewTransactionControllerError.wrongValue }
//        let isIncome = newTransactionTypeSegmentControl?.selectedSegmentIndex == 1
//        isIncome ? transactionHandler?.add(income: funds) : try transactionHandler?.add(spent: funds)
//    }
    
    @IBAction func didTapConfirmButton(_ sender: UIButton) {
        guard let transactionType = newTransactionTypeSegmentControl?.selectedSegmentIndex,
              let transactionValue = Float(newTransactionValueTextField.text ?? ""),
              let transactionCategory = newTransactionCategoryTextField.text,
              let transactionDate = selectedDate else { return }
        
        let transaction = Transaction(type: transactionType, value: abs(transactionValue), category: transactionCategory, date: transactionDate)
        dismiss(animated: true, completion: {
            self.newTransactionDelegate?.newTransactionViewController(self, didCreate: transaction)
        })
        
//        do {
//            try handleFundsTextField(text: newTransactionValueTextField?.text)
//            dismiss(animated: true)
//        } catch {
//            if let error = error as? TransactionManagerError {
//                switch error {
//                case .insufficientFunds:
//                    showAlert(with: "Error", body: "Insufficient funds")
//                case .insufficientCreditFunds:
//                    showAlert(with: "Error", body: "Insufficient credit funds")
//                }
//            } else {
//                showAlert(with: "Error", body: "Wrong value! Please, try again.")
//            }
//        }
    }
    
    func showAlert(with title: String, body: String) {
        let alertVC = UIAlertController(
            title: title,
            message: body,
            preferredStyle: .alert)
        present(alertVC, animated: true, completion: nil)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertVC.addAction(action)
    }
}

//enum NewTransactionControllerError: Error {
//    case wrongValue
//}

extension NewTransactionViewController: UIPickerViewDelegate, UIPickerViewDataSource {
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
        newTransactionCategoryTextField.text = categories.container[row].name
    }
}

extension NewTransactionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}