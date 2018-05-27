//
//  ForgotPasswordVC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 5/27/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit

class ForgotPasswordVC: UIViewController {
    
    @IBOutlet weak var passwordResetButton: UIButton!
    @IBOutlet weak var emailTF: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordResetButton.layer.cornerRadius = 18
        emailTF.addPadding(.left(35))

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
