//
//  SignUp2VC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 5/27/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit

class SignUp2VC: UIViewController {
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var dobTF: UITextField!
    @IBOutlet weak var heightTF: UITextField!
    @IBOutlet weak var trainerEmailTF: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        nextButton.layer.cornerRadius = 18
        firstNameTF.addPadding(.left(35))
        lastNameTF.addPadding(.left(35))
        dobTF.addPadding(.left(35))
        heightTF.addPadding(.left(35))
        trainerEmailTF.addPadding(.left(35))
        
        nextButton.addTarget(self, action: #selector(goToSignUp3VC), for: .touchUpInside)
    }

    @objc func goToSignUp3VC() {
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "SignUp3VC")
        self.navigationController?.pushViewController(destVC, animated: true)
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
