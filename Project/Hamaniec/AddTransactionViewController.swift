//
//  AddTransactionViewController.swift
//  Hamaniec
//
//  Created by Ales Krot on 20.04.22.
//

import UIKit

protocol AddTransactionHandler: AnyObject {
    func add(income: Int)
    func add(spent: Int) throws
}

class AddTransactionViewController: UIViewController {
    @IBOutlet weak var transactionValueTextField: UITextField!
    @IBOutlet weak var transactionTypeSegmentControl: UISegmentedControl!
    @IBOutlet weak var transactionCategoryTextField: UITextField!
    @IBOutlet weak var transactionDateTextField: UITextField!
    private let categoryPicker = UIPickerView()
    private let datePicker = UIDatePicker()
    private var selectedDate: Date?
    private var categories = Categories()
    
    weak var transactionHandler: AddTransactionHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transactionValueTextField.placeholder = "Write your spent or income"
        transactionValueTextField.delegate = self
        
        transactionCategoryTextField.placeholder = "Category of transaction"
        transactionCategoryTextField.delegate = self
        transactionCategoryTextField.inputView = categoryPicker
        categoryPicker.dataSource = self
        categoryPicker.delegate = self
        
        transactionDateTextField.placeholder = "01.01.2000, 00:00"
        transactionDateTextField.inputView = datePicker
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .wheels
        addButtonDoneToToolbar()
        datePicker.addTarget(self, action: #selector(onDatePickerValueChanged(sender:)), for: .valueChanged)
    }
    
    func addButtonDoneToToolbar() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
        toolbar.setItems([done], animated: false)
        transactionDateTextField.inputAccessoryView = toolbar
    }
    
    @objc func doneAction() {
        transactionDateTextField.resignFirstResponder()
    }
    
    @objc func onDatePickerValueChanged(sender: UIDatePicker) {
        let date = sender.date
        selectedDate = date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy, HH:mm"
        let dateString = dateFormatter.string(from: date)
        transactionDateTextField.text = dateString
    }
    
    func handleFundsTextField(text: String?) throws {
        guard let funds = Int(text ?? "") else { throw AddTransactionControllerError.wrongValue }
        let isIncome = transactionTypeSegmentControl?.selectedSegmentIndex == 1
        isIncome ? transactionHandler?.add(income: funds) : try transactionHandler?.add(spent: funds)
        
    }
    
    @IBAction func didTapConfirmButton(_ sender: UIButton) {
        do {
            try handleFundsTextField(text: transactionValueTextField?.text)
            dismiss(animated: true)
        } catch {
            if let error = error as? TransactionManagerError {
                switch error {
                case .insufficientFunds:
                    showAlert(with: "Error", body: "Insufficient funds")
                case .insufficientCreditFunds:
                    showAlert(with: "Error", body: "Insufficient credit funds")
                }
            } else {
                showAlert(with: "Error", body: "Wrong value! Please, try again.")
            }
        }
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

enum AddTransactionControllerError: Error {
    case wrongValue
}

extension AddTransactionViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.container.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories.container[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        transactionCategoryTextField.text = categories.container[row]
    }
}

extension AddTransactionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
