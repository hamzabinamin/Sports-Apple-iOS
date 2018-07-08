//
//  ActivitySessionsVC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 6/2/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import JGProgressHUD

class ActivitySessionsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var sessionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var constraintHeading: NSLayoutConstraint!
    @IBOutlet weak var constraintAddImageView: NSLayoutConstraint!
    var hud: JGProgressHUD?
    var array: [Activity] = []
    var pool: AWSCognitoIdentityUserPool?
    var date = Date()
    let formatter = DateFormatter()
    var session: Activity = Activity()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        rotateArrow()
    
        getSessions()
        
         NotificationCenter.default.addObserver(self, selector: #selector(confirmDate(notification:)), name: .confirmDate, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SessionTVCell
        cell.bodyWeightLabel.text = "\(array[indexPath.row]._bodyWeight!.doubleValue)" + " lbs"
        cell.caloriesLabel.text = "\(array[indexPath.row]._calories!.intValue)" 
        cell.locationLabel.text = "(" + array[indexPath.row]._location! + ")"
        cell.sessionCommentLabel.text = array[indexPath.row]._workoutComment
        cell.nextImageView.transform = CGAffineTransform(rotationAngle: .pi);
        
    /*    let tap = UITapGestureRecognizer(target: self, action: #selector(goToSessionActivitiesVC))
        cell.nextImageView.isUserInteractionEnabled = true
        cell.nextImageView.addGestureRecognizer(tap) */
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        session = array[indexPath.row]
        goToSessionActivitiesVC()
    }
    
    func rotateArrow() {
        self.forwardButton.transform = CGAffineTransform(rotationAngle: .pi)
    }
    
    func setupViews() {
        hud = self.createLoadingHUD()
        formatter.dateFormat = "MMM d, yyyy"
        dateLabel.text = formatter.string(from: date)
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
        tableView.tableFooterView = UIView()
        
        previousButton.addTarget(self, action: #selector(previousDate), for: .touchUpInside)
        forwardButton.addTarget(self, action: #selector(nextDate), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(goToAddSessionVC), for: .touchUpInside)
        calendarButton.addTarget(self, action: #selector(goToCalendarVC), for: .touchUpInside)
    }
    
    func getSessions() {
        formatter.dateFormat = "MM/dd/yyyy"
        self.showHUD(hud: hud!)
        session.queryActivity(userId: (pool?.currentUser()?.username)!, date: formatter.string(from: date)) { (response, responseArray) in
            
            DispatchQueue.main.async {
                self.hideHUD(hud: self.hud!)
            }
            print("Response: " + response)
            if response == "success" {
                DispatchQueue.main.async {
                    self.array = responseArray
                    self.tableView.reloadData()
                    self.tableView.isHidden = false
                    self.sessionLabel.isHidden = true
                }
            }
            else if response == "no result" {
                DispatchQueue.main.async {
                    self.tableView.isHidden = true
                    self.sessionLabel.isHidden = false
                }
            }
            else {
                print("Response: " + response)
            }
        }
    }
    
    
    @objc func confirmDate(notification: Notification) {
        if let date = notification.object as? String {
            formatter.dateFormat = "MMM d, yyyy"
            self.date = formatter.date(from: date)!
            dateLabel.text = date
            getSessions()
        }
    }
    
    @objc func previousDate() {
        date = Calendar.current.date(byAdding: .day, value: -1, to: date)!
        formatter.dateFormat = "MMM d, yyyy"
        dateLabel.text = formatter.string(from: date)
        getSessions()
    }
    
    @objc func nextDate() {
        date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
        formatter.dateFormat = "MMM d, yyyy"
        dateLabel.text = formatter.string(from: date)
        getSessions()
    }
    
    @objc func goToAddSessionVC() {
        let storyboard = UIStoryboard(name: "AddSession", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "AddSessionVC")
        self.present(destVC, animated: true, completion: .none)
    }
    
    @objc func goToSessionActivitiesVC() {
        let storyboard = UIStoryboard(name: "SessionActivities", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "SessionActivitiesVC") as! SessionActivitiesVC
        destVC.session = session
        self.present(destVC, animated: true, completion: .none)
    }
    
    @objc func goToCalendarVC() {
        let storyboard = UIStoryboard(name: "AddSession", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "CalendarVC") as! CalendarVC
        destVC.date = date
        self.present(destVC, animated: true, completion: .none)
    }
}
