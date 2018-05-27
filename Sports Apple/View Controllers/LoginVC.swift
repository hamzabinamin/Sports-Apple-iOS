//
//  ViewController.swift
//  Sports Apple
//
//  Created by Hamza Amin on 5/4/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit
import AWSUserPoolsSignIn
import AWSAuthUI

class LoginVC: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgotPasswordLabel: UILabel!
    @IBOutlet weak var signUpLabel: UILabel!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.isTranslucent = true
        
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
    
    func checkLoginStatus() {
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
    }

}

