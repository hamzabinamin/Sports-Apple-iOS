//
//  SignUp4VC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 5/27/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit

class SignUp4VC: UIViewController {

    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var weightTF: UITextField!
    @IBOutlet weak var chestTF: UITextField!
    @IBOutlet weak var waistTF: UITextField!
    @IBOutlet weak var hipsTF: UITextField!
    @IBOutlet weak var neckTF: UITextField!
    @IBOutlet weak var bicepsTF: UITextField!
    @IBOutlet weak var forearmsTF: UITextField!
    @IBOutlet weak var thighsTF: UITextField!
    @IBOutlet weak var calvesTF: UITextField!
    @IBOutlet weak var wristTF: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        completeButton.layer.cornerRadius = 18
        weightTF.addPadding(.left(35))
        chestTF.addPadding(.left(35))
        waistTF.addPadding(.left(35))
        hipsTF.addPadding(.left(35))
        neckTF.addPadding(.left(35))
        bicepsTF.addPadding(.left(35))
        forearmsTF.addPadding(.left(35))
        thighsTF.addPadding(.left(35))
        calvesTF.addPadding(.left(35))
        wristTF.addPadding(.left(35))

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
    }

}
