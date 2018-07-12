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
    var hud: JGProgressHUD?
    var pool: AWSCognitoIdentityUserPool?
    var user: UserItem = UserItem()
    var sentTo = ""
    let inchesArray = [Int](1...150)
    let inchesDecimalArray = [Int](0...9)
    let inchesSymbol = ["inches"]
    var store: AWSCognitoIdentityUser?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupPicker()
        
        if user.weight.stringValue != "-1" && user.userID.count > 0 {
            weightTF.text = user.weight.stringValue
            chestTF.text = user.chest.stringValue
            waistTF.text = user.waist.stringValue
            hipsTF.text = user.hips.stringValue
            neckTF.text = user.neck.stringValue
            bicepsTF.text = user.biceps.stringValue
            forearmsTF.text = user.forearms.stringValue
            thighsTF.text = user.thighs.stringValue
            calvesTF.text = user.calves.stringValue
            wristTF.text = user.wrist.stringValue
            completeButton.setTitle("Update", for: .normal)
        }
        else if user.weight.stringValue != "-1" {
            weightTF.text = user.weight.stringValue
            chestTF.text = user.chest.stringValue
            waistTF.text = user.waist.stringValue
            hipsTF.text = user.hips.stringValue
            neckTF.text = user.neck.stringValue
            bicepsTF.text = user.biceps.stringValue
            forearmsTF.text = user.forearms.stringValue
            thighsTF.text = user.thighs.stringValue
            calvesTF.text = user.calves.stringValue
            wristTF.text = user.wrist.stringValue
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
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
            return inchesSymbol[row]
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
        storeUser.createUser(userId: user.userID, firstName: user.firstName, lastName: user.lastName, trainerEmail: user.trainerEmail, biceps: user.biceps, calves: user.calves, chest: user.chest, dOB: user.dOB, forearms: user.forearms, height: user.height, hips: user.hips, location: user.location, neck: user.neck, thighs: user.thighs, waist: user.waist, weight: user.weight, wrist: user.wrist, completion: { (response) in
            
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
        
        if weight.count == 0 && chest.count == 0 && waist.count == 0 && hips.count == 0 && neck.count == 0 && biceps.count == 0 && forearms.count == 0 && thighs.count == 0 && calves.count == 0 && wrist.count == 0 {
            self.showErrorHUD(text: "Please fill all fields")
            return false
        }
    
        return true
    }
    
    func saveUser(storedUser: UserItem) {
        let user = User()
        //self.showHUD(hud: hud!)
        user?.createUser(userId: storedUser.userID, firstName: storedUser.firstName, lastName: storedUser.lastName, trainerEmail: storedUser.trainerEmail, biceps: storedUser.biceps, calves: storedUser.calves, chest: storedUser.chest, dOB: storedUser.dOB, forearms: storedUser.forearms, height: storedUser.height, hips: storedUser.hips, location: storedUser.location, neck: storedUser.neck, thighs: storedUser.thighs, waist: storedUser.waist, weight: storedUser.weight, wrist: storedUser.wrist, completion: { response in
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
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelPicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
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
            weightTF.text = String((inchesArray[picker.selectedRow(inComponent: 0)])) + "." + String((inchesDecimalArray[picker.selectedRow(inComponent: 1)]))
            chestTF.perform(
                #selector(becomeFirstResponder),
                with: nil,
                afterDelay: 0.1
            )
        }
        else if activeField == chestTF {
            chestTF.text = String((inchesArray[picker.selectedRow(inComponent: 0)])) + "." + String((inchesDecimalArray[picker.selectedRow(inComponent: 1)]))
            waistTF.perform(
                #selector(becomeFirstResponder),
                with: nil,
                afterDelay: 0.1
            )
        }
        else if activeField == waistTF {
            waistTF.text = String((inchesArray[picker.selectedRow(inComponent: 0)])) + "." + String((inchesDecimalArray[picker.selectedRow(inComponent: 1)]))
            hipsTF.perform(
                #selector(becomeFirstResponder),
                with: nil,
                afterDelay: 0.1
            )
        }
        else if activeField == hipsTF {
            hipsTF.text = String((inchesArray[picker.selectedRow(inComponent: 0)])) + "." + String((inchesDecimalArray[picker.selectedRow(inComponent: 1)]))
            neckTF.perform(
                #selector(becomeFirstResponder),
                with: nil,
                afterDelay: 0.1
            )
        }
        else if activeField == neckTF {
            neckTF.text = String((inchesArray[picker.selectedRow(inComponent: 0)])) + "." + String((inchesDecimalArray[picker.selectedRow(inComponent: 1)]))
            bicepsTF.perform(
                #selector(becomeFirstResponder),
                with: nil,
                afterDelay: 0.1
            )
        }
        else if activeField == bicepsTF {
            bicepsTF.text = String((inchesArray[picker.selectedRow(inComponent: 0)])) + "." + String((inchesDecimalArray[picker.selectedRow(inComponent: 1)]))
            forearmsTF.perform(
                #selector(becomeFirstResponder),
                with: nil,
                afterDelay: 0.1
            )
        }
        else if activeField == forearmsTF {
            forearmsTF.text = String((inchesArray[picker.selectedRow(inComponent: 0)])) + "." + String((inchesDecimalArray[picker.selectedRow(inComponent: 1)]))
            thighsTF.perform(
                #selector(becomeFirstResponder),
                with: nil,
                afterDelay: 0.1
            )
        }
        else if activeField == thighsTF {
            thighsTF.text = String((inchesArray[picker.selectedRow(inComponent: 0)])) + "." + String((inchesDecimalArray[picker.selectedRow(inComponent: 1)]))
            calvesTF.perform(
                #selector(becomeFirstResponder),
                with: nil,
                afterDelay: 0.1
            )
        }
        else if activeField == calvesTF {
            calvesTF.text = String((inchesArray[picker.selectedRow(inComponent: 0)])) + "." + String((inchesDecimalArray[picker.selectedRow(inComponent: 1)]))
            wristTF.perform(
                #selector(becomeFirstResponder),
                with: nil,
                afterDelay: 0.1
            )
        }
        else if activeField == wristTF {
            wristTF.text = String((inchesArray[picker.selectedRow(inComponent: 0)])) + "." + String((inchesDecimalArray[picker.selectedRow(inComponent: 1)]))
        }
        
        self.view.endEditing(true)
    }
    
    @objc func cancelPicker(){
        self.view.endEditing(true)
    }

    @objc func signUp() {
        print("Sign up called")
        let weight = weightTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let chest =  chestTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let waist = waistTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let hips = hipsTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let neck = neckTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let biceps = bicepsTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let forearms = forearmsTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let thighs = thighsTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let calves = calvesTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let wrist = wristTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = user.email
        let password = user.password
        //let emailAttribute = AWSCognitoIdentityUserAttributeType(name: "email", value: email!)
        
        if validation(weight: weight, chest: chest, waist: waist, hips: hips, neck: neck, biceps: biceps, forearms: forearms, thighs: thighs, calves: calves, wrist: wrist) {
        
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
