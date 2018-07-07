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
    var user: UserItem = UserItem()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        if user.location.count > 0 {
            locationTF.text = user.location
        }
        
    }
    
    func setupViews() {
        hideKeyboardWhenTappedAround()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        unitsTF.text = "Imperial (Units)"
        nextButton.layer.cornerRadius = 18
        unitsTF.addPadding(.left(35))
        locationTF.addPadding(.left(35))
        
        nextButton.addTarget(self, action: #selector(goNext), for: .touchUpInside)
    }
    
    func validation(location: String) -> Bool {
        
        if location.count == 0 {
            self.showErrorHUD(text: "Please fill all fields")
            return false
        }
        return true
    }
    
    @objc func goNext() {
        let location = locationTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
    
        if validation(location: location!) {
            user.location = location!
            goToSignUp4VC()
        }
    }

    @objc func goToSignUp4VC() {
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "SignUp4VC") as! SignUp4VC
        destVC.user = user
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        self.navigationController?.pushViewController(destVC, animated: true)
    }

}
