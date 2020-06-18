//
//  ViewController.swift
//  Sports Apple
//
//  Created by Hamza Amin on 5/4/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import AWSCognito
import AWSAuthCore
import JGProgressHUD

class LoginVC: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    var hud: JGProgressHUD?
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>?
    var pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
    var usernameText: String?
    var user: AWSCognitoIdentityUser?
    var sentTo = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
         if pool.currentUser()?.getSession() != nil {
            print("Session there")
         
        }
        else {
            print("No Session")
            (UIApplication.shared.delegate as! AppDelegate).pool?.getUser().getDetails()
        }
        
        passwordTF.text = ""
    }
    
    func setupViews() {
        self.hud = createLoadingHUD()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.isTranslucent = true
        
        loginButton.addTarget(self, action: #selector(loginUser), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(goToForgotPasswordVC), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(goToSignUp1VC), for: .touchUpInside)
        
        
        loginButton.layer.cornerRadius = 18
        emailTF.addPadding(.left(35))
        passwordTF.addPadding(.left(35))
    }
    
    @objc func loginUser() {
        self.showHUD(hud: hud!)
        print("Got inside Login func")
        if (self.emailTF.text != nil && self.passwordTF.text != nil) {
            print("Calling login method now")
            let authDetails = AWSCognitoIdentityPasswordAuthenticationDetails(username: self.emailTF.text!, password: self.passwordTF.text! )
           self.passwordAuthenticationCompletion?.set(result: authDetails)
            
        } else {
            self.hideHUD(hud: hud!)
            self.showErrorHUD(text: "Please enter a valid user name and password")
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
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        self.navigationController?.pushViewController(destVC, animated: true)
    }
    
    @objc func goToVerificationVC() {
        let storyboard = UIStoryboard(name: "Verification", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "VerificationVC") as! VerificationVC
        let email = (emailTF.text?.trimmingCharacters(in: .whitespacesAndNewlines))!
        destVC.sentTo = email
        destVC.user = (UIApplication.shared.delegate as! AppDelegate).pool?.getUser(email)
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

    func processUser() {
        if (self.user == nil) {
            self.user = self.pool.currentUser()
        }
        DispatchQueue.main.async {
            self.hideHUD(hud: self.hud!)
            self.goToActivitySessionsVC()
        }
       /* if UtilityFunctions.getUserDefaults() != nil {
            if UtilityFunctions.getUserDefaults()!.email.count > 0 {
                print("Saving user info in db")
                let user = User()
                let storedUser = UtilityFunctions.getUserDefaults()!
                storedUser.userID = (self.pool.currentUser()?.username)!
                
                user?.createUser(userId: storedUser.userID, firstName: storedUser.firstName, lastName: storedUser.lastName, trainerEmail: storedUser.trainerEmail, biceps: storedUser.biceps, calves: storedUser.calves, chest: storedUser.chest, dOB: storedUser.dOB, forearms: storedUser.forearms, height: storedUser.height, hips: storedUser.hips, location: storedUser.location, neck: storedUser.neck, thighs: storedUser.thighs, waist: storedUser.waist, weight: storedUser.weight, wrist: storedUser.wrist, completion: { response in
                    DispatchQueue.main.async {
                        self.hideHUD(hud: self.hud!)
                    }
                    if response == "success" {
                        print("Got here success")
                        DispatchQueue.main.async {
                            UtilityFunctions.saveUserDefaults(value: UserItem())
                            print()
                            self.goToActivitySessionsVC()
                        }
                    }
                })
            }
            else {
                DispatchQueue.main.async {
                    self.hideHUD(hud: self.hud!)
                    print("Calling ActivitySessionsVC")
                    self.goToActivitySessionsVC()
                }
            }
        }
        else {
            DispatchQueue.main.async {
                print("Userdefaults were nil")
                self.hideHUD(hud: self.hud!)
                self.goToActivitySessionsVC()
            }
        } */
    }
    
    func sendVerificationCode() {
        let email = emailTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let user = (UIApplication.shared.delegate as! AppDelegate).pool?.getUser(email!)
        user?.resendConfirmationCode().continueWith {[weak self] (task: AWSTask) -> AnyObject? in
            guard let _ = self else { return nil }
            DispatchQueue.main.async(execute: {
                self?.hideHUD(hud: (self?.hud!)!)
                if let error = task.error as NSError? {
                    self?.showErrorHUD(text: error.localizedDescription)
                } else if task.result != nil {
                    self?.goToVerificationVC()
                }
            })
            return nil
        }
    }
    
}

extension LoginVC: AWSCognitoIdentityPasswordAuthentication {
    
    public func getDetails(_ authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>) {
        print("Get details called")
        self.passwordAuthenticationCompletion = passwordAuthenticationCompletionSource
        DispatchQueue.main.async {
            if (self.usernameText == nil) {
                //self.usernameText = authenticationInput.lastKnownUsername
            }
        }
       // processUser()
    }
    
    public func didCompleteStepWithError(_ error: Error?) {
        print("Did commplete step with error called")
        DispatchQueue.main.async {
            if let error = error as NSError? {
                self.hideHUD(hud: self.hud!)
                print(error.code)
                if error.code == 20 {
                    // Incorrect username or password
                    self.showErrorHUD(text: "Incorrent username or password")
                }
                else if error.code == 13 {
                    // Missing required parameter USERNAME
                    self.showErrorHUD(text: "Please fill all fields")
                }
                else if error.code == 33 {
                    //self.showErrorHUD(text: "User is not confirmed")
                    let alertController = UIAlertController(title: "User Confirmation", message: "User is not confirmed", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Verify Now", style: UIAlertActionStyle.default) {
                        UIAlertAction in
                        self.sendVerificationCode()
                    }
                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
                        UIAlertAction in
                        alertController.dismiss(animated: true, completion: nil)
                    }
                    alertController.addAction(okAction)
                    alertController.addAction(cancelAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
                else if error.code == 34 {
                    // User does not exist
                    self.showErrorHUD(text: "User not found")
                }
                
            } else {
                self.processUser()
                print("Got in else")
            }
        }
    }
}

