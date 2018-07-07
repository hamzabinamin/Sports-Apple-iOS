//
//  ExerciseDetailsPopupVC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 6/5/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit
import JGProgressHUD
import AWSDynamoDB

class ExerciseDetailsVC: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var exerciseListTF: UITextField!
    @IBOutlet weak var favoritesListTF: UITextField!
    @IBOutlet weak var exerciseTypeTF: UITextField!
    @IBOutlet weak var weightAmountTF: UITextField!
    @IBOutlet weak var setsTF: UITextField!
    @IBOutlet weak var repsTF: UITextField!
    @IBOutlet weak var countTF: UITextField!
    @IBOutlet weak var timeTF: UITextField!
    @IBOutlet weak var distanceTF: UITextField!
    @IBOutlet weak var commentTV: UITextView!
    @IBOutlet weak var backView: UIView!
    var hud: JGProgressHUD?
    var activeField: UITextField?
    let picker = UIPickerView()
    var exerciseArray: [Exercise] = []
    let numberArray = [Int](1...1000)
    let hourArray = [Int](0...12)
    let minArray = [Int](0...60)
    let typeArray = ["Weight", "Count", "Time", "Distance"]
    let weightUnit = "lbs"
    let distanceUnit = "miles"
    let hourUnit = "hour"
    let minUnit = "min"
    var exerciseID = ""
    var session: Activity = Activity()
    var exerciseDictionary: Dictionary = [String: Any]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupPicker()
        setupTextView()
        setupButtonAndTextFields()
        
        completeButton.addTarget(self, action: #selector(addActivityInSession), for: .touchUpInside)
        
        self.showHUD(hud: hud!)
        getExercises()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        picker.reloadAllComponents()
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.init(hex: "#c7c7cd") {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Exercise Comment"
            textView.textColor = UIColor.init(hex: "#c7c7cd")
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        if activeField == weightAmountTF || activeField == distanceTF {
            return 2
        }
        else if activeField == timeTF {
            return 4
        }
        else {
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if activeField == weightAmountTF || activeField == distanceTF {
            if component == 0 {
                return numberArray.count
            }
            else if component == 1 {
                return 1
            }
        }
        else if activeField == timeTF {
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
        else {
            if activeField == exerciseListTF {
                return exerciseArray.count
            }
            else if activeField == favoritesListTF {
                return exerciseArray.count
            }
            else if activeField == exerciseTypeTF {
                return typeArray.count
            }
            else {
                return numberArray.count
            }
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if activeField == weightAmountTF || activeField == distanceTF {
            if component == 0 {
                return String(numberArray[row])
            }
            else if component == 1 {
                
                if activeField == weightAmountTF {
                    return weightUnit
                }
                else {
                    return distanceUnit
                }
            }
        }
        else if activeField == timeTF {
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
        else {
            if activeField == exerciseListTF {
                return exerciseArray[row]._name
            }
            else if activeField == favoritesListTF {
                return exerciseArray[row]._name
            }
            else if activeField == exerciseTypeTF {
                return typeArray[row]
            }
            else {
                return String(numberArray[row])
            }
        }
        return ""
    }
    
    func setupViews() {
        self.hideKeyboardWhenTappedAround()
        self.hud = self.createLoadingHUD()
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissVC))
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(tap)
    }
    
    func setupTextView() {
        commentTV.delegate = self
        commentTV.text = "Exercise Comment"
        commentTV.textColor = UIColor.init(hex: "#c7c7cd")
    }
    
    func setupButtonAndTextFields() {
        completeButton.layer.cornerRadius = 18
        exerciseListTF.delegate = self
        favoritesListTF.delegate = self
        exerciseTypeTF.delegate = self
        weightAmountTF.delegate = self
        repsTF.delegate = self
        setsTF.delegate = self
        countTF.delegate = self
        timeTF.delegate = self
        distanceTF.delegate = self
        exerciseListTF.addPadding(.left(35))
        favoritesListTF.addPadding(.left(35))
        exerciseTypeTF.addPadding(.left(35))
        weightAmountTF.addPadding(.left(35))
        setsTF.addPadding(.left(35))
        repsTF.addPadding(.left(35))
        countTF.addPadding(.left(35))
        timeTF.addPadding(.left(35))
        distanceTF.addPadding(.left(35))
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
        exerciseTypeTF.inputView = picker
        exerciseTypeTF.inputAccessoryView = toolBar
        weightAmountTF.inputView = picker
        weightAmountTF.inputAccessoryView = toolBar
        repsTF.inputView = picker
        repsTF.inputAccessoryView = toolBar
        setsTF.inputView = picker
        setsTF.inputAccessoryView = toolBar
        countTF.inputView = picker
        countTF.inputAccessoryView = toolBar
        timeTF.inputView = picker
        timeTF.inputAccessoryView = toolBar
        distanceTF.inputView = picker
        distanceTF.inputAccessoryView = toolBar
    }
    
    @objc func donePicker() {
        
        if activeField == exerciseListTF {
            exerciseListTF.text = exerciseArray[picker.selectedRow(inComponent: 0)]._name
            exerciseID = "\(exerciseArray[picker.selectedRow(inComponent: 0)]._exerciseId!)"
            exerciseTypeTF.perform(
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
            exerciseTypeTF.perform(
                #selector(becomeFirstResponder),
                with: nil,
                afterDelay: 0.1
            )
        }
        else if activeField == exerciseTypeTF {
            let type = typeArray[picker.selectedRow(inComponent: 0)]
            exerciseTypeTF.text = type
            
            if type == "Weight" {
                weightAmountTF.isEnabled = true
                weightAmountTF.alpha = 1
                setsTF.isEnabled = true
                setsTF.alpha = 1
                repsTF.isEnabled = true
                repsTF.alpha = 1
                
                countTF.isEnabled = false
                countTF.alpha = 0.5
                timeTF.isEnabled = false
                timeTF.alpha = 0.5
                distanceTF.isEnabled = false
                distanceTF.alpha = 0.5
                
                weightAmountTF.perform(
                    #selector(becomeFirstResponder),
                    with: nil,
                    afterDelay: 0.1
                )
            }
            else if type == "Count" {
                countTF.isEnabled = true
                countTF.alpha = 1
                
                weightAmountTF.isEnabled = false
                weightAmountTF.alpha = 0.5
                setsTF.isEnabled = false
                setsTF.alpha = 0.5
                repsTF.isEnabled = false
                repsTF.alpha = 0.5
                timeTF.isEnabled = false
                timeTF.alpha = 0.5
                distanceTF.isEnabled = false
                distanceTF.alpha = 0.5
                
                countTF.perform(
                    #selector(becomeFirstResponder),
                    with: nil,
                    afterDelay: 0.1
                )
            }
            else if type == "Time" {
                timeTF.isEnabled = true
                timeTF.alpha = 1
                
                weightAmountTF.isEnabled = false
                weightAmountTF.alpha = 0.5
                setsTF.isEnabled = false
                setsTF.alpha = 0.5
                repsTF.isEnabled = false
                repsTF.alpha = 0.5
                countTF.isEnabled = false
                countTF.alpha = 0.5
                distanceTF.isEnabled = false
                distanceTF.alpha = 0.5
                
                timeTF.perform(
                    #selector(becomeFirstResponder),
                    with: nil,
                    afterDelay: 0.1
                )
            }
            else if type == "Distance" {
                distanceTF.isEnabled = true
                distanceTF.alpha = 1
                
                weightAmountTF.isEnabled = false
                weightAmountTF.alpha = 0.5
                setsTF.isEnabled = false
                setsTF.alpha = 0.5
                repsTF.isEnabled = false
                repsTF.alpha = 0.5
                countTF.isEnabled = false
                countTF.alpha = 0.5
                timeTF.isEnabled = false
                timeTF.alpha = 0.5
                
                distanceTF.perform(
                    #selector(becomeFirstResponder),
                    with: nil,
                    afterDelay: 0.1
                )
            }
        }
        else if activeField == weightAmountTF {
            weightAmountTF.text = "\(numberArray[picker.selectedRow(inComponent: 0)])" + " lbs"
            repsTF.perform(
                #selector(becomeFirstResponder),
                with: nil,
                afterDelay: 0.1
            )
        }
        else if activeField == repsTF {
            repsTF.text = "\(numberArray[picker.selectedRow(inComponent: 0)])"
            setsTF.perform(
                #selector(becomeFirstResponder),
                with: nil,
                afterDelay: 0.1
            )
        }
        else if activeField == setsTF {
            setsTF.text = "\(numberArray[picker.selectedRow(inComponent: 0)])"
            commentTV.perform(
                #selector(becomeFirstResponder),
                with: nil,
                afterDelay: 0.1
            )
        }
        else if activeField == countTF {
            countTF.text = "\(numberArray[picker.selectedRow(inComponent: 0)])"
            commentTV.perform(
                #selector(becomeFirstResponder),
                with: nil,
                afterDelay: 0.1
            )
        }
        else if activeField == timeTF {
            timeTF.text = "\(hourArray[picker.selectedRow(inComponent: 0)])" + ":" + "\(minArray[picker.selectedRow(inComponent: 2)])"
            commentTV.perform(
                #selector(becomeFirstResponder),
                with: nil,
                afterDelay: 0.1
            )
        }
        else if activeField == distanceTF {
            distanceTF.text = "\(numberArray[picker.selectedRow(inComponent: 0)])" + " miles"
            commentTV.perform(
                #selector(becomeFirstResponder),
                with: nil,
                afterDelay: 0.1
            )
        }
        
        self.view.endEditing(true)
    }
    
    @objc func cancelPicker(){
        self.view.endEditing(true)
    }
    
    @objc func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func addActivityInSession() {
        let weightAmount = weightAmountTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let reps = repsTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let sets = setsTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let count = countTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let time = timeTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let distance = distanceTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let comment = commentTV.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if exerciseID.count > 0 {
            let index = exerciseArray.index(where: { $0._exerciseId?.stringValue == exerciseID })
            
            
            exerciseDictionary["exerciseID"] = exerciseID
            exerciseDictionary["exerciseName"] = exerciseArray[index!]._name
            
            if weightAmount!.count > 0 {
                exerciseDictionary["Weight Amount"] = weightAmount?.replacingOccurrences(of: " lbs", with: "")
                
                if reps!.count > 0 {
                    exerciseDictionary["Reps"] = reps
                }
                if sets!.count > 0 {
                    exerciseDictionary["Sets"] = sets
                }
            }
            else if count!.count > 0 {
                exerciseDictionary["Count"] = count
            }
            else if time!.count > 0 {
                let store = time?.split(separator: ":")
                let hours = Int(store![0])
                let minutes = Int(store![1])
                let seconds = (hours! * 60 * 60) + (minutes! * 60)
                exerciseDictionary["Time"] = seconds
            }
            else if distance!.count > 0 {
                exerciseDictionary["Distance"] = distance?.replacingOccurrences(of: " miles", with: "")
            }

            if comment == "Exercise Comment" {
                exerciseDictionary["Exercise Comment"] = "none"
            }
            else {
                exerciseDictionary["Exercise Comment"] = comment
            }
            
            NotificationCenter.default.post(name: .updateActivityTV, object: exerciseDictionary)
            self.dismiss(animated: true, completion: nil)
        }
        else {
            self.showErrorHUD(text: "Please fill the required fields")
        }
    }

}
