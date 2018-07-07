//
//  AddSessionVC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 6/2/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class AddSessionVC: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var locationTF: UITextField!
    @IBOutlet weak var commentTV: UITextView!
    @IBOutlet weak var caloriesTF: UITextField!
    @IBOutlet weak var weightTF: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    var activeField: UITextField?
    let picker = UIPickerView()
    var pool: AWSCognitoIdentityUserPool?
    let numberArray = [Int](1...1500)
    let inchesArray = [Int](1...500)
    let inchesDecimalArray = [Int](0...9)
    let inchesSymbol = "lbs"
    let caloriesSymbol = "calories"
    let session: Activity = Activity()
    var date = Date()
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rotateArrow()
        setupViews()
        setupTextFields()
        setupTextView()
        setupPicker()
        
        NotificationCenter.default.addObserver(self, selector: #selector(confirmDate(notification:)), name: .confirmDate, object: nil)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        picker.reloadAllComponents()
        return true
    }

    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.init(hex: "#c7c7cd") && textView.text.count > 0 {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Session Comment"
            textView.textColor = UIColor.init(hex: "#c7c7cd")
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        if activeField == caloriesTF {
            return 2
        }
        else if activeField == weightTF {
            return 3
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if activeField == caloriesTF {
            if component == 0 {
                return numberArray.count
            }
            else if component == 1 {
                return 1
            }
        }
        else if activeField == weightTF {
            if component == 0 {
                return inchesArray.count
            }
            else if component == 1 {
                return inchesDecimalArray.count
            }
            else if component == 2 {
                return 1
            }
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if activeField == caloriesTF {
            if component == 0 {
                return String(numberArray[row])
            }
            else if component == 1 {
                return caloriesSymbol
            }
        }
        else if activeField == weightTF {
            if component == 0 {
                return String(inchesArray[row])
            }
            else if component == 1 {
                return String(inchesDecimalArray[row])
            }
            else if component == 2 {
                return inchesSymbol
            }
        }
        return ""
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
        
        caloriesTF.inputView = picker
        caloriesTF.inputAccessoryView = toolBar
        weightTF.inputView = picker
        weightTF.inputAccessoryView = toolBar
    }
    
    @objc func donePicker() {
        if activeField == caloriesTF {
            caloriesTF.text = String((numberArray[picker.selectedRow(inComponent: 0)])) + " calories"
            weightTF.perform(
                #selector(becomeFirstResponder),
                with: nil,
                afterDelay: 0.1
            )
        }
        else if activeField == weightTF {
            weightTF.text = String((inchesArray[picker.selectedRow(inComponent: 0)])) + "." + String((inchesDecimalArray[picker.selectedRow(inComponent: 1)]))
        }
        
        self.view.endEditing(true)
    }
    
    @objc func cancelPicker(){
        self.view.endEditing(true)
    }
    
    func rotateArrow() {
        self.forwardButton.transform = CGAffineTransform(rotationAngle: .pi);
    }
    
    func setupViews() {
        formatter.dateFormat = "MMM d, yyyy"
        dateLabel.text = formatter.string(from: date)
       
        prevButton.addTarget(self, action: #selector(previousDate), for: .touchUpInside)
        forwardButton.addTarget(self, action: #selector(nextDate), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(goNext), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        calendarButton.addTarget(self, action: #selector(goToCalendarVC), for: .touchUpInside)
        
    }
    
    func setupTextFields() {
        locationTF.delegate = self
        caloriesTF.delegate = self
        weightTF.delegate = self
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
        locationTF.addPadding(.left(35))
        caloriesTF.addPadding(.left(35))
        weightTF.addPadding(.left(35))
    }
    
    func setupTextView() {
        commentTV.delegate = self
        commentTV.text = "Workout Comment"
        commentTV.textColor = UIColor.init(hex: "#c7c7cd")
    }
    
    func validation(calories: String, weight: String) -> Bool {
        
        if calories.count > 0 && weight.count > 0 {
            
            return true
        }
        else {
            self.showErrorHUD(text: "Please fill the required fields")
            return false
        }
        
    }
    
    @objc func confirmDate(notification: Notification) {
        if let date = notification.object as? String {
            self.date = formatter.date(from: date)!
            dateLabel.text = date
        }
    }
    
    @objc func previousDate() {
        date = Calendar.current.date(byAdding: .day, value: -1, to: date)!
        dateLabel.text = formatter.string(from: date)
    }
    
    @objc func nextDate() {
        date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
        dateLabel.text = formatter.string(from: date)
    }
    
    @objc func goNext() {
        let location = locationTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        var comment = commentTV.text.trimmingCharacters(in: .whitespacesAndNewlines)
        var calories = caloriesTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let weight = weightTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if validation(calories: calories!, weight: weight!) {
            calories = calories?.replacingOccurrences(of: " calories", with: "")
            
            if comment == "Workout Comment" {
                comment = "none"
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy h:mm a"
            session._userId = pool?.currentUser()?.username
            session._activityId = NSUUID().uuidString
            session._date = formatter.string(from: date)
            session._location = location
            session._workoutComment = comment
            session._calories = NSNumber(value: Float(calories!)!)
            session._bodyWeight = NSNumber(value: Float(weight!)!)
            goToAddActivityInSession()
        }
    }
    
    @objc func goToAddActivityInSession() {
        let storyboard = UIStoryboard(name: "AddActivityInSession", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "AddActivityInSessionVC") as! AddActivityInSessionVC
        destVC.session = session
        self.present(destVC, animated: true, completion: .none)
    }
    
    @objc func goToCalendarVC() {
        let storyboard = UIStoryboard(name: "AddSession", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "CalendarVC") as! CalendarVC
        destVC.date = date
        self.present(destVC, animated: true, completion: .none)
    }
    
    @objc func back() {
        self.dismiss(animated: true, completion: nil)
    }


}
