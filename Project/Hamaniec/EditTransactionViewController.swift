//
//  EditTransactionViewController.swift
//  Hamaniec
//
//  Created by Ales Krot on 25.04.22.
//

import UIKit
import CoreData

protocol EditTransactionViewControllerDelegate: AnyObject {
    func editTransactionViewController(_ controller: EditTransactionViewController)
}

class EditTransactionViewController: UIViewController {
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var editTransactionTypeSegmentControl: UISegmentedControl!
    @IBOutlet weak var editTransactionValueTextField: UITextField!
    @IBOutlet weak var editTransactionCategoryTextField: UITextField!
    @IBOutlet weak var editTransactionDateTextField: UITextField!
    @IBOutlet weak var editButton: UIButton!
    
    private var whiteColorTextViewController = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
    private var backgroundColorViewController = UIColor(red: 53/255, green: 53/255, blue: 53/255, alpha: 1)
    private var backgroundColorTextField = UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 0.5)
    private var backgroundColorSegmentColor = UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1)
    
    var currentTransaction: Transaction?
    weak var delegate: EditTransactionViewControllerDelegate?
    var containerForCategories: [Category]?
    
    private let categoryPicker = UIPickerView()
    private let datePicker = UIDatePicker()
    private var selectedDate: Date?
    
    var container: NSPersistentContainer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareColorsEditTransactionVC()
        
        guard let currentTransaction = currentTransaction else { return }
        editTransactionTypeSegmentControl.selectedSegmentIndex = Int(currentTransaction.type)
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

        selectedDate = currentTransaction.date
        datePicker.addTarget(self, action: #selector(onDatePickerValueChanged(sender:)), for: .valueChanged)
        editButton.isEnabled = false
    }
    
    private func prepareColorsEditTransactionVC() {
        self.view.backgroundColor = backgroundColorViewController
        editTransactionTypeSegmentControl.tintColor = whiteColorTextViewController
        editTransactionTypeSegmentControl.backgroundColor = backgroundColorSegmentColor
        amountLabel.textColor = whiteColorTextViewController
        categoryLabel.textColor = whiteColorTextViewController
        dateLabel.textColor = whiteColorTextViewController
        editTransactionValueTextField.backgroundColor = backgroundColorTextField
        editTransactionValueTextField.textColor = whiteColorTextViewController
        editTransactionCategoryTextField.backgroundColor = backgroundColorTextField
        editTransactionCategoryTextField.textColor = whiteColorTextViewController
        editTransactionDateTextField.backgroundColor = backgroundColorTextField
        editTransactionDateTextField.textColor = whiteColorTextViewController
    }
    
    private func addButtonDoneToToolbar() {
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
        guard let transactionType = editTransactionTypeSegmentControl?.selectedSegmentIndex,
              let transactionValue = editTransactionValueTextField.text,
              let transactionCategory = editTransactionCategoryTextField.text,
              let transactionDate = selectedDate else { return }
        
        currentTransaction?.type = Int16(transactionType)
        currentTransaction?.value = Float(transactionValue) ?? 0
        currentTransaction?.category = transactionCategory
        currentTransaction?.date = transactionDate
        
        let context = container.viewContext
        do {
            try context.save()
        } catch let error as NSError {
            print("Error While Deleting Note: \(error.userInfo)")
        }
        dismiss(animated: true, completion: {
            self.delegate?.editTransactionViewController(self)
        })
    }
}

extension EditTransactionViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let categories = containerForCategories else { return 0 }
        return categories.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let categories = containerForCategories else { return "N/A category" }
        return categories[row].name
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let categories = containerForCategories else { return }
        editTransactionCategoryTextField.text = categories[row].name
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
