//
//  VerificationVC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 6/24/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import JGProgressHUD

class VerificationVC: UIViewController {
    
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var resendButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var codeTF: UITextField!
    var hud: JGProgressHUD?
    var sentTo = ""
    var user: AWSCognitoIdentityUser?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        if let rootVC = navigationController?.viewControllers.first {
            navigationController?.viewControllers = [rootVC, self]
        }
    }

    func setupViews() {
        hideKeyboardWhenTappedAround()
        hud = self.createLoadingHUD()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        titleLabel.text = "Verification code sent to: \(self.sentTo)"
        verifyButton.layer.cornerRadius = 18
        codeTF.addPadding(.left(35))
        
        resendButton.addTarget(self, action: #selector(resendCode), for: .touchUpInside)
        verifyButton.addTarget(self, action: #selector(verifyAccount), for: .touchUpInside)
    }
   

    @objc func resendCode() {
        self.showHUD(hud: hud!)
        self.user?.resendConfirmationCode().continueWith {[weak self] (task: AWSTask) -> AnyObject? in
            guard let _ = self else { return nil }
            DispatchQueue.main.async(execute: {
                self?.hideHUD(hud: (self?.hud!)!)
                if let error = task.error as NSError? {
                    let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                            message: error.userInfo["message"] as? String,
                                                            preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    print(error.code)
                    
                    self?.present(alertController, animated: true, completion:  nil)
                } else if let result = task.result {
                   
                    self?.showSuccessHUD(text: "Verification code resent to " + (result.codeDeliveryDetails?.destination!)!)
                }
            })
            return nil
        }
    }
    
    @objc func verifyAccount() {
        let code = codeTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        self.showHUD(hud: hud!)
        self.user?.confirmSignUp(code, forceAliasCreation: true).continueWith {[weak self] (task: AWSTask) -> AnyObject? in
            guard self != nil else { return nil }
            DispatchQueue.main.async(execute: {
                 self?.hideHUD(hud: (self?.hud!)!)
                if let error = task.error as NSError? {
                    
                    print(error.code)
                    if error.code == 13 {
                        self?.showErrorHUD(text: "Verification code must have length greater than or equal to 1")
                    }
                    else if error.code == 3 {
                        self?.showErrorHUD(text: "Invalid verification code provided, please try again")
                    }
                    
                } else {
                    self?.navigationController?.popToRootViewController(animated: true)
                    //self?.goToLoginVC()
                }
            })
            return nil
        }
    }
    
    @objc func goToLoginVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "LoginVC")
        self.navigationController?.pushViewController(destVC, animated: true)
    }
}
