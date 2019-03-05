//
//  SignUp2VC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 5/27/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit

class SignUp2VC: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
  
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var dobTF: UITextField!
    @IBOutlet weak var heightTF: UITextField!
    @IBOutlet weak var trainerEmailTF: UITextField!
    var user: UserItem = UserItem()
    var oldPassword = ""
    let picker = UIPickerView()
    let datePicker = UIDatePicker()
    let feetArray = [Int](1...10)
    let feetSymbol = ["'"]
    let inchesArray = [Int](0...11)
    let inchesSymbol = ["”"]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupPicker()
        setupDatePicker()
        
        if user.firstName.count > 0 {
            firstNameTF.text = user.firstName
            lastNameTF.text = user.lastName
            dobTF.text = user.dOB
            heightTF.text = user.height
            trainerEmailTF.text = user.trainerEmail
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if component == 0 {
            return feetArray.count
        }
        else if component == 1 {
            return feetSymbol.count
        }
        else if component == 2 {
            return inchesArray.count
        }
        else if component == 3 {
            return inchesSymbol.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
    
        if component == 0 {
            return 100.0
        }
        else if component == 1 {
             return 20.0
        }
        else if component == 2 {
            return 100.0
        }
        else if component == 3 {
             return 20.0
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if component == 0 {
            return String(feetArray[row])
        }
        else if component == 1 {
            return feetSymbol[row]
        }
        else if component == 2 {
            return String(inchesArray[row])
        }
        else if component == 3 {
            return inchesSymbol[row]
        }
        return ""
    }
    
    func setupViews() {
        hideKeyboardWhenTappedAround()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        dobTF.delegate = self
        heightTF.delegate = self
        nextButton.layer.cornerRadius = 18
        firstNameTF.addPadding(.left(35))
        lastNameTF.addPadding(.left(35))
        dobTF.addPadding(.left(35))
        heightTF.addPadding(.left(35))
        trainerEmailTF.addPadding(.left(35))
        
        nextButton.addTarget(self, action: #selector(goNext), for: .touchUpInside)
    }
    
    func setupPicker() {
        picker.delegate = self
        picker.dataSource = self
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelPicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        heightTF.inputView = picker
        heightTF.inputAccessoryView = toolBar
    }
    
    func setupDatePicker() {
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([cancelButton,spaceButton, doneButton], animated: false)
        
       // datePicker.locale = Locale(identifier:"en_US_POSIX")
        dobTF.inputAccessoryView = toolbar
        dobTF.inputView = datePicker
        datePicker.datePickerMode = .date
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: UIControlEvents.valueChanged)
    }
    
    func validation(firstName: String, lastName: String, dob: String, height: String, trainerEmail: String) -> Bool {
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        if firstName.count > 0 && lastName.count > 0 /*  && dob.count > 0 && height.count > 0 */ {
            
            if trainerEmail.count > 0 && trainerEmail != "none" {
                if !emailTest.evaluate(with: trainerEmail) {
                    self.showErrorHUD(text: "Please write a valid email")
                    return false
                }
            }
            return true
        }
        self.showErrorHUD(text: "Please fill all fields")
        return false
    }
    
    @objc func donePicker() {
        heightTF.text = String((feetArray[picker.selectedRow(inComponent: 0)])) + feetSymbol[0] + String((inchesArray[picker.selectedRow(inComponent: 2)])) + inchesSymbol[0]
        trainerEmailTF.perform(
            #selector(becomeFirstResponder),
            with: nil,
            afterDelay: 0.1
        )
        self.view.endEditing(true)
    }
    
    @objc func cancelPicker(){
        self.view.endEditing(true)
    }
    
    @objc func datePickerValueChanged(){
        dobTF.text = datePicker.date.toString(dateFormat: "MM/dd/yyyy")
    }
    
    @objc func donedatePicker(){
        dobTF.text = datePicker.date.toString(dateFormat: "MM/dd/yyyy")
        heightTF.perform(
            #selector(becomeFirstResponder),
            with: nil,
            afterDelay: 0.1
        )
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    @objc func goNext() {
        let firstName = firstNameTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastName = lastNameTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        var dob = dobTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        var height = heightTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let trainerEmail = trainerEmailTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if validation(firstName: firstName, lastName: lastName, dob: dob, height: height, trainerEmail: trainerEmail) {
            user.firstName = firstName
            user.lastName = lastName
            
            if dob.count == 0 {
                dob = "none"
            }
            if height.count == 0 {
                height = "none"
            }
            
            user.dOB = dob
            user.height = height
            
            if trainerEmail.count > 0 {
                user.trainerEmail = trainerEmail
            }
            else {
                user.trainerEmail = "none"
            }
            goToSignUp3VC()
        }
    }

    @objc func goToSignUp3VC() {
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "SignUp3VC") as! SignUp3VC
        destVC.user = user
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        self.navigationController?.pushViewController(destVC, animated: true)
    }
}
