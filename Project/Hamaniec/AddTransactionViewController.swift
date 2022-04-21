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
    @IBOutlet weak var transactionCategoryPickerView: UIPickerView!
    
    weak var transactionHandler: AddTransactionHandler?
    var categories = Categories()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transactionValueTextField.placeholder = "Write your spent or income"
        transactionValueTextField.delegate = self
        
        
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

extension AddTransactionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
