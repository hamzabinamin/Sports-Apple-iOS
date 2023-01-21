//
//  ContainerVC.swift
//  
//
//  Created by Hamza  Amin on 10/15/17.
//

import UIKit

class ContainerVC: UIViewController {
    
    @IBOutlet weak var sideMenuContraint: NSLayoutConstraint!
    @IBOutlet weak var sideBarView: UIView!
    var isSideMenuOpen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
         print("In Container VC")
        
        NotificationCenter.default.addObserver(self, selector: #selector(toggleSideMenu), name: NSNotification.Name("toggleSideMenu"), object: nil)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(ContainerVC.swipedRight))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    @objc func swipedRight() {
        print("Swipe Right Function called")
        NotificationCenter.default.post(name: NSNotification.Name("toggleSideMenu"), object: nil)
    }
    
    @objc func toggleSideMenu() {
        print("Original toggleSideMenu Called")
        if isSideMenuOpen {
            isSideMenuOpen = false
            sideMenuContraint.constant = 0
        }
        else {
            print("Menu should open")
            isSideMenuOpen = true
            sideMenuContraint.constant = -240
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }


}
