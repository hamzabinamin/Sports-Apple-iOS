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

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
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
                                        activity?.createActivity()
                                        print("User ID: ", AWSIdentityManager.default().identityId!)
                                    }
            })
    }

}

