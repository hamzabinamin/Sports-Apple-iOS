//
//  SignUp4VC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 5/27/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit
import AWSUserPoolsSignIn
import JGProgressHUD

class SignUp4VC: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var weightTF: UITextField!
    @IBOutlet weak var chestTF: UITextField!
    @IBOutlet weak var waistTF: UITextField!
    @IBOutlet weak var hipsTF: UITextField!
    @IBOutlet weak var neckTF: UITextField!
    @IBOutlet weak var bicepsTF: UITextField!
    @IBOutlet weak var forearmsTF: UITextField!
    @IBOutlet weak var thighsTF: UITextField!
    @IBOutlet weak var calvesTF: UITextField!
    @IBOutlet weak var wristTF: UITextField!
    var activeField: UITextField?
    let picker = UIPickerView()
    var titleButton: UIBarButtonItem?
    var hud: JGProgressHUD?
    var pool: AWSCognitoIdentityUserPool?
    var user: UserItem = UserItem()
    var sentTo = ""
    let inchesArray = [Int](1...500)
    let inchesDecimalArray = [Int](0...9)
    let inchesSymbol = ["inches"]
    let weightSymbol = "lbs"
    var store: AWSCognitoIdentityUser?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupPicker()
        
        if user.weight.stringValue != "-1" && user.userID.count > 0 {
            weightTF.text = String(format: "%.1f", user.weight.floatValue) + " lbs"
            chestTF.text = String(format: "%.1f", user.chest.floatValue) + " inches"
            waistTF.text = String(format: "%.1f", user.waist.floatValue) + " inches"
            hipsTF.text = String(format: "%.1f", user.hips.floatValue) + " inches"
            neckTF.text = String(format: "%.1f", user.neck.floatValue) + " inches"
            bicepsTF.text = String(format: "%.1f", user.biceps.floatValue) + " inches"
            forearmsTF.text = String(format: "%.1f", user.forearms.floatValue) + " inches"
            thighsTF.text = String(format: "%.1f", user.thighs.floatValue) + " inches"
            calvesTF.text = String(format: "%.1f", user.calves.floatValue) + " inches"
            wristTF.text = String(format: "%.1f", user.wrist.floatValue) + " inches"
            completeButton.setTitle("Update", for: .normal)
        }
        else if user.weight.stringValue != "-1" {
            weightTF.text = String(format: "%.1f", user.weight.floatValue) + " lbs"
            chestTF.text = String(format: "%.1f", user.chest.floatValue) + " inches"
            waistTF.text = String(format: "%.1f", user.waist.floatValue) + " inches"
            hipsTF.text = String(format: "%.1f", user.hips.floatValue) + " inches"
            neckTF.text = String(format: "%.1f", user.neck.floatValue) + " inches"
            bicepsTF.text = String(format: "%.1f", user.biceps.floatValue) + " inches"
            forearmsTF.text = String(format: "%.1f", user.forearms.floatValue) + " inches"
            thighsTF.text = String(format: "%.1f", user.thighs.floatValue) + " inches"
            calvesTF.text = String(format: "%.1f", user.calves.floatValue) + " inches"
            wristTF.text = String(format: "%.1f", user.wrist.floatValue) + " inches"
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        
        if activeField == weightTF {
            titleButton?.title = "Weight"
        }
        else if activeField == chestTF {
            titleButton?.title = "Chest"
        }
        else if activeField == waistTF {
            titleButton?.title = "Waist"
        }
        else if activeField == hipsTF {
            titleButton?.title = "Hips"
        }
        else if activeField == neckTF {
            titleButton?.title = "Neck"
        }
        else if activeField == bicepsTF {
            titleButton?.title = "Biceps"
        }
        else if activeField == forearmsTF {
            titleButton?.title = "Forearms"
        }
        else if activeField == thighsTF {
            titleButton?.title = "Thighs"
        }
        else if activeField == calvesTF {
            titleButton?.title = "Calves"
        }
        else if activeField == wristTF {
            titleButton?.title = "Wrist"
        }
        
        picker.reloadAllComponents()
        picker.selectRow(0, inComponent: 0, animated: false)
        picker.selectRow(0, inComponent: 1, animated: false)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if component == 0 {
            return inchesArray.count
        }
        else if component == 1 {
            return inchesDecimalArray.count
        }
        else if component == 2 {
            return inchesSymbol.count
        }
        return 0
    }
    
   /* func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        
        
        return 0
    } */
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if component == 0 {
            return String(inchesArray[row])
        }
        else if component == 1 {
            return String(inchesDecimalArray[row])
        }
        else if component == 2 {
            if activeField == weightTF {
                return weightSymbol
            }
            else {
                return inchesSymbol[row]
            }
        }
        return ""
    }
    
    
    func setupViews() {
        hideKeyboardWhenTappedAround()
        hud = self.createLoadingHUD()
        self.pool = AWSCognitoIdentityUserPool.init(forKey: AWSCognitoUserPoolsSignInProviderKey)
        completeButton.layer.cornerRadius = 18
        weightTF.delegate = self
        chestTF.delegate = self
        waistTF.delegate = self
        hipsTF.delegate = self
        neckTF.delegate = self
        bicepsTF.delegate = self
        forearmsTF.delegate = self
        thighsTF.delegate = self
        calvesTF.delegate = self
        wristTF.delegate = self
        weightTF.addPadding(.left(35))
        chestTF.addPadding(.left(35))
        waistTF.addPadding(.left(35))
        hipsTF.addPadding(.left(35))
        neckTF.addPadding(.left(35))
        bicepsTF.addPadding(.left(35))
        forearmsTF.addPadding(.left(35))
        thighsTF.addPadding(.left(35))
        calvesTF.addPadding(.left(35))
        wristTF.addPadding(.left(35))
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        completeButton.addTarget(self, action: #selector(signUp), for: .touchUpInside)
    }
    
    func updateUser() {
        let storeUser: User = User()
        self.showHUD(hud: hud!)
        storeUser.createUser(userId: user.userID, firstName: user.firstName, lastName: user.lastName, trainerEmail: user.trainerEmail, biceps: user.biceps, calves: user.calves, chest: user.chest, dOB: user.dOB, forearms: user.forearms, height: user.height, hips: user.hips, location: user.location, neck: user.neck, thighs: user.thighs, waist: user.waist, weight: user.weight, wrist: user.wrist, subscriptionDetails: user.subscriptionDetails, completion: { (response) in
            
            DispatchQueue.main.async {
                self.hideHUD(hud: self.hud!)
                
                if response == "success" {
                    let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
                    self.navigationController!.popToViewController(viewControllers[viewControllers.count - 5], animated: true)
                    NotificationCenter.default.post(name: .profileUpdated, object: nil)
                }
                else {
                    self.showErrorHUD(text: response)
                }
                
            }
            
        })
    }
    
    func validation(weight: String, chest: String, waist: String, hips: String, neck: String, biceps: String, forearms: String, thighs: String, calves: String, wrist: String) -> Bool {
        
        return true
    }
    
    func saveUser(storedUser: UserItem) {
        let user = User()
        //self.showHUD(hud: hud!)
        var subscriptionDetails: Dictionary = [String: String]()
        subscriptionDetails["Type"] = "none"
        subscriptionDetails["Expiration Date"] = "none"
        subscriptionDetails["Subscription Date"] = "none"
        subscriptionDetails["Original Transaction ID"] = "none"
        
        user?.createUser(userId: storedUser.userID, firstName: storedUser.firstName, lastName: storedUser.lastName, trainerEmail: storedUser.trainerEmail, biceps: storedUser.biceps, calves: storedUser.calves, chest: storedUser.chest, dOB: storedUser.dOB, forearms: storedUser.forearms, height: storedUser.height, hips: storedUser.hips, location: storedUser.location, neck: storedUser.neck, thighs: storedUser.thighs, waist: storedUser.waist, weight: storedUser.weight, wrist: storedUser.wrist, subscriptionDetails: subscriptionDetails, completion: { response in
            DispatchQueue.main.async {
                self.hideHUD(hud: self.hud!)
            }
            if response == "success" {
                print("Got here success")
                DispatchQueue.main.async {
                    self.goToVerificationVC()
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
        titleButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: self, action: nil)
        //titleButton?.isEnabled = false
        titleButton?.tintColor = .black
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelPicker))
        
        
        toolBar.setItems([cancelButton, spaceButton, titleButton!, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        weightTF.inputView = picker
        weightTF.inputAccessoryView = toolBar
        chestTF.inputView = picker
        chestTF.inputAccessoryView = toolBar
        waistTF.inputView = picker
        waistTF.inputAccessoryView = toolBar
        hipsTF.inputView = picker
        hipsTF.inputAccessoryView = toolBar
        neckTF.inputView = picker
        neckTF.inputAccessoryView = toolBar
        bicepsTF.inputView = picker
        bicepsTF.inputAccessoryView = toolBar
        forearmsTF.inputView = picker
        forearmsTF.inputAccessoryView = toolBar
        thighsTF.inputView = picker
        thighsTF.inputAccessoryView = toolBar
        calvesTF.inputView = picker
        calvesTF.inputAccessoryView = toolBar
        wristTF.inputView = picker
        wristTF.inputAccessoryView = toolBar
    }
    
    @objc func donePicker() {
        
        if activeField == weightTF {
            weightTF.text = String((inchesArray[picker.selectedRow(inComponent: 0)])) + "." + String((inchesDecimalArray[picker.selectedRow(inComponent: 1)])) + " lbs"
            chestTF.perform(
                #selector(becomeFirstResponder),
                with: nil,
                afterDelay: 0.1
            )
        }
        else if activeField == chestTF {
            chestTF.text = String((inchesArray[picker.selectedRow(inComponent: 0)])) + "." + String((inchesDecimalArray[picker.selectedRow(inComponent: 1)])) + " inches"
            waistTF.perform(
                #selector(becomeFirstResponder),
                with: nil,
                afterDelay: 0.1
            )
        }
        else if activeField == waistTF {
            waistTF.text = String((inchesArray[picker.selectedRow(inComponent: 0)])) + "." + String((inchesDecimalArray[picker.selectedRow(inComponent: 1)])) + " inches"
            hipsTF.perform(
                #selector(becomeFirstResponder),
                with: nil,
                afterDelay: 0.1
            )
        }
        else if activeField == hipsTF {
            hipsTF.text = String((inchesArray[picker.selectedRow(inComponent: 0)])) + "." + String((inchesDecimalArray[picker.selectedRow(inComponent: 1)])) + " inches"
            neckTF.perform(
                #selector(becomeFirstResponder),
                with: nil,
                afterDelay: 0.1
            )
        }
        else if activeField == neckTF {
            neckTF.text = String((inchesArray[picker.selectedRow(inComponent: 0)])) + "." + String((inchesDecimalArray[picker.selectedRow(inComponent: 1)])) + " inches"
            bicepsTF.perform(
                #selector(becomeFirstResponder),
                with: nil,
                afterDelay: 0.1
            )
        }
        else if activeField == bicepsTF {
            bicepsTF.text = String((inchesArray[picker.selectedRow(inComponent: 0)])) + "." + String((inchesDecimalArray[picker.selectedRow(inComponent: 1)])) + " inches"
            forearmsTF.perform(
                #selector(becomeFirstResponder),
                with: nil,
                afterDelay: 0.1
            )
        }
        else if activeField == forearmsTF {
            forearmsTF.text = String((inchesArray[picker.selectedRow(inComponent: 0)])) + "." + String((inchesDecimalArray[picker.selectedRow(inComponent: 1)])) + " inches"
            thighsTF.perform(
                #selector(becomeFirstResponder),
                with: nil,
                afterDelay: 0.1
            )
        }
        else if activeField == thighsTF {
            thighsTF.text = String((inchesArray[picker.selectedRow(inComponent: 0)])) + "." + String((inchesDecimalArray[picker.selectedRow(inComponent: 1)])) + " inches"
            calvesTF.perform(
                #selector(becomeFirstResponder),
                with: nil,
                afterDelay: 0.1
            )
        }
        else if activeField == calvesTF {
            calvesTF.text = String((inchesArray[picker.selectedRow(inComponent: 0)])) + "." + String((inchesDecimalArray[picker.selectedRow(inComponent: 1)])) + " inches"
            wristTF.perform(
                #selector(becomeFirstResponder),
                with: nil,
                afterDelay: 0.1
            )
        }
        else if activeField == wristTF {
            wristTF.text = String((inchesArray[picker.selectedRow(inComponent: 0)])) + "." + String((inchesDecimalArray[picker.selectedRow(inComponent: 1)])) + " inches"
        }
        
        self.view.endEditing(true)
    }
    
    @objc func cancelPicker(){
        self.view.endEditing(true)
    }

    @objc func signUp() {
        print("Sign up called")
        var weight = weightTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        var chest =  chestTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        var waist = waistTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        var hips = hipsTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        var neck = neckTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        var biceps = bicepsTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        var forearms = forearmsTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        var thighs = thighsTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        var calves = calvesTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        var wrist = wristTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = user.email
        let password = user.password
        //let emailAttribute = AWSCognitoIdentityUserAttributeType(name: "email", value: email!)
        
        if validation(weight: weight, chest: chest, waist: waist, hips: hips, neck: neck, biceps: biceps, forearms: forearms, thighs: thighs, calves: calves, wrist: wrist) {
            
            if weight.count == 0 {
                weight = "0 lbs"
            }
            if chest.count == 0 {
                chest = "0 inches"
            }
            if waist.count == 0 {
                waist = "0 inches"
            }
            if hips.count == 0 {
                hips = "0 inches"
            }
            if neck.count == 0 {
                neck = "0 inches"
            }
            if biceps.count == 0 {
                biceps = "0 inches"
            }
            if forearms.count == 0 {
                forearms = "0 inches"
            }
            if thighs.count == 0 {
                thighs = "0 inches"
            }
            if calves.count == 0 {
                calves = "0 inches"
            }
            if wrist.count == 0 {
                wrist = "0 inches"
            }
        
            weight = weight.replacingOccurrences(of: " lbs", with: "")
            chest = chest.replacingOccurrences(of: " inches", with: "")
            waist = waist.replacingOccurrences(of: " inches", with: "")
            hips = hips.replacingOccurrences(of: " inches", with: "")
            neck = neck.replacingOccurrences(of: " inches", with: "")
            biceps = biceps.replacingOccurrences(of: " inches", with: "")
            forearms = forearms.replacingOccurrences(of: " inches", with: "")
            thighs = thighs.replacingOccurrences(of: " inches", with: "")
            calves = calves.replacingOccurrences(of: " inches", with: "")
            wrist = wrist.replacingOccurrences(of: " inches", with: "")
            
            user.weight = NSNumber(value: Float(weight)!)
            user.chest = NSNumber(value: Float(chest)!)
            user.waist = NSNumber(value: Float(waist)!)
            user.hips = NSNumber(value: Float(hips)!)
            user.neck = NSNumber(value: Float(neck)!)
            user.biceps = NSNumber(value: Float(biceps)!)
            user.forearms = NSNumber(value: Float(forearms)!)
            user.thighs = NSNumber(value: Float(thighs)!)
            user.calves = NSNumber(value: Float(calves)!)
            user.wrist = NSNumber(value: Float(wrist)!)
            
            if completeButton.titleLabel?.text == "Update" {
                if user.newPassword.count > 0 {
                    self.showHUD(hud: hud!)
                    self.pool?.currentUser()?.changePassword(user.password, proposedPassword: user.newPassword).continueWith(block: { (response: AWSTask < AWSCognitoIdentityUserChangePasswordResponse>) -> Any? in
                
                        DispatchQueue.main.async {
                            self.hideHUD(hud: self.hud!)
                        }
                        
                        if response.result != nil {
                            print(response.result!.description)
                            self.updateUser()
                        }
                        else {
                            print("Error: ", response.error!.localizedDescription)
                            
                            DispatchQueue.main.async {
                                
                                if response.error!.localizedDescription.contains("The operation couldn’t be completed. (com.amazonaws.AWSCognitoIdentityProviderErrorDomain error 18.)") {
                                    
                                    self.showErrorHUD(text: "Attempt limit exceeded, please try after some time")
                                }
                                else {
                                    self.showErrorHUD(text: "Provided password is incorrect")
                                }
                                
                            }
                        }
                        
                        return nil
                    })
                }
                else {
                    updateUser()
                }
            }
            else {
            self.showHUD(hud: hud!)
            self.pool?.signUp(email, password: password, userAttributes: [], validationData: nil).continueWith {[weak self] (task) -> Any? in
                guard self != nil else { return nil }
                DispatchQueue.main.async(execute: {
                    if let error = task.error as NSError? {
                        DispatchQueue.main.async {
                            self?.hideHUD(hud: (self?.hud!)!)
                            
                        }
                        if error.code == 13 {
                            self?.showErrorHUD(text: "Password must be of 8 or more characters")
                        }
                        else if error.code == 14 {
                            self?.showErrorHUD(text: "Password must contain uppercase, lowercase & numeric characters")
                        }
                        else if error.code == 37 {
                            self?.showErrorHUD(text: "An account with the given email already exists")
                            
                        }
                        
                        print(error.code)
                    } else if let result = task.result  {
                        // handle the case where user has to confirm his identity via email / SMS
                        if (result.user.confirmedStatus != AWSCognitoIdentityUserStatus.confirmed) {
                            print("User not confirmed")
                            //UtilityFunctions.saveUserDefaults(value: (self?.user)!)
                            self?.sentTo = (result.codeDeliveryDetails?.destination)!
                            self?.store = result.user
                            self?.user.userID = result.userSub!
                            self?.saveUser(storedUser: (self?.user)!)
                        } else {
                            print("Got in else")
                        }
                    }
                    
                })
                print("Returning nil outside")
                return nil
            }
        }
        }
        
    }

    @objc func goToVerificationVC() {
        let storyboard = UIStoryboard(name: "Verification", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "VerificationVC") as! VerificationVC
        destVC.sentTo = sentTo
        destVC.user = store
        self.navigationController?.pushViewController(destVC, animated: true)
    }

}
