//
//  ActivitySessionsVC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 6/2/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit

class ActivitySessionsVC: UIViewController {
    
    @IBOutlet weak var addSessionImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        //setupTaps()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        addSessionImageView.isUserInteractionEnabled = true
        addSessionImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func setupTaps() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(goToAddSessionVC))
        addSessionImageView.isUserInteractionEnabled = true
        addSessionImageView.addGestureRecognizer(tap)
    }
    
    @objc func goToAddSessionVC() {
        print("Tapped")
        let storyboard = UIStoryboard(name: "AddSession", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "AddSessionVC")
        self.present(destVC, animated: true, completion: .none)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        print("Tapped")
        let storyboard = UIStoryboard(name: "AddSession", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "AddSessionVC")
        self.present(destVC, animated: true, completion: .none)
        
        // Your action
    }
}
