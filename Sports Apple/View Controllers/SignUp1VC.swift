//
//  SignUp1VC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 5/27/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit

class SignUp1VC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var updatePasswordButton: UIButton!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var newPasswordTF: UITextField!
    @IBOutlet weak var newPasswordImageView: UIImageView!
    var user: UserItem = UserItem()
    //var cameFromSettings = false
    //var passwordChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        if user.email.count > 0 {
            emailTF.isEnabled = false
            emailTF.alpha = 0.5
            passwordTF.isEnabled = false
            passwordTF.alpha = 0.5
            emailTF.text = user.email
            passwordTF.text = "Tigerey1"
            updatePasswordButton.isHidden = false
        }
        else {
            emailTF.isEnabled = true
            emailTF.alpha = 1
            passwordTF.isEnabled = true
            passwordTF.alpha = 1
            updatePasswordButton.isHidden = true
        }
    }
    
  /*  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == passwordTF {
            passwordChanged = true
        }
      return true
    } */
    
    func setupViews() {
        hideKeyboardWhenTappedAround()
        self.passwordTF.delegate = self
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        nextButton.layer.cornerRadius = 18
        emailTF.addPadding(.left(35))
        passwordTF.addPadding(.left(35))
        newPasswordTF.addPadding(.left(35))
        
        nextButton.addTarget(self, action: #selector(goNext), for: .touchUpInside)
        updatePasswordButton.addTarget(self, action: #selector(showViews), for: .touchUpInside)
    }
    
    func validation(email: String, password: String, newPassword: String) -> Bool {
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let passwordRegEx = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d]{8,}$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        if email.count > 0 && password.count > 0 {
            
            if !emailTest.evaluate(with: email) {
                self.showErrorHUD(text: "Please write a valid email")
                return false
            }
            
            if !passwordTest.evaluate(with: password) {
                self.showErrorHUD(text: "Password must be atleast 8 characters long, contain atleast one uppercase, lowercase & numeric characters")
                return false
            }
            
            if !newPasswordTF.isHidden {
                if !passwordTest.evaluate(with: newPassword) {
                    self.showErrorHUD(text: "Password must be atleast 8 characters long, contain atleast one uppercase, lowercase & numeric characters")
                    return false
                }
            }
            
            return true
        }
        self.showErrorHUD(text: "Please fill all fields")
        return false
    }

    @objc func goNext() {
        let email = emailTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let newPassword = newPasswordTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if validation(email: email, password: password, newPassword: newPassword) {
            user.email = email
            user.password = password
            
            if !newPasswordTF.isHidden {
                user.newPassword = newPassword
            }
            
           // if cameFromSettings &&
            goToSignUp2VC()
        }
    }
    
    @objc func showViews() {
        if newPasswordTF.isHidden && newPasswordImageView.isHidden {
            passwordTF.isEnabled = true
            passwordTF.alpha = 1
            passwordTF.placeholder = "Old Password"
            passwordTF.text = ""
            newPasswordTF.isHidden = false
            newPasswordImageView.isHidden = false
            updatePasswordButton.setTitle("Cancel", for: .normal)
        }
        else {
            passwordTF.isEnabled = false
            passwordTF.alpha = 0.5
            passwordTF.text = "Tigerey1"
            newPasswordTF.isHidden = true
            newPasswordImageView.isHidden = true
            updatePasswordButton.setTitle("Update Password", for: .normal)
        }
    }
    
    @objc func goToSignUp2VC() {
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "SignUp2VC") as! SignUp2VC
        destVC.user = user
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationItem.backBarButtonItem = backItem
        self.navigationController?.pushViewController(destVC, animated: true)
    }
}
