//
//  LeaderVC.swift
//  Schools-Live
//
//  Created by Hamza  Amin on 1/23/18.
//  Copyright © 2018 Hamza  Amin. All rights reserved.
//

import UIKit

class LeaderVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func openMenu(_ sender: UIButton) {
        print("Button Clicked")
        NotificationCenter.default.post(name: NSNotification.Name("toggleSideMenu"), object: nil)
    }

}
