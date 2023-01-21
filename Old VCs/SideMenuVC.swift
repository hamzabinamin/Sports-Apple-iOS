//
//  SideMenuVC.swift
//  
//
//  Created by Hamza  Amin on 10/15/17.
//

import UIKit
import MessageUI

class SideMenuVC: UIViewController {

    @IBOutlet weak var schoolLogo: SwiftyAvatar!
    @IBOutlet weak var gamesItem: UILabel!
    @IBOutlet weak var changeItem: UILabel!
    @IBOutlet weak var editItem: UILabel!
    @IBOutlet weak var addItem: UILabel!
    @IBOutlet weak var notificationItem: UILabel!
    @IBOutlet weak var leaderItem: UILabel!
    @IBOutlet weak var settingsItem: UILabel!
    @IBOutlet weak var touchItem: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        let school = retrieveSchool()
        
        if school  != nil {
            let encoded = school?.schoolImage.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
            let url = URL(string: (encoded)!)
            schoolLogo.kf.setImage(with: url)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeSchoolImage), name: NSNotification.Name("changeSchoolImage"), object: nil)
        
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(SideMenuVC.swipedLeft))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    @objc func changeSchoolImage(_ sender: Any) {
        let school = retrieveSchool()
        
        if school  != nil {
            let encoded = school?.schoolImage.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
            let url = URL(string: (encoded)!)
            schoolLogo.kf.setImage(with: url)
        }
    }
    
    @objc func swipedLeft() {
        print("Swipe Left Function called")
        NotificationCenter.default.post(name: NSNotification.Name("toggleSideMenu"), object: nil)
    }
    
    @IBAction func openGames(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name("openGames"), object: nil)
    }
    
    @IBAction func openChange(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name("openChange"), object: nil)
    }
    
    @IBAction func openEdit(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name("openEdit"), object: nil)
    }
    
    @IBAction func openAdd(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name("openAdd"), object: nil)
    }
    
    @IBAction func openNotifications(_ sender: Any) {
        print("Notifications got Called")
        NotificationCenter.default.post(name: NSNotification.Name("openNotifications"), object: nil)
    }
    
    @IBAction func openLeaderboard(_ sender: Any) {
        print("Leaderboard got Called")
        NotificationCenter.default.post(name: NSNotification.Name("openLeaderboard"), object: nil)
    }
    
    @IBAction func openUserSettings(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name("openUserSettings"), object: nil)
    }
    
    @IBAction func openGetInTouch(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name("openGetInTouch"), object: nil)
    }
}
