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
import AWSCognitoIdentityProvider

class ExerciseDetailsVC: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var addToFavoritesButton: UIButton!
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
    var pool: AWSCognitoIdentityUserPool?
    var exerciseArray: [Exercise] = []
    var favoritesArray: [Exercise] = []
    var favoritesDictionary: [[String: Any]] = []
    let numberArray = [Int](1...1000)
    let hourArray = [Int](0...12)
    let minArray = [Int](0...59)
    let typeArray = ["Weight", "Count", "Time", "Distance"]
    var favoriteExercise: Exercise = Exercise()
    let weightUnit = "lbs"
    let distanceUnit = "miles"
    let hourUnit = "hour"
    let minUnit = "min"
    var exerciseID = ""
    var session: Activity = Activity()
    var exerciseDictionary: Dictionary = [String: Any]()
    var oldActivity: Activity = Activity()
    var oldExercise: ExerciseItem = ExerciseItem()

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
        
        if textField == timeTF {
            picker.selectRow(0, inComponent: 0, animated: false)
            picker.selectRow(0, inComponent: 1, animated: false)
        }
        else {
            picker.selectRow(0, inComponent: 0, animated: false)
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
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
                return favoritesArray.count
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
                return favoritesArray[row]._name
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
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissVC))
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(tap)
        
        addToFavoritesButton.addTarget(self, action: #selector(addToFavorites), for: .touchUpInside)
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
                    self.exerciseArray.sort{ ($0._name! < $1._name!) }
                    print(exercise.value(forKey: "_exerciseId")!)
                    print(exercise.value(forKey: "_name")!)
                    
                }
            }
            DispatchQueue.main.async {
                self.hideHUD(hud: self.hud!)
                self.picker.reloadComponent(0)
                self.getFavorites()
            }
            return()
        })
    }
    
    func createFavorite() {
        var store: Dictionary = [String: Any]()
        let favorites = Favorites()
        store["ID"] = self.favoriteExercise._exerciseId
        store["Name"] = self.favoriteExercise._name
        favoritesDictionary.append(store)
        favorites?._userId = (self.pool?.currentUser()?.username)!
        favorites?._exerciseList = favoritesDictionary
        favorites?.createFavorite(favoriteItem: favorites!, completion: { (response) in
            DispatchQueue.main.async {
                if response == "success" {
                    self.showSuccessHUD(text: "Added to Favorites")
                    self.addToFavoritesButton.setImage(UIImage(named: "Favorite"), for: .normal)
                    let exerciseItem = Exercise()
                    exerciseItem?._exerciseId = self.favoriteExercise._exerciseId
                    exerciseItem?._name = self.favoriteExercise._name
                    self.favoritesArray.append(exerciseItem!)
                    self.picker.reloadComponent(0)
                }
                else {
                    self.showErrorHUD(text: "Couldn't add to Favorites")
                }
            }
        })
    }
    
    func getFavorites() {
        self.showHUD(hud: hud!)
        let favorites = Favorites()
        favorites?.queryFavorites(userId: (pool?.currentUser()?.username)!, completion: { (response, responseArray) in
            
            DispatchQueue.main.async {
                self.hideHUD(hud: self.hud!)
                
                if response == "success" {
                    self.favoritesDictionary = responseArray
                    
                    for value in (self.favoritesDictionary) {
                        print(value["ID"]!)
                        let exerciseID = value["ID"]
                        let exerciseName = value["Name"]
                        let exerciseItem = Exercise()
                        exerciseItem?._exerciseId = NSNumber(value: Int("\(exerciseID!)")!)
                        exerciseItem?._name = "\(exerciseName!)"
                        self.favoritesArray.append(exerciseItem!)
                    }
                    self.picker.reloadComponent(0)
                }
                
                if self.oldExercise.exerciseID.count > 0 {
                    self.exerciseListTF.text = self.oldExercise.exerciseName
                    self.exerciseID = self.oldExercise.exerciseID
                    
                    if self.oldExercise.exerciseComment.count > 0 {
                        if self.oldExercise.exerciseComment != "none" {
                            self.commentTV.textColor = UIColor.black
                            self.commentTV.text = self.oldExercise.exerciseComment
                        }
                    }
                    
                    if self.oldExercise.exerciseWeightAmount != 0 {
                        self.exerciseTypeTF.text = "Weight"
                        self.weightAmountTF.text = "\(self.oldExercise.exerciseWeightAmount)" + " lbs"
                        self.repsTF.text = "\(self.oldExercise.exerciseReps)" + " reps"
                        self.setsTF.text = "\(self.oldExercise.exerciseSets)" + " sets"
                    }
                    else if self.oldExercise.exerciseCount != 0 {
                        self.exerciseTypeTF.text = "Count"
                        self.countTF.text = "\(self.oldExercise.exerciseCount)" + " counts"
                    }
                    else if self.oldExercise.exerciseTime != 0 {
                        self.exerciseTypeTF.text = "Time"
                        let hours = self.oldExercise.exerciseTime / 3600
                        let minutes = (self.oldExercise.exerciseTime / 60) % 60
                        self.timeTF.text = String(format: "%02d:%02d", hours, minutes)
                    }
                    else if self.oldExercise.exerciseDistance != 0 {
                        self.exerciseTypeTF.text = "Distance"
                        self.distanceTF.text = "\(self.oldExercise.exerciseDistance)" + " miles"
                    }
                    
                    let exercise = Exercise()
                    exercise?._exerciseId = NSNumber(value: Int((self.oldExercise.exerciseID))!)
                    exercise?._name = self.oldExercise.exerciseName
                    if self.favoritesArray.contains(exercise!) {
                        self.addToFavoritesButton.setImage(UIImage(named: "Favorite"), for: .normal)
                    }
                    else {
                        self.addToFavoritesButton.setImage(UIImage(named: "Favorite Gray"), for: .normal)
                    }
                }
            }
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
            favoriteExercise = exerciseArray[picker.selectedRow(inComponent: 0)]
            exerciseListTF.text = exerciseArray[picker.selectedRow(inComponent: 0)]._name
            exerciseID = "\(exerciseArray[picker.selectedRow(inComponent: 0)]._exerciseId!)"
            if favoritesListTF.text!.count > 0 {
                favoritesListTF.text = ""
            }
            
            if exerciseListTF.text!.count > 0 {
                
                if favoritesArray.contains(favoriteExercise) {
                    addToFavoritesButton.setImage(UIImage(named: "Favorite"), for: .normal)
                }
                else {
                    addToFavoritesButton.setImage(UIImage(named: "Favorite Gray"), for: .normal)
                }
            }
            else {
                addToFavoritesButton.setImage(UIImage(named: "List"), for: .normal)
            }
            
            exerciseTypeTF.perform(
                #selector(becomeFirstResponder),
                with: nil,
                afterDelay: 0.1
            )
        }
        else if activeField == favoritesListTF {
            favoritesListTF.text = favoritesArray[picker.selectedRow(inComponent: 0)]._name
            exerciseID = "\(favoritesArray[picker.selectedRow(inComponent: 0)]._exerciseId!)"
            if exerciseListTF.text!.count > 0 {
                exerciseListTF.text = ""
                self.addToFavoritesButton.setImage(UIImage(named: "List"), for: .normal)
            }
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
                
                if countTF.text!.count > 0 {
                    countTF.text = ""
                }
                if timeTF.text!.count > 0 {
                    timeTF.text = ""
                }
                if distanceTF.text!.count > 0 {
                    distanceTF.text = ""
                }
                
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
                
                if weightAmountTF.text!.count > 0 {
                    weightAmountTF.text = ""
                }
                if setsTF.text!.count > 0 {
                    setsTF.text = ""
                }
                if repsTF.text!.count > 0 {
                    repsTF.text = ""
                }
                if timeTF.text!.count > 0 {
                    timeTF.text = ""
                }
                if distanceTF.text!.count > 0 {
                    distanceTF.text = ""
                }
                
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
                
                if weightAmountTF.text!.count > 0 {
                    weightAmountTF.text = ""
                }
                if setsTF.text!.count > 0 {
                    setsTF.text = ""
                }
                if repsTF.text!.count > 0 {
                    repsTF.text = ""
                }
                if countTF.text!.count > 0 {
                    countTF.text = ""
                }
                if distanceTF.text!.count > 0 {
                    distanceTF.text = ""
                }
                
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
                
                if weightAmountTF.text!.count > 0 {
                    weightAmountTF.text = ""
                }
                if setsTF.text!.count > 0 {
                    setsTF.text = ""
                }
                if repsTF.text!.count > 0 {
                    repsTF.text = ""
                }
                if countTF.text!.count > 0 {
                    countTF.text = ""
                }
                if timeTF.text!.count > 0 {
                    timeTF.text = ""
                }
                
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
            repsTF.text = "\(numberArray[picker.selectedRow(inComponent: 0)])" + " reps"
            setsTF.perform(
                #selector(becomeFirstResponder),
                with: nil,
                afterDelay: 0.1
            )
        }
        else if activeField == setsTF {
            setsTF.text = "\(numberArray[picker.selectedRow(inComponent: 0)])" + " sets"
            commentTV.perform(
                #selector(becomeFirstResponder),
                with: nil,
                afterDelay: 0.1
            )
        }
        else if activeField == countTF {
            countTF.text = "\(numberArray[picker.selectedRow(inComponent: 0)])" + " counts"
            commentTV.perform(
                #selector(becomeFirstResponder),
                with: nil,
                afterDelay: 0.1
            )
        }
        else if activeField == timeTF {
            let hours = hourArray[picker.selectedRow(inComponent: 0)]
            let minutes = minArray[picker.selectedRow(inComponent: 2)]
            let time = String(format: "%02d:%02d", hours, minutes)
            timeTF.text = time
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
    
    @objc func addToFavorites() {
        let favorites = Favorites()
        
        if addToFavoritesButton.currentImage == UIImage(named: "Favorite Gray") {
            self.showHUD(hud: hud!)
            favorites?.queryFavorites(userId: (pool?.currentUser()?.username)!, completion: { (response, responseArray) in
                
                DispatchQueue.main.async {
                    self.hideHUD(hud: self.hud!)
                    
                    if response == "success" {
                        self.favoritesDictionary = responseArray
                        self.createFavorite()
                    }
                    else {
                        self.createFavorite()
                    }
                }
            })
        }
        else {
            
        }
    }
    
    @objc func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func validation(type: String, weight: String, reps: String, sets: String, count: String, time: String, distance: String) -> Bool {
        
        if exerciseID.count > 0 {
        
            if type == "Weight" {
                
                if weight.count > 0 && reps.count > 0 && sets.count > 0 {
                    return true
                }
                self.showErrorHUD(text: "Please fill the weight, reps and sets fields")
                return false
            }
            else if type == "Count" {
                
                if count.count > 0 {
                    return true
                }
                self.showErrorHUD(text: "Please fill the count field")
                return false
            }
            else if type == "Time" {
                
                if time.count > 0 {
                    return true
                }
                self.showErrorHUD(text: "Please fill the time field")
                return false
            }
            else if type == "Distance" {
                
                if distance.count > 0 {
                    return true
                }
                self.showErrorHUD(text: "Please fill the distance field")
                return false
            }
            else {
                self.showErrorHUD(text: "Please choose an activity type")
                return false
            }
        }
        else {
            self.showErrorHUD(text: "Please fill the required fields")
            return false
        }
    }

    @objc func addActivityInSession() {
        let type = exerciseTypeTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let weightAmount = weightAmountTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let reps = repsTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let sets = setsTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let count = countTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let time = timeTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let distance = distanceTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let comment = commentTV.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        if validation(type: type!, weight: weightAmount!, reps: reps!, sets: sets!, count: count!, time: time!, distance: distance!) {
            let index = exerciseArray.index(where: { $0._exerciseId?.stringValue == exerciseID })
            
            exerciseDictionary["exerciseID"] = exerciseID
            exerciseDictionary["exerciseName"] = exerciseArray[index!]._name
            
            if weightAmount!.count > 0 {
                exerciseDictionary["Weight Amount"] = weightAmount?.replacingOccurrences(of: " lbs", with: "")
                
                if reps!.count > 0 {
                    exerciseDictionary["Reps"] = reps?.replacingOccurrences(of: " reps", with: "")
                }
                if sets!.count > 0 {
                    exerciseDictionary["Sets"] = sets?.replacingOccurrences(of: " sets", with: "")
                }
            }
            else if count!.count > 0 {
                exerciseDictionary["Count"] = count?.replacingOccurrences(of: " counts", with: "")
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
            
            if oldExercise.exerciseID.count > 0 {
                var exerciseList = self.oldActivity._exerciseList
                
                for (key, value) in (exerciseList?.enumerated())! {
                    
                    if value["exerciseID"] as? String == oldExercise.exerciseID && value["exerciseName"] as? String == oldExercise.exerciseName {
                        print("Before: ", exerciseList![key])
                        
                        if oldExercise.exerciseWeightAmount != 0 {
                            if value["Weight Amount"] != nil {
                                if Int((value["Weight Amount"] as? String)!) == oldExercise.exerciseWeightAmount {
                                    exerciseList![key] = exerciseDictionary
                                }
                            }
                        }
                        else if oldExercise.exerciseCount != 0 {
                            if value["Count"] != nil {
                                if Int((value["Count"] as? String)!) == oldExercise.exerciseCount {
                                    exerciseList![key] = exerciseDictionary
                                }
                            }
                            print("After: ", exerciseList![key])
                        }
                        else if oldExercise.exerciseTime != 0 {
                            if value["Time"] != nil {
                                if (value["Time"] as? Int)! == oldExercise.exerciseTime {
                                    exerciseList![key] = exerciseDictionary
                                }
                            }
                            print("After: ", exerciseList![key])
                        }
                        else if oldExercise.exerciseDistance != 0 {
                            if value["Distance"] != nil {
                                if Int((value["Distance"] as? String)!) == oldExercise.exerciseDistance {
                                    exerciseList![key] = exerciseDictionary
                                }
                            }
                        }
                        self.oldActivity._exerciseList = exerciseList
                        self.showHUD(hud: self.hud!)
                        self.oldActivity.createActivity(activityItem: self.oldActivity, completion: { (response) in
                            DispatchQueue.main.async {
                                self.hideHUD(hud: self.hud!)
                                if response == "success" {
                                    self.showSuccessHUD(text: "Activity updated")
                                    NotificationCenter.default.post(name: .updateExercise, object: nil)
                                }
                                else {
                                    self.showErrorHUD(text: response)
                                }
                            }
                            
                        })
                        
                        return
                    }
                    else {
                        print("This value is not equal: ", value)
                        //print("ID: ", value["exerciseID"])
                    }
                    
                }
            }
            else {
                NotificationCenter.default.post(name: .updateActivityTV, object: nil)
                self.dismiss(animated: true, completion: nil)
            }
        }
        else {
           // self.showErrorHUD(text: "Please fill the required fields")
        }
    }

}
