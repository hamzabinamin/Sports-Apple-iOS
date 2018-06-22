//
//  SignUp1VC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 5/27/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit
import AWSUserPoolsSignIn

class SignUp1VC: UIViewController {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    var pool: AWSCognitoIdentityUserPool?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        nextButton.layer.cornerRadius = 18
        emailTF.addPadding(.left(35))
        passwordTF.addPadding(.left(35))
        
        nextButton.addTarget(self, action: #selector(signUp), for: .touchUpInside)
        self.pool = AWSCognitoIdentityUserPool.init(forKey: AWSCognitoUserPoolsSignInProviderKey)
    }


    @objc func goToSignUp2VC() {
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "SignUp2VC")
        self.navigationController?.pushViewController(destVC, animated: true)
    }
    
    @objc func signUp() {
        print("Sign up called")
        let email = emailTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let emailAttribute = AWSCognitoIdentityUserAttributeType(name: "email", value: email!)
        
        self.pool?.signUp("Jacob", password: password!, userAttributes: [emailAttribute], validationData: nil).continueWith {[weak self] (task) -> Any? in
            print("Inside method")
            guard self != nil else {
                print("Returning Nil")
                return nil }
            DispatchQueue.main.async(execute: {
                if let error = task.error as NSError? {
                    let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                            message: error.userInfo["message"] as? String,
                                                            preferredStyle: .alert)
                    let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
                    alertController.addAction(retryAction)
                    
                    self?.present(alertController, animated: true, completion:  nil)
                } else if let result = task.result  {
                    // handle the case where user has to confirm his identity via email / SMS
                    if (result.user.confirmedStatus != AWSCognitoIdentityUserStatus.confirmed) {
                        print(result.user.confirmedStatus)
                        //strongSelf.sentTo = result.codeDeliveryDetails?.destination
                        //strongSelf.performSegue(withIdentifier: "confirmSignUpSegue", sender:sender)
                    } else {
                        print("Got in else")
                        //let _ = strongSelf.navigationController?.popToRootViewController(animated: true)
                    }
                }
                
            })
            print("Returning nil outside")
            return nil
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
