//
//  ForgotPasswordConfirmVC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 6/26/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import JGProgressHUD

class ForgotPasswordConfirmVC: UIViewController {
    
    @IBOutlet weak var passwordResetButton: UIButton!
    @IBOutlet weak var verificationTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    var hud: JGProgressHUD?
    var user: AWSCognitoIdentityUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        self.hideKeyboardWhenTappedAround()
        hud = self.createLoadingHUD()
        verificationTF.addPadding(.left(35))
        passwordTF.addPadding(.left(35))
        passwordResetButton.layer.cornerRadius = 18
        
        passwordResetButton.addTarget(self, action: #selector(confirmPassword), for: .touchUpInside)
    }
    
    func validation(verification: String, password: String) -> Bool {
        if verification.count > 0 && password.count > 0 {
            return true
        }
        else {
            self.showErrorHUD(text: "Please fill all fields")
            return false
        }
    }

    @objc func confirmPassword() {
        let verification = verificationTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if validation(verification: verification!, password: password!) {
            self.showHUD(hud: hud!)
            self.user?.confirmForgotPassword(verification!, password: password!).continueWith {[weak self] (task: AWSTask) -> AnyObject? in
                guard self != nil else { return nil }
                DispatchQueue.main.async(execute: {
                    if let error = task.error as NSError? {
                        self?.hideHUD(hud: (self?.hud!)!)
                        print(error.code)
                        print(error.description)
                        
                        if error.code == 13 {
                            self?.showErrorHUD(text: "Password must be of 8 or more characters")
                        }
                        else if error.code == 14 {
                            self?.showErrorHUD(text: "Password must contain uppercase, lowercase & numeric characters")
                        }
                        else if error.code == 3 {
                            self?.showErrorHUD(text: "Invalid verification code provided, please try again")
                        }
                    }
                    else {
                        self?.hideHUD(hud: (self?.hud!)!)
                        self?.showSuccessHUD(text: "Password updated successfully")
                        self?.navigationController?.popToRootViewController(animated: true)
                    }
                })
                return nil
            }
        }
    }
   
}
