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
        
         NotificationCenter.default.addObserver(self, selector: #selector(sessionAdded), name: .sessionAdded, object: nil)
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
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            self.showHUD(hud: self.hud!)
            self.session.deleteActivity(activityItem: self.array[index.row], completion: { (response) in
                
                DispatchQueue.main.async {
                    self.hideHUD(hud: self.hud!)
                    if response == "success" {
                        self.showSuccessHUD(text: "Session deleted")
                    }
                    else {
                        self.showErrorHUD(text: response)
                    }
                }
                
            })
        }
        delete.backgroundColor = .red
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            let storyboard = UIStoryboard(name: "AddSession", bundle: nil)
            let destVC = storyboard.instantiateViewController(withIdentifier: "AddSessionVC") as! AddSessionVC
            destVC.oldSession = self.array[index.row]
            self.present(destVC, animated: true, completion: .none)
        }
        edit.backgroundColor = UIColor.init(hex: "#3681CC")
        
        return [delete, edit]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func rotateArrow() {
        self.forwardButton.transform = CGAffineTransform(rotationAngle: .pi)
    }
    
    func setupViews() {
        hud = self.createLoadingHUD()
        formatter.dateFormat = "MMM d, yyyy"
        formatter.locale = Locale(identifier:"en_US_POSIX")
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
                    self.formatter.dateFormat = "MM/dd/yyyy h:mm a"
                    self.array.sort(by: { self.formatter.date(from: $0._date!)?.compare(self.formatter.date(from: ($1._date)!)!) == .orderedDescending})
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
        if let date = notification.object as? [Date] {
            formatter.dateFormat = "MMM d, yyyy"
            self.date = date.first!
            dateLabel.text = formatter.string(from: date.first!)
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
        if !(Calendar.current.date(byAdding: .day, value: 1, to: date)! > Date()) {
            date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
            formatter.dateFormat = "MMM d, yyyy"
            dateLabel.text = formatter.string(from: date)
            getSessions()
        }
    }
    
    @objc func sessionAdded() {
        self.showSuccessHUD(text: "Session added")
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
