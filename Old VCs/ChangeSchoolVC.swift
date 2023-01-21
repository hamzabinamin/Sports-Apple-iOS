//
//  ChangeSchoolVC.swift
//  Schools-Live
//
//  Created by Hamza  Amin on 10/17/17.
//  Copyright © 2017 Hamza  Amin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ChangeSchoolVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var dropDownText: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var changeSchoolButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var viewItem: UIView!
    
    var allSchoolsArray = [School] ()
    var array = [String] ()
    var filteredData = [String]()
    var isSearching = false
    var activityIndicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    var schoolType = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewItem.layer.borderColor = UIColor.black.cgColor
        viewItem.layer.borderWidth = 1
        
        changeSchoolButton.layer.cornerRadius = 20
        changeSchoolButton.clipsToBounds = true
        changeSchoolButton.isHidden = true
        
        searchBar.delegate = self

        if isConnectedToNetwork() {
            getSchools()
        }
        else {
             createAlert(titleText: "Note", messageText: "Please connect to the Internet")
        }
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
    
   
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredData.count
        }
        else {
            return array.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if isSearching {
            cell?.textLabel?.text = filteredData[indexPath.row]
        }
        else {
            cell?.textLabel?.text = array[indexPath.row]
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        dropDownText.text = cell?.textLabel?.text
        viewItem.isHidden = true
        view.endEditing(true)
        searchBar.text = ""
        isSearching = false
        tableView.reloadData()
        changeSchool()
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
            view.endEditing(true)
            tableView.reloadData()
        }
        else {
            isSearching = true
          /*  filteredData = array.filter( {$0.range(of: searchText, options: [.anchored, .caseInsensitive, .diacriticInsensitive]) != nil} ) */
             filteredData = array.filter( {$0.lowercased().contains(searchText.lowercased())} )
            tableView.reloadData()
        }
        
    }
    
    func createAlert(titleText: String, messageText: String) {
        let alert = UIAlertController(title: titleText, message: messageText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func openMenu(_ sender: UIButton) {
        print("Button Clicked")
        NotificationCenter.default.post(name: NSNotification.Name("toggleSideMenu"), object: nil)
        
    }
    @IBAction func showDropDown(_ sender: Any) {
        viewItem.isHidden = false
    }
    
    
    @IBAction func changeSchool(_ sender: Any) {
        changeSchool()
    }

    func changeSchool() {
        if dropDownText.text.count > 0 {
            var schoolName = dropDownText.text.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if schoolName.contains("High School") && !schoolName.contains("Pri") {
                schoolName = schoolName.replacingOccurrences(of: "(High School)", with: "")
                schoolType = "High School"
            }
            else if schoolName.contains("Primary School") {
                schoolName = schoolName.replacingOccurrences(of: "(Primary School)", with: "")
                schoolType = "Primary School"
            }
            else if schoolName.contains("College") {
                schoolName = schoolName.replacingOccurrences(of: "(College)", with: "")
                schoolType = "College"
            }
            else if schoolName.contains("Pri-High School") {
                schoolName = schoolName.replacingOccurrences(of: "(Pri-High School)", with: "")
                schoolType = "Pri-High School"
            }
            
            if let row = allSchoolsArray.firstIndex(where: {$0.schoolName == schoolName.trimmingCharacters(in: .whitespacesAndNewlines) && $0.schoolType == schoolType.trimmingCharacters(in: .whitespacesAndNewlines)}) {
                let selectedSchool = allSchoolsArray[row]
                saveSchool(school: selectedSchool)
                createAlert(titleText: "School Changed", messageText: "School Changed Successfully")
                NotificationCenter.default.post(name: NSNotification.Name("changeSchoolImage"), object: nil)
                
            }
        }
        else {
            createAlert(titleText: "Note", messageText: "Please select a School")
        }
    }
    
    @IBAction func closeView(_ sender: Any) {
        viewItem.isHidden = true
        searchBar.text = ""
        isSearching = false
        tableView.reloadData()
    }
    
    func getSchools() {
        effectView.isHidden = false
        activityIndicator("Please Wait")
        AF.request("https://schools-live.com/app/apis/getSchools.php")
            .validate()
            .responseString { response in
                
                switch(response.result) {
                    case .success(let data):
                        if data.contains("Got Result<br>") {
                            let newData = data.replacingOccurrences(of: "Got Result<br>", with: "")
                            
                            if let store = (newData as NSString).data(using: String.Encoding.utf8.rawValue) {
                                do {
                                    let json = try JSON(data: store)
                                    
                                    if let jsonArray = json.array {
                                        var schoolID = ""
                                        var schoolName = ""
                                        var schoolType = ""
                                        var schoolLocation = ""
                                        var schoolWebsite = ""
                                        var schoolTwitter = ""
                                        var schoolFacebook = ""
                                        var schoolLogo = ""
                                        for i in 0..<jsonArray.count {
                                            schoolID = jsonArray[i]["School_ID"].stringValue
                                            schoolName = jsonArray[i]["School_Name"].stringValue
                                            schoolType = jsonArray[i]["School_Type"].stringValue
                                            schoolLocation = jsonArray[i]["School_Location"].stringValue
                                            schoolWebsite = jsonArray[i]["School_Website"].stringValue
                                            schoolTwitter = jsonArray[i]["School_Twitter"].stringValue
                                            schoolFacebook = jsonArray[i]["School_Facebook"].stringValue
                                            schoolLogo = jsonArray[i]["School_Logo"].stringValue
                                            self.array.append(schoolName + " " + "(" + schoolType + ")" )
                                            self.allSchoolsArray.append(School(schoolID: schoolID, schoolName: schoolName, schoolType: schoolType, schoolLocation: schoolLocation, schoolCountry: "", schoolImage: schoolLogo))
                                        }
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
