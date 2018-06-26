//
//  LogOutVC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 6/6/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class LogOutVC: UIViewController {
   
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var bgView: UIView!
    let pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
   
    override func viewDidLoad() {
        super.viewDidLoad()

        bgView.layer.cornerRadius = 10
        bgView.layer.masksToBounds = true
        setupButtons()
    }
    
    func setupButtons() {
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
    }
    
    @objc func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func logout() {
        
        if let currentUser = pool.currentUser() {
            currentUser.signOut()
            self.dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: .showLoginVC, object: nil)
            })
            
        }
        
    }
}
