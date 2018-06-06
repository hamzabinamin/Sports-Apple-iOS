//
//  ExerciseDetailsPopupVC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 6/5/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit

class ExerciseDetailsVC: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var exerciseListTF: UITextField!
    @IBOutlet weak var favoritesListTF: UITextField!
    @IBOutlet weak var weightAmountTF: UITextField!
    @IBOutlet weak var setsTF: UITextField!
    @IBOutlet weak var repsTF: UITextField!
    @IBOutlet weak var countTF: UITextField!
    @IBOutlet weak var timeTF: UITextField!
    @IBOutlet weak var distanceTF: UITextField!
    @IBOutlet weak var commentTV: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setupTextView()
        setupButtonAndTextFields()
        
        completeButton.addTarget(self, action: #selector(addActivityInSession), for: .touchUpInside)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.init(hex: "#c7c7cd") {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Exercise Comment"
            textView.textColor = UIColor.init(hex: "#c7c7cd")
        }
    }
    
    func setupTextView() {
        commentTV.delegate = self
        commentTV.text = "Workout Comment"
        commentTV.textColor = UIColor.init(hex: "#c7c7cd")
    }
    
    func setupButtonAndTextFields() {
        completeButton.layer.cornerRadius = 18
        exerciseListTF.addPadding(.left(35))
        favoritesListTF.addPadding(.left(35))
        weightAmountTF.addPadding(.left(35))
        setsTF.addPadding(.left(35))
        repsTF.addPadding(.left(35))
        countTF.addPadding(.left(35))
        timeTF.addPadding(.left(35))
        distanceTF.addPadding(.left(35))
    }

    @objc func addActivityInSession() {
        self.dismiss(animated: true, completion: nil)
    }

}
