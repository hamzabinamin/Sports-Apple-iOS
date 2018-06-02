//
//  AddSessionVC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 6/2/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit

class AddSessionVC: UIViewController {

    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var forwardImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        rotateArrow()
        setupTaps()
    }
    
    func rotateArrow() {
        self.forwardImageView.transform = CGAffineTransform(rotationAngle: .pi);
    }
    
    func setupTaps() {
        let tapPrev = UITapGestureRecognizer(target: self, action: #selector(previousDate))
        let tapNext = UITapGestureRecognizer(target: self, action: #selector(nextDate))
        backImageView.isUserInteractionEnabled = true
        backImageView.addGestureRecognizer(tapPrev)
        forwardImageView.isUserInteractionEnabled = true
        forwardImageView.addGestureRecognizer(tapNext)
    }
    
    @objc func previousDate() {
        
    }
    
    @objc func nextDate() {
        
    }


}
