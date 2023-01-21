//
//  MangeSchoolsVC.swift
//  Schools-Live
//
//  Created by Hamza  Amin on 12/4/17.
//  Copyright © 2017 Hamza  Amin. All rights reserved.
//

import UIKit

class MangeSchoolsVC: UIViewController {
    
    @IBOutlet weak var addSchoolButton: UIButton!
    @IBOutlet weak var editSchoolButton: UIButton!
    @IBOutlet weak var changeSchoolButton: UIButton!
    @IBOutlet weak var gamesButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addSchoolButton.layer.cornerRadius = 20
        addSchoolButton.clipsToBounds = true
        
        editSchoolButton.layer.cornerRadius = 20
        editSchoolButton.clipsToBounds = true
        
        changeSchoolButton.layer.cornerRadius = 20
        changeSchoolButton.clipsToBounds = true
        
        gamesButton.layer.cornerRadius = 20
        gamesButton.clipsToBounds = true
    }
    
    @IBAction func openMenu(_ sender: UIButton) {
        print("Button Clicked")
        NotificationCenter.default.post(name: NSNotification.Name("toggleSideMenu"), object: nil)
        
    }
    
    @IBAction func openAddSchool(sender: UIButton) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddSchool") as! AddSchoolVC
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    @IBAction func openEditSchool(sender: UIButton) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "EditSchool") as! EditSchool1VC
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    @IBAction func openChangeSchool(sender: UIButton) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChangeSchool") as! ChangeSchoolVC
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    @IBAction func openGames(sender: UIButton) {
        /*let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view = storyboard.instantiateViewController(withIdentifier: "ContainerVC") as UIViewController
        self.present(view, animated: true, completion: nil) */
        
  /*      let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "ContainerVC") as! ContainerVC
        self.navigationController?.pushViewController(secondViewController, animated: true) */
         self.navigationController?.popToRootViewController(animated: true)
    }

}
