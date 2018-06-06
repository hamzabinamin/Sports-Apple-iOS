//
//  SignUp3VC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 5/27/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit

class SignUp3VC: UIViewController {
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var unitsTF: UITextField!
    @IBOutlet weak var locationTF: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        nextButton.layer.cornerRadius = 18
        unitsTF.addPadding(.left(35))
        locationTF.addPadding(.left(35))
        
        nextButton.addTarget(self, action: #selector(goToSignUp4VC), for: .touchUpInside)
    }

    @objc func goToSignUp4VC() {
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "SignUp4VC")
        self.navigationController?.pushViewController(destVC, animated: true)
    }

}
