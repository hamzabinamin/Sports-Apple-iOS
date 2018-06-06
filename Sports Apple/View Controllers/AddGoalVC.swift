//
//  AddGoalVC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 6/6/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit

class AddGoalVC: UIViewController {

    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var exerciseListTF: UITextField!
    @IBOutlet weak var favoritesListTF: UITextField!
    @IBOutlet weak var goalTypeTF: UITextField!
    @IBOutlet weak var goalAmountTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setupButtonAndTextFields()
        
        completeButton.addTarget(self, action: #selector(addGoal), for: .touchUpInside)
    }
    
    func setupButtonAndTextFields() {
        completeButton.layer.cornerRadius = 18
        exerciseListTF.addPadding(.left(35))
        favoritesListTF.addPadding(.left(35))
        goalTypeTF.addPadding(.left(35))
        goalAmountTF.addPadding(.left(35))
    }
    
    @objc func addGoal() {
        self.dismiss(animated: true, completion: nil)
    }

}
