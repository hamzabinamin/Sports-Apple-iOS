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
import JGProgressHUD

class LoginVC: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgotPasswordLabel: UILabel!
    @IBOutlet weak var signUpLabel: UILabel!
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
            
            if (pool.currentUser()?.isSignedIn)! {
                print("User logged in 1st")
                print("Username in LoginVC: ", pool.currentUser()?.username)
                goToActivitySessionsVC()
            }
            else {
                 print("User not logged in 1st")
            }
        }
        else {
            print("No Session")
           // print("Here: ", pool.currentUser()?.getDetails())
            (UIApplication.shared.delegate as! AppDelegate).pool?.getUser().getDetails()
            
         /*   if ((UIApplication.shared.delegate as! AppDelegate).pool?.getUser().isSignedIn)! {
                print("User logged in")
            }
            else {
                (UIApplication.shared.delegate as! AppDelegate).pool?.getUser().getDetails()
                pool.currentUser()?.getDetails()
                  print("User not logged in")
            } */
            
            
            //let user = appDelegate.pool!.currentUser()
            //let details = user!.getDetails()
        }
        
        self.passwordTF.text = nil
        self.emailTF.text = usernameText
    }
    
    func setupViews() {
        self.hud = createLoadingHUD()
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
        self.navigationController?.pushViewController(destVC, animated: true)
    }
    
    @objc func goToVerificationVC() {
        let storyboard = UIStoryboard(name: "Verification", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "VerificationVC") as! VerificationVC
        destVC.sentTo = sentTo
        destVC.user = (UIApplication.shared.delegate as! AppDelegate).pool?.getUser()
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
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
        if (self.user == nil) {
            self.user = self.pool.currentUser()
    
        }
       /* self.user?.getDetails().continueOnSuccessWith { (task) -> AnyObject? in
            DispatchQueue.main.async(execute: {
                let response = task.result
               // print(response.idTok)
                //print("Username: ", self.user?.username)
                let userAttribute = response?.userAttributes![2]
                print("Attribute Name: ", userAttribute?.name!)
                print("Attribute Value: ", userAttribute?.value!)
            })
            return nil
        } */
        
        
        if UtilityFunctions.getUserDefaults() != nil {
            if UtilityFunctions.getUserDefaults()!.email.count > 0 {
                let user = User()
                let storedUser = UtilityFunctions.getUserDefaults()!
                storedUser.userID = (self.user?.username!)!
                
                user?.createUser(userId: storedUser.userID, firstName: storedUser.firstName, lastName: storedUser.lastName, trainerEmail: storedUser.trainerEmail, biceps: storedUser.biceps, calves: storedUser.calves, chest: storedUser.chest, dOB: storedUser.dOB, forearms: storedUser.forearms, height: storedUser.height, hips: storedUser.hips, location: storedUser.location, neck: storedUser.neck, thighs: storedUser.thighs, waist: storedUser.waist, weight: storedUser.weight, wrist: storedUser.wrist, completion: { response in
                    self.hideHUD(hud: self.hud!)
                    if response == "success" {
                        print("Got here success")
                        UtilityFunctions.saveUserDefaults(value: UserItem())
                        self.goToActivitySessionsVC()
                    }
                    
                })
            }
            else {
                self.hideHUD(hud: hud!)
                goToActivitySessionsVC()
            }
        }
        else {
             self.hideHUD(hud: hud!)
           // goToActivitySessionsVC()
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
                        //self.sentTo =
                        self.goToVerificationVC()
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

