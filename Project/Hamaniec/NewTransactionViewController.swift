//
//  AddTransactionViewController.swift
//  Hamaniec
//
//  Created by Ales Krot on 20.04.22.
//

import UIKit
import CoreData

protocol NewTransactionViewContollerDelegate: AnyObject {
    func newTransactionViewController(_ controller: NewTransactionViewController, didCreate: Transaction)
}

class NewTransactionViewController: UIViewController {
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var newTransactionValueTextField: UITextField!
    @IBOutlet weak var newTransactionTypeSegmentControl: UISegmentedControl!
    @IBOutlet weak var newTransactionCategoryTextField: UITextField!
    @IBOutlet weak var newTransactionDateTextField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    
    private var whiteColorTextViewController = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
    private var backgroundColorViewController = UIColor(red: 53/255, green: 53/255, blue: 53/255, alpha: 1)
    private var backgroundColorTextField = UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 0.5)
    private var whiteColorTextFieldPlaceholder = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 0.5)
    
    private let categoryPicker = UIPickerView()
    private let datePicker = UIDatePicker()
    private var selectedDate: Date?
    
    var containerForCategories: [Category]?
    weak var delegate: NewTransactionViewContollerDelegate?
    
    var container: NSPersistentContainer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareColorsNewTransactionVC()
        
        newTransactionValueTextField.delegate = self
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
        
        confirmButton.isEnabled = false
    }
    
    func prepareColorsNewTransactionVC() {
        self.view.backgroundColor = backgroundColorViewController
        newTransactionTypeSegmentControl.tintColor = whiteColorTextViewController
        amountLabel.textColor = whiteColorTextViewController
        categoryLabel.textColor = whiteColorTextViewController
        dateLabel.textColor = whiteColorTextViewController
        newTransactionValueTextField.backgroundColor = backgroundColorTextField
        newTransactionValueTextField.textColor = whiteColorTextViewController
        newTransactionValueTextField.attributedPlaceholder = NSAttributedString(string: "Write your spent or income", attributes: [NSAttributedString.Key.foregroundColor: whiteColorTextFieldPlaceholder])
        newTransactionCategoryTextField.backgroundColor = backgroundColorTextField
        newTransactionCategoryTextField.textColor = whiteColorTextViewController
        newTransactionCategoryTextField.attributedPlaceholder = NSAttributedString(string: "Category of transaction", attributes: [NSAttributedString.Key.foregroundColor: whiteColorTextFieldPlaceholder])
        newTransactionDateTextField.backgroundColor = backgroundColorTextField
        newTransactionDateTextField.textColor = whiteColorTextViewController
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
    
    @IBAction func didTapConfirmButton(_ sender: UIButton) {
        guard let transactionType = newTransactionTypeSegmentControl?.selectedSegmentIndex,
              let transactionValue = newTransactionValueTextField.text,
              let transactionCategory = newTransactionCategoryTextField.text,
              let transactionDate = selectedDate else { return }
        
        let context = container.viewContext
        let transactionObject = Transaction(context: context)
    
        transactionObject.type = Int16(transactionType)
        transactionObject.value = Float(transactionValue) ?? 0
        transactionObject.category = transactionCategory
        transactionObject.date = transactionDate
        
        dismiss(animated: true, completion: {
            self.delegate?.newTransactionViewController(self, didCreate: transactionObject)
        })
    }
}

extension NewTransactionViewController: UIPickerViewDelegate, UIPickerViewDataSource {
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
        newTransactionCategoryTextField.text = categories[row].name
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if !(newTransactionValueTextField.text?.isEmpty ?? false) && !(newTransactionCategoryTextField.text?.isEmpty ?? false) && !(newTransactionDateTextField.text?.isEmpty ?? false) {
            confirmButton.isEnabled = true
        } else {
            confirmButton.isEnabled = false
        }
    }
}
