//
//  LeaderboardVC.swift
//  Schools-Live
//
//  Created by Hamza  Amin on 10/17/17.
//  Copyright © 2017 Hamza  Amin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LeaderboardVC: UIViewController, UITableViewDataSource , UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var schoolTypeLabel: UILabel!
    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var schoolLocationLabel: UILabel!
    @IBOutlet weak var schoolWebsiteLabel: UILabel!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    var array = [Rank]()
    let messageFrame = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = 40
        let school = retrieveSchool()
        
        if school == nil {
            DispatchQueue.main.async {
               /* self.createAlert(titleText: "Note", messageText: "Either add a new School or Select existing one from  Change School") */
                let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChangeSchool") as! ChangeSchoolVC
                self.navigationController?.pushViewController(secondViewController, animated: true)
            }
        }
        else {
            schoolTypeLabel.text = school?.schoolType
            schoolNameLabel.text = school?.schoolName
            schoolLocationLabel.text = school?.schoolLocation
           // schoolWebsiteLabel.text = school?.schoolWebsite
            
            if isConnectedToNetwork() {
                getNoOfUpdates()
            }
            else {
                 createAlert2(titleText: "Note", messageText: "Please connect to the Internet")
            }
        }
    }
    
    func createAlert(titleText: String, messageText: String) {
        
        let alert = UIAlertController(title: titleText, message: messageText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
            alert.dismiss(animated: true, completion: nil)
            self.performSegue(withIdentifier: "ManageSchools", sender: nil)
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func createAlert2(titleText: String, messageText: String) {
        
        let alert = UIAlertController(title: titleText, message: messageText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return array.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell: Rank = tableView.dequeueReusableCell(withIdentifier: "cell") as! Rank
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! rankTVCell
        
        cell.rankLabel.text = "\(array[indexPath.row].rank)"
        cell.nameLabel.text = array[indexPath.row].name
        cell.dateLabel.text = array[indexPath.row].date.replacingOccurrences(of: "/", with: "")
        cell.totalUpdatesLabel.text = "\(array[indexPath.row].totalUpdates)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let cell = tableView.cellForRow(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func openMenu(_ sender: UIButton) {
        print("Button Clicked")
        NotificationCenter.default.post(name: NSNotification.Name("toggleSideMenu"), object: nil)
    }
    
    func activityIndicator(_ title: String) {
        strLabel.removeFromSuperview()
        activityIndicator.removeFromSuperview()
        effectView.removeFromSuperview()
        
        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 160, height: 46))
        strLabel.text = title
        strLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
        strLabel.textColor = UIColor(white: 0.9, alpha: 0.7)
        
        effectView.frame = CGRect(x: view.frame.midX - strLabel.frame.width/2, y: view.frame.midY - strLabel.frame.height/2 , width: 160, height: 46)
        effectView.layer.cornerRadius = 15
        effectView.layer.masksToBounds = true
        
        activityIndicator = UIActivityIndicatorView(style: .white)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
        activityIndicator.startAnimating()
        
        effectView.contentView.addSubview(activityIndicator)
        effectView.contentView.addSubview(strLabel)
        view.addSubview(effectView)
    }
    
    func getNoOfUpdates() {
        activityIndicator("Please Wait")
        AF.request("https://schools-live.com/app/apis/getNoOfUpdates.php")
            .validate()
            .responseString { response in
                
                switch(response.result) {
                    case .success(let data):
                        
                        if data.contains("Got Result<br>") {
                            let newData = data.replacingOccurrences(of: "Got Result<br>", with: "")
                            
                            if let store = (newData as NSString).data(using: String.Encoding.utf8.rawValue) {
                                do {
                                    let json = try JSON(data: store)
                                    
                                    var name = ""
                                    var lastUpdateTime = ""
                                    var totalUpdates = 0
                                    
                                    if let jsonArray = json.array {
                                        var j = 0
                                        for i in 0..<jsonArray.count {
                                            name = jsonArray[i]["Name"].stringValue
                                            lastUpdateTime = jsonArray[i]["Last_Update_Time"].stringValue
                                            totalUpdates = jsonArray[i]["Total_Updates"].intValue
                                            
                                            j = j + 1
                                            
                                            if totalUpdates == 0 {
                                                let rank = Rank(rank: j, name: name, date: lastUpdateTime, totalUpdates: 0)
                                                self.array.append(rank)
                                                
                                            }
                                            else {
                                                let rank = Rank(rank: j, name: name, date: lastUpdateTime, totalUpdates: totalUpdates)
                                                self.array.append(rank)
                                            }
                                            
                                        }
                                        self.activityIndicator.stopAnimating()
                                        self.activityIndicator.isHidden = true
                                        self.effectView.isHidden = true
                                        self.tableView.reloadData()
                                    }
                                    
                                }
                                catch {
                                    print("Got in Catch")
                                }
                            }
                            
                        }
                        break
                    
                    case .failure(let error):
                        self.effectView.isHidden = true
                        self.createAlert(titleText: "Note", messageText: error.localizedDescription)
                        break;
                }
        }
        
    }
}
