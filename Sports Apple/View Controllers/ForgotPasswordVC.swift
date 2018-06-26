//
//  ForgotPasswordVC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 5/27/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import JGProgressHUD

class ForgotPasswordVC: UIViewController {
    
    @IBOutlet weak var passwordResetButton: UIButton!
    @IBOutlet weak var emailTF: UITextField!
    var hud: JGProgressHUD?
    var pool: AWSCognitoIdentityUserPool?
    var user: AWSCognitoIdentityUser?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()

    }
    
    func setupViews() {
        self.hideKeyboardWhenTappedAround()
        hud = self.createLoadingHUD()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
        passwordResetButton.layer.cornerRadius = 18
        emailTF.addPadding(.left(35))
    
        passwordResetButton.addTarget(self, action: #selector(forgotPassword), for: .touchUpInside)
    }

    func validation(email: String) -> Bool {
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        if email.count > 0 {
            
            if !emailTest.evaluate(with: email) {
                self.showErrorHUD(text: "Please write a valid email")
                return false
            }
            return true
        }
        else {
            self.showErrorHUD(text: "Please fill all fields")
            return false
        }
    }

    
    @objc func forgotPassword() {
        let email = emailTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if validation(email: email) {
            self.showHUD(hud: hud!)
            self.user = self.pool?.getUser(email)
            self.user?.forgotPassword().continueWith{[weak self] (task: AWSTask) -> AnyObject? in
                guard self != nil else {return nil}
                DispatchQueue.main.async(execute: {
                    self?.hideHUD(hud: (self?.hud!)!)
                    if let error = task.error as NSError? {
                        print(error.code)
                        if error.code == 34 {
                            self?.showErrorHUD(text: "User not found")
                        }
                    } else {
                        self?.goToForgotPasswordConfirmVC()
                    }
                })
                return nil
            }
        }
    }
    
    @objc func goToForgotPasswordConfirmVC() {
        let storyboard = UIStoryboard(name: "ForgotPassword", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "ForgotPasswordConfirmVC") as! ForgotPasswordConfirmVC
        destVC.user = user
        self.navigationController?.pushViewController(destVC, animated: true)
    }
}
