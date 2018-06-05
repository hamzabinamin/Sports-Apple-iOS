//
//  AddSessionVC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 6/2/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit

class AddSessionVC: UIViewController, UITextViewDelegate {

    @IBOutlet weak var locationTF: UITextField!
    @IBOutlet weak var commentTV: UITextView!
    @IBOutlet weak var caloriesTF: UITextField!
    @IBOutlet weak var weightTF: UITextField!
    @IBOutlet weak var nextLabel: UILabel!
    @IBOutlet weak var prevImageView: UIImageView!
    @IBOutlet weak var forwardImageView: UIImageView!
    @IBOutlet weak var backImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        rotateArrow()
        setupTaps()
        setupTextFields()
        setupTextView()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.init(hex: "#c7c7cd") {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Session Comment"
            textView.textColor = UIColor.init(hex: "#c7c7cd")
        }
    }
    
    func rotateArrow() {
        self.forwardImageView.transform = CGAffineTransform(rotationAngle: .pi);
    }
    
    func setupTaps() {
        let tapPrev = UITapGestureRecognizer(target: self, action: #selector(previousDate))
        let tapForward = UITapGestureRecognizer(target: self, action: #selector(nextDate))
        let tapBack = UITapGestureRecognizer(target: self, action: #selector(back))
        let tapNext = UITapGestureRecognizer(target: self, action: #selector(goToAddActivityInSession))
        prevImageView.isUserInteractionEnabled = true
        prevImageView.addGestureRecognizer(tapPrev)
        forwardImageView.isUserInteractionEnabled = true
        forwardImageView.addGestureRecognizer(tapForward)
        backImageView.isUserInteractionEnabled = true
        backImageView.addGestureRecognizer(tapBack)
        nextLabel.isUserInteractionEnabled = true
        nextLabel.addGestureRecognizer(tapNext)
    }
    
    func setupTextFields() {
        locationTF.addPadding(.left(35))
        caloriesTF.addPadding(.left(35))
        weightTF.addPadding(.left(35))
    }
    
    func setupTextView() {
        commentTV.delegate = self
        commentTV.text = "Workout Comment"
        commentTV.textColor = UIColor.init(hex: "#c7c7cd")
    }
    
    @objc func previousDate() {
        
    }
    
    @objc func nextDate() {
        
    }
    
    @objc func goToAddActivityInSession() {
        let storyboard = UIStoryboard(name: "AddActivityInSession", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "AddActivityInSessionVC")
        self.present(destVC, animated: true, completion: .none)
    }
    
    @objc func back() {
        self.dismiss(animated: true, completion: nil)
    }


}
