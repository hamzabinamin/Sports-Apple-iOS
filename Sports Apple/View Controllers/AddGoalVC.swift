//
//  AddGoalVC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 6/6/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit
import JGProgressHUD
import AWSDynamoDB
import AWSCognitoIdentityProvider

class AddGoalVC: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
  
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var exerciseListTF: UITextField!
    @IBOutlet weak var favoritesListTF: UITextField!
    @IBOutlet weak var goalTypeTF: UITextField!
    @IBOutlet weak var goalAmountTF: UITextField!
    @IBOutlet weak var yearlyGoalTF: UITextField!
    @IBOutlet weak var backView: UIView!
    var hud: JGProgressHUD?
    var activeField: UITextField?
    let picker = UIPickerView()
    var pool: AWSCognitoIdentityUserPool?
    var exerciseArray: [Exercise] = []
    let numberArray = [Int](1...50000)
    let hourArray = [Int](0...12)
    let minArray = [Int](0...60)
    let goalTypeArray: [String] = ["Weight Goal", "Distance Goal", "Time Goal", "Calories Goal"]
    let yearlyGoalArray: [String] = ["Yes", "No"]
    let weightUnit = "lbs"
    let distanceUnit = "miles"
    let caloriesUnit = "calories"
    let hourUnit = "hour"
    let minUnit = "min"
    var exerciseID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setupViews()
        setupPicker()
        self.showHUD(hud: hud!)
        getExercises()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        picker.reloadAllComponents()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        if activeField == goalAmountTF {
            let type = goalTypeTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if type == "Time Goal" {
                return 4
            }
            else if type == "Distance Goal" {
                return 2
            }
            else if type == "Weight Goal" {
                return 2
            }
            else if type == "Calories Goal" {
              return 2
            }
            
        }
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if activeField == goalAmountTF {
            let type = goalTypeTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if type == "Time Goal" {
                if component == 0 {
                    return String(hourArray[row])
                }
                else if component == 1 {
                    return hourUnit
                }
                else if component == 2 {
                    return String(minArray[row])
                }
                else if component == 3 {
                    return minUnit
                }
            }
            else if type == "Distance Goal" {
                if component == 0 {
                    return String(numberArray[row])
                }
                else if component == 1 {
                    return distanceUnit
                }
            }
             else if type == "Weight Goal" {
                if component == 0 {
                    return String(numberArray[row])
                }
                else if component == 1 {
                    return weightUnit
                }
            }
            else if type == "Calories Goal" {
                if component == 0 {
                    return String(numberArray[row])
                }
                else if component == 1 {
                    return caloriesUnit
                }
            }
        }
        if activeField == exerciseListTF {
            return exerciseArray[row]._name
        }
        else if activeField == favoritesListTF {
            return exerciseArray[row]._name
        }
        else if activeField == goalTypeTF {
            return goalTypeArray[row]
        }
        else if activeField == yearlyGoalTF {
            return yearlyGoalArray[row]
        }
        return ""
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if activeField == goalAmountTF {
            let type = goalTypeTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if type == "Time Goal" {
                if component == 0 {
                    return hourArray.count
                }
                else if component == 1 {
                    return 1
                }
                else if component == 2 {
                    return minArray.count
                }
                else if component == 3 {
                    return 1
                }
            }
            else if type == "Distance Goal" {
                if component == 0 {
                    return numberArray.count
                }
                else if component == 1 {
                    return 1
                }
            }
            else if type == "Weight Goal" {
                if component == 0 {
                    return numberArray.count
                }
                else if component == 1 {
                    return 1
                }
            }
            else if type == "Calories Goal" {
                if component == 0 {
                    return numberArray.count
                }
                else if component == 1 {
                    return 1
                }
            }
        }
        else {
            if component == 0 {
                if activeField == exerciseListTF {
                    return exerciseArray.count
                }
                else if activeField == favoritesListTF {
                    return exerciseArray.count
                }
                else if activeField == goalTypeTF {
                    return goalTypeArray.count
                }
                else if activeField == yearlyGoalTF {
                    return yearlyGoalArray.count
                }
            }
        }
        return 0
    }

    func setupViews() {
        self.hideKeyboardWhenTappedAround()
        self.hud = self.createLoadingHUD()
        exerciseListTF.delegate = self
        favoritesListTF.delegate = self
        goalTypeTF.delegate = self
        goalAmountTF.delegate = self
        yearlyGoalTF.delegate = self
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
        self.exerciseListTF.delegate = self
        self.favoritesListTF.delegate = self
        self.goalTypeTF.delegate = self
        completeButton.layer.cornerRadius = 18
        exerciseListTF.addPadding(.left(35))
        favoritesListTF.addPadding(.left(35))
        goalTypeTF.addPadding(.left(35))
        goalAmountTF.addPadding(.left(35))
        yearlyGoalTF.addPadding(.left(35))
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(tap)
        completeButton.addTarget(self, action: #selector(addGoal), for: .touchUpInside)
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
        
        exerciseListTF.inputView = picker
        exerciseListTF.inputAccessoryView = toolBar
        favoritesListTF.inputView = picker
        favoritesListTF.inputAccessoryView = toolBar
        goalTypeTF.inputView = picker
        goalTypeTF.inputAccessoryView = toolBar
        goalAmountTF.inputView = picker
        goalAmountTF.inputAccessoryView = toolBar
        yearlyGoalTF.inputView = picker
        yearlyGoalTF.inputAccessoryView = toolBar
    }
    
    func getExercises() {
        let scanExpression = AWSDynamoDBScanExpression()
        scanExpression.limit = 500
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        dynamoDbObjectMapper.scan(Exercise.self, expression: scanExpression).continueWith(block: { (task:AWSTask<AWSDynamoDBPaginatedOutput>!) -> Any? in
            if let error = task.error as NSError? {
                print("The request failed. Error: \(error)")
            } else if let paginatedOutput = task.result {
                for exercise in paginatedOutput.items {
                    let store = Exercise()
                    let id = exercise.value(forKey: "_exerciseId")! as! NSNumber
                    let name = exercise.value(forKey: "_name")! as! String
                    store?._exerciseId = id
                    store?._name = name
                    self.exerciseArray.append(store!)
                    print(exercise.value(forKey: "_exerciseId")!)
                    print(exercise.value(forKey: "_name")!)
                    
                }
            }
            DispatchQueue.main.async {
                self.hideHUD(hud: self.hud!)
                self.picker.reloadComponent(0)
            }
            return()
        })
    }
    
    func validation(type: String, amount: String, yearlyGoal: String) -> Bool {
        
        if exerciseID.count > 0 && type.count > 0 && amount.count > 0 && yearlyGoal.count > 0 {
            
            return true
        }
        self.showErrorHUD(text: "Please fill the required fields")
        return false
    }
    
    func clearFields() {
        self.exerciseListTF.text = ""
        self.favoritesListTF.text = ""
        self.goalTypeTF.text = ""
        self.goalAmountTF.text = ""
        self.yearlyGoalTF.text = ""
    }
    
    @objc func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func donePicker() {
        if activeField == exerciseListTF {
            exerciseListTF.text = exerciseArray[picker.selectedRow(inComponent: 0)]._name
            exerciseID = "\(exerciseArray[picker.selectedRow(inComponent: 0)]._exerciseId!)"
            goalTypeTF.perform(
                #selector(becomeFirstResponder),
                with: nil,
                afterDelay: 0.1
            )
        }
        else if activeField == favoritesListTF {
            favoritesListTF.text = exerciseArray[picker.selectedRow(inComponent: 0)]._name
            exerciseID = "\(exerciseArray[picker.selectedRow(inComponent: 0)]._exerciseId!)"
            exerciseListTF.isEnabled = false
            exerciseListTF.alpha = 0.5
            goalTypeTF.perform(
                #selector(becomeFirstResponder),
                with: nil,
                afterDelay: 0.1
            )
        }
        else if activeField == goalTypeTF {
            goalTypeTF.text = goalTypeArray[picker.selectedRow(inComponent: 0)]
            goalAmountTF.perform(
                #selector(becomeFirstResponder),
                with: nil,
                afterDelay: 0.1
            )
        }
        else if activeField == goalAmountTF {
            let type = goalTypeTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if type == "Time Goal" {
                goalAmountTF.text = "\(hourArray[picker.selectedRow(inComponent: 0)])" + ":" + "\(minArray[picker.selectedRow(inComponent: 2)])"
            }
            else if type == "Distance Goal" {
            goalAmountTF.text = "\(numberArray[picker.selectedRow(inComponent: 0)])" + " " + distanceUnit
            }
            else if type == "Weight Goal" {
                goalAmountTF.text = "\(numberArray[picker.selectedRow(inComponent: 0)])" + " " + weightUnit
            }
            else if type == "Calories Goal" {
                goalAmountTF.text = "\(numberArray[picker.selectedRow(inComponent: 0)])" + " " + caloriesUnit
            }
            yearlyGoalTF.perform(
                #selector(becomeFirstResponder),
                with: nil,
                afterDelay: 0.1
            )
        }
        else if activeField == yearlyGoalTF {
            yearlyGoalTF.text = yearlyGoalArray[picker.selectedRow(inComponent: 0)]
        }
        self.view.endEditing(true)
    }
    
    @objc func cancelPicker(){
        self.view.endEditing(true)
    }
    
    @objc func addGoal() {
        let type = goalTypeTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let amount = goalAmountTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let yearlyGoal = yearlyGoalTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if validation(type: type!, amount: amount!, yearlyGoal: yearlyGoal!) {
            self.showHUD(hud: hud!)
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy h:mm a"
            let goalItem: Goal = Goal()
            goalItem._exerciseId = exerciseID
            
            if type == "Time Goal" {
                let store = amount?.split(separator: ":")
                let hours = Int(store![0])
                let minutes = Int(store![1])
                let seconds = (hours! * 60 * 60) + (minutes! * 60)
                goalItem._time = NSNumber(value: seconds)
            }
            else if type == "Distance Goal" {
                let distanceS = amount?.replacingOccurrences(of: " miles", with: "")
                let distance = Int(distanceS!)
                goalItem._distance = NSNumber(value: distance!)
            }
            else if type == "Weight Goal" {
                let weightS = amount?.replacingOccurrences(of: " lbs", with: "")
                let weight = Int(weightS!)
                goalItem._weight = NSNumber(value: weight!)
            }
            else if type == "Calories Goal" {
                let caloriesS = amount?.replacingOccurrences(of: " calories", with: "")
                let calories = Int(caloriesS!)
                goalItem._calories = NSNumber(value: calories!)
            }
            
            goalItem._yearlyGoal = yearlyGoal
            goalItem._userId = pool?.currentUser()?.username
            goalItem._goalId = NSUUID().uuidString
            goalItem._date = formatter.string(from: Date())
            goalItem.createGoal(goalItem: goalItem, completion: { (response) in
                
                DispatchQueue.main.async {
                    self.hideHUD(hud: self.hud!)
                }
                
                if response == "success" {
                   DispatchQueue.main.async {
                        self.clearFields()
                        self.showSuccessHUD(text: response)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        self.showErrorHUD(text: response)
                    }
                }
            })
        }
     }

}
