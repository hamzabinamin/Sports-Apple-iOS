//
//  AddGameVC.swift
//  Schools-Live
//
//  Created by Hamza  Amin on 11/19/17.
//  Copyright © 2017 Hamza  Amin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AddGameOldVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDataSource , UITableViewDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var viewItem: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var addGameButton: UIButton!
    @IBOutlet weak var awayAgeGroupButton: UIButton!
    @IBOutlet weak var awayTeamButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var homeSchoolTV: UITextView!
    @IBOutlet weak var awaySchoolTV: UITextView!
    @IBOutlet weak var gameCategoryTextView: UITextView!
    @IBOutlet weak var sportTV: UITextView!
    @IBOutlet weak var homeAgeGroupTV: UITextView!
    @IBOutlet weak var homeTeamTV: UITextView!
    @IBOutlet weak var awayAgeGroupTV: UITextView!
    @IBOutlet weak var awayTeamTV: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var gameCategoryView: UIView!
    @IBOutlet weak var checkBox: VKCheckbox!
    
   // var user = User()
    var schoolArray = [String] ()
    var filteredData = [String] ()
    var allSchoolsArray = [School] ()
    var gameCategoryArray = ["Boys", "Girls"]
    var sportArray = ["Basketball", "Rugby", "Cricket", "Hockey", "Netball", "Soccer", "Water polo", "Sevens"]
    var ageGroupArray = ["U/6", "U/7", "U/8", "U/9", "U/10", "U/11", "U/12", "U/13", "U/14", "U/15", "U/16", "U/17", "U/18", "U/19"]
    var teamArray = ["A", "B", "C", "D", "E", "F", "G", "H"]
    var homeSchoolCalled = false
    var awaySchoolCalled = false
    var gameCategoryCalled = false
    var sportCalled = false
    var ageGroupCalled = false
    var teamCalled = false
    var ageGroupAwayCalled = false
    var teamAwayCalled = false
    var isSearching = false
    let messageFrame = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewItem.layer.borderColor = UIColor.black.cgColor
        viewItem.layer.borderWidth = 1

        pickerView.delegate = self
        pickerView.dataSource = self
        searchBar.delegate = self
        
        addGameButton.layer.cornerRadius = 20
        addGameButton.clipsToBounds = true
        
        //UIColor.init(red: 241, green: 74, blue: 102, alpha: 1)
        checkBox.color = UIColor.red
       
        checkBox.checkboxValueChangedBlock = {
            isOn in
            
            if isOn {
                self.awayAgeGroupTV.alpha = 0.5
                self.awayAgeGroupTV.isSelectable = false
                self.awayAgeGroupButton.alpha = 0.5
                self.awayAgeGroupButton.isEnabled = false
                self.awayTeamTV.alpha = 0.5
                self.awayTeamTV.isSelectable = false
                self.awayTeamButton.alpha = 0.5
                self.awayTeamButton.isEnabled = false
            }
            else {
                self.awayAgeGroupTV.alpha = 1
                self.awayAgeGroupTV.isSelectable = true
                self.awayAgeGroupButton.alpha = 1
                self.awayAgeGroupButton.isEnabled = true
                self.awayTeamTV.alpha = 1
                self.awayTeamTV.isSelectable = true
                self.awayTeamButton.alpha = 1
                self.awayTeamButton.isEnabled = true
            }
            
            print("Custom checkbox is \(isOn ? "ON" : "OFF")")
        }
        
        DispatchQueue.main.async {
            let screenSize = UIScreen.main.bounds
            self.scrollView.contentSize = CGSize(width: screenSize.width, height: screenSize.height)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(pickerTapped))
        tap.delegate = self
        self.pickerView.addGestureRecognizer(tap)
        
        if isConnectedToNetwork() {
            getSchools()
        }
        else {
            createAlert(titleText: "Note", messageText: "Please connect to the Internet")
        }
        
        datePicker.locale = Locale(identifier: "en_US")
        
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        
        self.hideKeyboard()
    }
    
    @objc func pickerTapped(tapRecognizer: UITapGestureRecognizer) {
            print("Tapped")
        if tapRecognizer.state == .ended {
            print("Tapped inside If")
            let rowHeight = self.pickerView.rowSize(forComponent: 0).height
            let selectedRowFrame = self.pickerView.bounds.insetBy(dx: 0, dy: (self.pickerView.frame.height - rowHeight) / 2)
            let userTappedOnSelectedRow = selectedRowFrame.contains(tapRecognizer.location(in: self.pickerView))
            if userTappedOnSelectedRow {
                let selectedRow = self.pickerView.selectedRow(inComponent: 0)
                pickerView(self.pickerView, didSelectRow: selectedRow, inComponent: 0)
                pickerView.isHidden = true
            }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if sportCalled == true {
            print("Sport Count")
            return sportArray.count
        }
        else if ageGroupCalled == true {
            print("Age Group Count")
            return ageGroupArray.count
        }
        else if teamCalled == true {
            print("Team Count")
            return teamArray.count
        }
        else if ageGroupAwayCalled == true {
            print("Age Group Count")
            return ageGroupArray.count
        }
        else if teamAwayCalled == true {
            print("Team Count")
            return teamArray.count
        }
        else if gameCategoryCalled == true {
            return gameCategoryArray.count
        }
        print("No Count")
        return -1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        self.view.endEditing(true)
        if sportCalled == true {
            print("Sport Data")
            return sportArray[row]
        }
        else if ageGroupCalled == true {
            print("Age Group Data")
            return ageGroupArray[row]
        }
        else if teamCalled == true {
            print("Team Data")
            return teamArray[row]
        }
        else if ageGroupAwayCalled == true {
            print("Age Group Data")
            return ageGroupArray[row]
        }
        else if teamAwayCalled == true {
            print("Team Data")
            return teamArray[row]
        }
        else if gameCategoryCalled == true {
            return gameCategoryArray[row]
        }
        else {
            print("No Data")
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if sportCalled == true {
            print("Sport Picker Called")
            sportTV.text = sportArray[row]
            pickerView.isHidden = true
            addGameButton.isHidden = false
            sportCalled = false
        }
        else if ageGroupCalled == true {
            print("Age Group Picker Called")
            homeAgeGroupTV.text = ageGroupArray[row]
            pickerView.isHidden = true
            addGameButton.isHidden = false
            ageGroupCalled = false
        }
        else if teamCalled == true {
            print("Team Picker Called")
            homeTeamTV.text = teamArray[row]
            pickerView.isHidden = true
            addGameButton.isHidden = false
            teamCalled = false
        }
        else if ageGroupAwayCalled == true {
            print("Age Group Picker Called")
            awayAgeGroupTV.text = ageGroupArray[row]
            pickerView.isHidden = true
            addGameButton.isHidden = false
            ageGroupAwayCalled = false
        }
        else if teamAwayCalled == true {
            print("Team Picker Called")
            awayTeamTV.text = teamArray[row]
            pickerView.isHidden = true
            addGameButton.isHidden = false
            teamAwayCalled = false
        }
        else if gameCategoryCalled == true {
            gameCategoryTextView.text = gameCategoryArray[row]
            pickerView.isHidden = true
            addGameButton.isHidden = false
            gameCategoryCalled = false
        }
        else {
            print("Nothing is true for Picker")
        }
     }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredData.count
        }
        else {
            if homeSchoolCalled == true || awaySchoolCalled == true {
                return schoolArray.count
            }
            else {
                return -1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if isSearching {
            cell?.textLabel?.text = filteredData[indexPath.row]
        }
        else {
            if homeSchoolCalled == true || awaySchoolCalled == true {
                cell?.textLabel?.text = schoolArray[indexPath.row]
            }
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if homeSchoolCalled == true {
            homeSchoolTV.text = cell?.textLabel?.text
            homeSchoolCalled = false
        }
        else if awaySchoolCalled == true {
            awaySchoolTV.text = cell?.textLabel?.text
            awaySchoolCalled = false
        }
        viewItem.isHidden = true
        view.endEditing(true)
        searchBar.text = ""
        isSearching = false
        tableView.reloadData()
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
            view.endEditing(true)
            tableView.reloadData()
        }
        else {
            isSearching = true
            if homeSchoolCalled == true || awaySchoolCalled == true {
              /*  filteredData = schoolArray.filter( {$0.range(of: searchText, options: [.anchored, .caseInsensitive, .diacriticInsensitive]) != nil} )  */
                filteredData = schoolArray.filter( {$0.lowercased().contains(searchText.lowercased())} )
                tableView.reloadData()
            }
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
    
    func createAlert(titleText: String, messageText: String) {
        
        let alert = UIAlertController(title: titleText, message: messageText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }

    func validation() -> Bool {
        let homeSchool = homeSchoolTV.text!
        let awaySchool = awaySchoolTV.text!
        let gameCategory = gameCategoryTextView.text!
        let sport = sportTV.text!
        var ageGroup = ""
        var team = ""
        
        if(checkBox.isOn()) {
            ageGroup = homeAgeGroupTV.text + "-" + homeAgeGroupTV.text
            team = homeTeamTV.text + "-" + homeTeamTV.text
        }
        else {
            ageGroup = homeAgeGroupTV.text + "-" + awayAgeGroupTV.text
            team = homeTeamTV.text + "-" + awayTeamTV.text
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "d-M-yyyy / HH:mm a"
       // var dateAndTime = formatter.string(from: datePicker.date)
       // let date = Date()
      //  let currentCalendar = Calendar.current
        let selectedDate = datePicker.date
        let currentDate = Date()
        print("Agegroup: " + ageGroup)
        print("Team: " + team)
        if homeSchool.count > 0 && awaySchool.count > 0 && gameCategory.count > 0 && sport.count > 0 && ageGroup.count > 3 && team.count > 2 {
            
            let store = currentDate.timeIntervalSince(selectedDate) / 60
            
            if store > 1440 {
            
           // if selectedDate < currentDate {
                self.createAlert(titleText: "Note", messageText: "You can't select a date older than the current date")
                return false
            }
            else {
            if homeSchool == awaySchool {
                self.createAlert(titleText: "Note", messageText: "Home & Away Schools can't be same")
                return false
                }
            }
            return true
        }
        else {
            self.createAlert(titleText: "Note", messageText: "Please fill all the fields")
            return false
        }
    }
    
    func getUser() -> User? {
        if let data = UserDefaults.standard.data(forKey: "User"),
           let user = (NSKeyedUnarchiver.unarchiveObject(with: data) as? User?) {
            //myPeopleList.forEach({print( $0.name, $0.age)})  // Joe 10
            return user
        } else {
            print("There is an issue")
            return nil
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
                                        
                                        for i in 0..<jsonArray.count {
                                            let schoolID = jsonArray[i]["School_ID"].stringValue
                                            let schoolName = jsonArray[i]["School_Name"].stringValue
                                            let schoolType = jsonArray[i]["School_Type"].stringValue
                                            let schoolWebsite = jsonArray[i]["School_Website"].stringValue
                                            let schoolFacebook = jsonArray[i]["School_Facebook"].stringValue
                                            let schoolTwitter = jsonArray[i]["School_Twitter"].stringValue
                                            let schoolLocation = jsonArray[i]["School_Location"].stringValue
                                            let schoolLogo = jsonArray[i]["School_Logo"].stringValue
                                            self.schoolArray.append(schoolName + " " + "(" + schoolType + ")" )
                                            self.allSchoolsArray.append(School(schoolID: schoolID, schoolName: schoolName, schoolType: schoolType, schoolLocation: schoolLocation, schoolCountry: "", schoolImage: schoolLogo))
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
    
    func addGame(homeSchool: String, awaySchool: String, schoolsType: String, gameCategory: String, sport: String, ageGroup: String, team: String, startTime: String, weather: String, temperature: String, status: String, score: String, updateBy: String, updateTime: String, homeSchoolLogo: String, awaySchoolLogo: String) {
        effectView.isHidden = false
        activityIndicator("Please Wait")
        AF.request("https://www.schools-live.com/app/apis/insertGame.php", parameters: ["homeschool": homeSchool, "awayschool": awaySchool, "schoolstype": schoolsType, "category": gameCategory, "sport": sport, "agegroup": ageGroup, "team": team, "starttime": startTime, "weather": weather, "temperature": temperature, "status": status, "score": score, "updateby": updateBy, "updatetime": updateTime, "homeschoollogo": homeSchoolLogo, "awayschoollogo": awaySchoolLogo])
            .validate()
            .responseString { response in
                
                switch(response.result) {
                    case .success(let data):
                        if data.contains("New record created successfully") {
                            self.effectView.isHidden = true
                            self.createAlert(titleText: "Successful", messageText: "New Game Created Successfully")
                            
                        }
                        else {
                            self.effectView.isHidden = true
                            self.createAlert(titleText: "Note", messageText: "There was an Error")
                        }
                        break
                    
                    case .failure(let error):
                        self.effectView.isHidden = true
                        self.createAlert(titleText: "Note", messageText: error.localizedDescription)
                        break;
                }
        }
        
    }
    
    @IBAction func dropDownSport(_ sender: Any) {
        pickerView.isHidden = false
        addGameButton.isHidden = true
        sportCalled = true
        pickerView.reloadAllComponents()
        pickerView.selectRow(0, inComponent: 0, animated: true)
        //let store = pickerView.selectedRow(inComponent: 0)
        //sportTV.text = sportArray[store]
    }
    
    @IBAction func dropDownAge(_ sender: Any) {
        pickerView.isHidden = false
        addGameButton.isHidden = true
        ageGroupCalled = true
        pickerView.reloadAllComponents()
        pickerView.selectRow(0, inComponent: 0, animated: true)
        //let store = pickerView.selectedRow(inComponent: 0)
        //ageGroupTV.text = ageGroupArray[store]
    }
    
    @IBAction func dropDownAwayAge(_ sender: Any) {
        pickerView.isHidden = false
        addGameButton.isHidden = true
        ageGroupAwayCalled = true
        pickerView.reloadAllComponents()
        pickerView.selectRow(0, inComponent: 0, animated: true)
        //let store = pickerView.selectedRow(inComponent: 0)
        //ageGroupTV.text = ageGroupArray[store]
    }
    
    @IBAction func dropDownTeam(_ sender: Any) {
        pickerView.isHidden = false
        addGameButton.isHidden = true
        teamCalled = true
        pickerView.reloadAllComponents()
        pickerView.selectRow(0, inComponent: 0, animated: true)
        //let store = pickerView.selectedRow(inComponent: 0)
        //teamTV.text = teamArray[store]
    }
    
    @IBAction func dropDownAwayTeam(_ sender: Any) {
        pickerView.isHidden = false
        addGameButton.isHidden = true
        teamAwayCalled = true
        pickerView.reloadAllComponents()
        pickerView.selectRow(0, inComponent: 0, animated: true)
        //let store = pickerView.selectedRow(inComponent: 0)
        //teamTV.text = teamArray[store]
    }
    
    @IBAction func dropDownHomeSchool(_ sender: Any) {
       viewItem.isHidden = false
       homeSchoolCalled = true
       tableView.reloadData()
    }
    
    @IBAction func dropDownAwaySchool(_ sender: Any) {
       viewItem.isHidden = false
       awaySchoolCalled = true
       tableView.reloadData()
    }
    
    @IBAction func dropDownGameCategory(_ sender: Any) {
        pickerView.isHidden = false
        addGameButton.isHidden = true
        gameCategoryCalled = true
        pickerView.reloadAllComponents()
        pickerView.selectRow(0, inComponent: 0, animated: true)
        //let store = pickerView.selectedRow(inComponent: 0)
        //gameCategoryTextView.text = gameCategoryArray[store]
    }
    
    
    @IBAction func addGame(_ sender: Any) {
        if(validation()) {
            var homeSchool = homeSchoolTV.text!
            var awaySchool = awaySchoolTV.text!
            var homeSchoolType = ""
            var awaySchoolType = ""
            let sport = sportTV.text!
            var ageGroup = ""
            var team = ""
            
            if(checkBox.isOn()) {
                ageGroup = homeAgeGroupTV.text + "-" + homeAgeGroupTV.text
                team = homeTeamTV.text + "-" + homeTeamTV.text
            }
            else {
                ageGroup = homeAgeGroupTV.text + "-" + awayAgeGroupTV.text
                team = homeTeamTV.text + "-" + awayTeamTV.text
            }
            
            let category = gameCategoryTextView.text!
            let status = "NOT STARTED"
            let temperature = "+25°C"
            let weather = "Sunshine"
            var score = ""
            if sport == "Cricket" {
                score = "0/0"
            }
            else {
                score = "0 - 0"
            }
            let updateTime = Date().preciseGMTTime
            let updateBy = getUser()?.getFullName()
            let formatter = DateFormatter()
            formatter.dateFormat = "d-M-yyyy / hh:mm a"
            formatter.locale = Locale(identifier: "en_US")
            formatter.timeZone = TimeZone(identifier: "UTC")
            let gameDate = formatter.string(from: datePicker.date)
            
            
           
            if homeSchool.contains("High School") && !homeSchool.contains("Pri-High School") {
                homeSchool = homeSchool.replacingOccurrences(of: "(High School)", with: "")
                homeSchoolType = "High School"
            }
            else if homeSchool.contains("Primary School") {
                homeSchool = homeSchool.replacingOccurrences(of: "(Primary School)", with: "")
                homeSchoolType = "Primary School"
            }
            else if homeSchool.contains("College") {
                homeSchool = homeSchool.replacingOccurrences(of: "(College)", with: "")
                homeSchoolType = "College"
            }
            else if homeSchool.contains("Pri-High School") {
                homeSchool = homeSchool.replacingOccurrences(of: "(Pri-High School)", with: "")
                homeSchoolType = "Pri-High School"
            }
            
            if awaySchool.contains("High School") && !awaySchool.contains("Pri-High School") {
                awaySchool = awaySchool.replacingOccurrences(of: "(High School)", with: "")
                awaySchoolType = "High School"
            }
            else if awaySchool.contains("Primary School") {
                awaySchool = awaySchool.replacingOccurrences(of: "(Primary School)", with: "")
                awaySchoolType = "Primary School"
            }
            else if awaySchool.contains("College") {
                awaySchool = awaySchool.replacingOccurrences(of: "(College)", with: "")
                awaySchoolType = "College"
            }
            else if awaySchool.contains("Pri-High School") {
                awaySchool = awaySchool.replacingOccurrences(of: "(Pri-High School)", with: "")
                awaySchoolType = "Pri-High School"
            }
            var homeSchoolURL = ""
            var awaySchoolURL = ""
            
            if let row = allSchoolsArray.index(where: {$0.schoolName.trimmingCharacters(in: .whitespacesAndNewlines) == homeSchool.trimmingCharacters(in: .whitespacesAndNewlines)}) {
                homeSchoolURL = allSchoolsArray[row].schoolImage
            }
            if let row = allSchoolsArray.firstIndex(where: {$0.schoolName.trimmingCharacters(in: .whitespacesAndNewlines) == awaySchool.trimmingCharacters(in: .whitespacesAndNewlines)}) {
                awaySchoolURL = allSchoolsArray[row].schoolImage
            }
            if homeSchoolURL.contains("http") {
                homeSchoolURL = homeSchoolURL.replacingOccurrences(of: "http", with: "")
            }
            if awaySchoolURL.contains("http") {
                awaySchoolURL = awaySchoolURL.replacingOccurrences(of: "http", with: "")
            }
            
            
           
            print("Home School URL: ", homeSchoolURL)
            print("Away School URL: ", awaySchoolURL)
            
         
            let schoolsType = homeSchoolType + "/" + awaySchoolType
            
      /*      homeSchool = String(utf8String: homeSchool.cString(using: .utf8)!)!
            awaySchool = String(utf8String: awaySchool.cString(using: .utf8)!)!
            schoolsType = String(utf8String: schoolsType.cString(using: .utf8)!)!
            sport = String(utf8String: sport.cString(using: .utf8)!)!
            ageGroup = String(utf8String: ageGroup.cString(using: .utf8)!)!
            team = String(utf8String: team.cString(using: .utf8)!)!
            field = String(utf8String: field.cString(using: .utf8)!)!
            status = String(utf8String: status.cString(using: .utf8)!)!
            temperature = String(utf8String: temperature.cString(using: .utf8)!)!
            weather = String(utf8String: weather.cString(using: .utf8)!)!
            score = String(utf8String: score.cString(using: .utf8)!)!
            gameDate = String(utf8String: gameDate.cString(using: .utf8)!)!
            updateTime = String(utf8String: updateTime.cString(using: .utf8)!)!
            updateBy = String(utf8String: (updateBy?.cString(using: .utf8))!)!
            homeSchoolURL = String(utf8String: (homeSchoolURL?.cString(using: .utf8))!)!
            awaySchoolURL = String(utf8String: (awaySchoolURL?.cString(using: .utf8))!)! */
            
            if isConnectedToNetwork() {
            addGame(homeSchool: homeSchool, awaySchool: awaySchool, schoolsType: schoolsType, gameCategory: category, sport: sport, ageGroup: ageGroup, team: team, startTime: gameDate, weather: weather, temperature: temperature, status: status, score: score, updateBy: updateBy!, updateTime: updateTime, homeSchoolLogo: homeSchoolURL, awaySchoolLogo: awaySchoolURL)
            }
            else {
                createAlert(titleText: "Note", messageText: "Please connect to the Internet")
            }
        }
        
    }
    
    @IBAction func goBack(_ sender: Any) {
      /*  let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ContainerVC")
        //self.present(vc, animated: true, completion: nil)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = vc */
        self.navigationController?.popViewController(animated: true)
    }
}

extension Date {
    // you can create a read-only computed property to return just the nanoseconds from your date time
    var nanosecond: Int { return Calendar.current.component(.nanosecond,  from: self)   }
    // the same for your local time
    var preciseLocalTime: String {
        return Formatter.preciseLocalTime.string(for: self) ?? ""
    }
    // or GMT time
    var preciseGMTTime: String {
        return Formatter.preciseGMTTime.string(for: self) ?? ""
    }
}

extension Formatter {
    // create static date formatters for your date representations
    static let preciseLocalTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "d-M-yyyy / hh:mm a"
        return formatter
    }()
    static let preciseGMTTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "d-M-yyyy / hh:mm a"
        return formatter
    }()
}
