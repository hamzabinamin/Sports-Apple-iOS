//
//  ViewController.swift
//  Sports Apple
//
//  Created by Hamza Amin on 5/4/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class LoginVC: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgotPasswordLabel: UILabel!
    @IBOutlet weak var signUpLabel: UILabel!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>?
    let pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
    var usernameText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.isTranslucent = true
        
        loginButton.addTarget(self, action: #selector(loginUser), for: .touchUpInside)
        
        loginButton.layer.cornerRadius = 18
        emailTF.addPadding(.left(35))
        passwordTF.addPadding(.left(35))
    
        let tap = UITapGestureRecognizer(target: self, action: #selector(goToForgotPasswordVC))
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(goToSignUp1VC))
        forgotPasswordLabel.isUserInteractionEnabled = true
        forgotPasswordLabel.addGestureRecognizer(tap)
        signUpLabel.isUserInteractionEnabled = true
        signUpLabel.addGestureRecognizer(tap2)
        
        //AWSCognitoUserPoolsSignInProvider.sharedInstance().setInteractiveAuthDelegate(self)
        //AWSSignInManager.sharedInstance().register(signInProvider: AWSCognitoUserPoolsSignInProvider.sharedInstance())
        //AWSIdentityManager.defaultIdentityManager().logins().
        
        //self.pool = AWSCognitoIdentityUserPool.init(forKey: AWSCognitoUserPoolsSignInProviderKey)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if pool.currentUser()?.getSession() != nil {
            print(pool.currentUser()?.getSession())
        }
        else {
            print("No Session")
        }
        
        self.passwordTF.text = nil
        self.emailTF.text = usernameText
    }
    

 /*   func didCompleteStepWithError(_ error: Error?) {
        if error != nil {
            let alertController = UIAlertController(title: error?.localizedDescription, message: "error", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            print("logged in")
        }
    } */
    
    @objc func loginUser() {
        print("Got inside Login func")
        if (self.emailTF.text != nil && self.passwordTF.text != nil) {
            print("Calling login method now")
            let authDetails = AWSCognitoIdentityPasswordAuthenticationDetails(username: self.emailTF.text!, password: self.passwordTF.text! )
            self.passwordAuthenticationCompletion?.set(result: authDetails)
            
        } else {
            print("Empty fields")
            let alertController = UIAlertController(title: "Missing information",
                                                    message: "Please enter a valid user name and password",
                                                    preferredStyle: .alert)
            let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
            alertController.addAction(retryAction)
        }
    }
    
    @objc func goToActivitySessionsVC() {
        let storyboard = UIStoryboard(name: "TabBar", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "TabBarVC")
        self.navigationController?.pushViewController(destVC, animated: true)
        self.navigationController?.isNavigationBarHidden = true
    }

    @objc func goToForgotPasswordVC() {
        let storyboard = UIStoryboard(name: "ForgotPassword", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "ForgotPasswordVC")
        self.navigationController?.pushViewController(destVC, animated: true)
    }
    
    @objc func goToSignUp1VC() {
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "SignUp1VC")
        self.navigationController?.pushViewController(destVC, animated: true)
    }
    
 /*   func checkLoginStatus() {
        if !AWSSignInManager.sharedInstance().isLoggedIn {
            showSignIn()
        }
        else {
            print("Logged In")
            AWSSignInManager.sharedInstance().logout(completionHandler: {(result: Any?, error: Error?) in
                self.showSignIn()
                print("Sign-out Successful");
                
            })
        }
    }
    
    func showSignIn() {
        let config = AWSAuthUIConfiguration()
        config.enableUserPoolsUI = true
        AWSAuthUIViewController
            .presentViewController(with: self.navigationController!,
                                   configuration: config,
                                   completionHandler: { (provider: AWSSignInProvider, error: Error?) in
                                    if error != nil {
                                        print("Error occurred: \(String(describing: error))")
                                    } else {
                                       // let user = User()
                                       // user?.createUser(userId: AWSIdentityManager.default().identityId!)
                                        //let exercise = Exercise()
                                        //exercise?.queryExercise()
                                        //exercise?.createExercise()
                                        let activity = Activity()
                                        //activity?.createActivity()
                                        activity?.queryActivity(userId: AWSIdentityManager.default().identityId!, date: Date().toString(dateFormat: "dd-MM-yyyy"))
                                        //print("User ID: ", AWSIdentityManager.default().identityId!)
                                    }
            })
    } */

}

extension LoginVC: AWSCognitoIdentityPasswordAuthentication {
    
    public func getDetails(_ authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>) {
        print("Get details called")
        self.passwordAuthenticationCompletion = passwordAuthenticationCompletionSource
        DispatchQueue.main.async {
            if (self.usernameText == nil) {
                self.usernameText = authenticationInput.lastKnownUsername
            }
        }
    }
    
    public func didCompleteStepWithError(_ error: Error?) {
        print("Did commplete step with error called")
        DispatchQueue.main.async {
            if let error = error as NSError? {
                let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                        message: error.userInfo["message"] as? String,
                                                        preferredStyle: .alert)
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
                alertController.addAction(retryAction)
                
                self.present(alertController, animated: true, completion:  nil)
                 print(error.description)
            } else {
                self.emailTF.text = nil
                self.dismiss(animated: true, completion: nil)
                print("Got in else")
            }
        }
    }
}

