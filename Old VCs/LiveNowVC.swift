//
//  LiveNowVC.swift
//  Schools-Live
//
//  Created by Hamza  Amin on 12/9/17.
//  Copyright © 2017 Hamza  Amin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LiveNowVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var schoolTypeLabel: UILabel!
    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var schoolLocationLabel: UILabel!
    @IBOutlet weak var schoolWebsiteLabel: UILabel!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    var array = [Game] ()
    var notificationArray = [Game] ()
    var school: School?
    let messageFrame = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(willEnterForeground), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    @objc func willEnterForeground() {
        print("Live now entered Foreground")
        
        if self.isViewLoaded && (self.view.window != nil) {
        school = retrieveSchool()
        
        if school == nil {
            
             DispatchQueue.main.async {
                self.createAlert(titleText: "Note", messageText: "Either add a new School or Select existing one from  Change School")
            }
        }
        else {
            schoolTypeLabel.text = school?.schoolType
            schoolNameLabel.text = school?.schoolName
            schoolLocationLabel.text = school?.schoolLocation
          //  schoolWebsiteLabel.text = school?.schoolWebsite
            let parameters = ["home": school?.schoolName, "away": school?.schoolName]
            array.removeAll()
            tableView.reloadData()
            if isConnectedToNetwork() {
                getGames(url: "https://schools-live.com/app/apis/getAllLiveGames.php", parameters: parameters as! [String : String])
            }
            else {
                 DispatchQueue.main.async {
                    self.createAlert2(titleText: "Note", messageText: "Please connect to the Internet")
                }
            }
        }
        }
        else {
            print("Live Now is NOT visible")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        school = retrieveSchool()
        
        if school == nil {
            
             DispatchQueue.main.async {
                self.createAlert(titleText: "Note", messageText: "Either add a new School or Select existing one from  Change School")
            }
        }
        else {
            schoolTypeLabel.text = school?.schoolType
            schoolNameLabel.text = school?.schoolName
            schoolLocationLabel.text = school?.schoolLocation
           // schoolWebsiteLabel.text = school?.schoolWebsite
            let parameters = ["home": school?.schoolName, "away": school?.schoolName]
            array.removeAll()
            tableView.reloadData()
            if isConnectedToNetwork() {
                getGames(url: "https://schools-live.com/app/apis/getAllLiveGames.php", parameters: parameters as! [String : String])
            }
            else {
                createAlert2(titleText: "Note", messageText: "Please connect to the Internet")
            }
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if array[indexPath.row].sport == "Cricket" {
              let cell = tableView.dequeueReusableCell(withIdentifier: "gamecellcricket", for: indexPath) as! gameCricketTVCell
            
            cell.homeSchoolNameLabel.text = array[indexPath.row].homeSchoolName.trimmingCharacters(in: .whitespacesAndNewlines)
            cell.awaySchoolNameLabel.text = array[indexPath.row].awaySchoolName.trimmingCharacters(in: .whitespacesAndNewlines)
            let store = array[indexPath.row].schoolsType.components(separatedBy: "/")
            cell.homeSchoolTypeLabel.text = store[0]
            cell.awaySchoolTypeLabel.text = store[1]
            let encoded = array[indexPath.row].homeSchoolImageURL.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
            var url = URL(string: "http" + encoded!)
            cell.homeSchoolImage.kf.setImage(with: url,  placeholder: #imageLiteral(resourceName: "Place Holder"))
            let encoded2 = array[indexPath.row].awaySchoolImageURL.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
            url = URL(string: "http" + encoded2!)
            cell.awaySchoolImage.kf.setImage(with: url,  placeholder: #imageLiteral(resourceName: "Place Holder"))
            cell.gameTimeLabel.text = UTCToLocal(date: array[indexPath.row].startTime)
            cell.lastUpdateByLabel.text = array[indexPath.row].lastUpdateBy
            cell.gameStatus.text = array[indexPath.row].status
           // cell.homeTeamScoreLabel.adjustsFontSizeToFitWidth = true
           // cell.awayTeamScoreLabel.adjustsFontSizeToFitWidth = true
           // cell.homeTeamOverLabel.adjustsFontSizeToFitWidth = true
           // cell.awayTeamOverLabel.adjustsFontSizeToFitWidth = true
            
            if array[indexPath.row].chatBubble == "Yes" {
                cell.chatBubble.isHidden = false
            }
            else {
                cell.chatBubble.isHidden = true
            }
            
            if array[indexPath.row].ageGroup.contains("-") && array[indexPath.row].team.contains("-") {
                let game = array[indexPath.row]
                let ageGroupArray = game.ageGroup.split(separator: "-")
                let teamArray = game.team.split(separator: "-");
                cell.homeSchoolAgeTeamL.text = ageGroupArray[0] + "/" + teamArray[0]
                cell.awaySchoolAgeTeamL.text = ageGroupArray[1] + "/" + teamArray[1]
            }
            else {
                let game = array[indexPath.row]
                cell.homeSchoolAgeTeamL.text = game.ageGroup + "/" + game.team
                cell.awaySchoolAgeTeamL.text = game.ageGroup + "/" + game.team
            }
            
            var category = array[indexPath.row].category
            
            if category == "Boys" {
                category = "(B)"
            }
            else if category == "Girls" {
                category = "(G)"
            }
            
            do {
                if let notification = UserDefaults.standard.object(forKey: "Notification Array") as? Data {
                    if let storedNotification = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, Game.self], from: notification) as? [Game] {
                        let index = storedNotification.firstIndex(where: {$0.gameID == array[indexPath.row].gameID })
                        if index != -1 && index != nil {
                            print("Game is present in notification list")
                            cell.notificationButton.setBackgroundImage(UIImage(named: "Alarm Colored"), for: .normal)
                        }
                        else {
                            print("Game is not present in notification list")
                            cell.notificationButton.setBackgroundImage(UIImage(named: "Alarm"), for: .normal)
                        }
                    }
                }
            }
            catch {
                print(error)
            }
         
            cell.gameNameLabel.text = category + " " + array[indexPath.row].sport
            
            let cricGame = array[indexPath.row]
            
            if (cricGame.score.contains("*")) {
                let bothScores = cricGame.score.components(separatedBy: "*")
                let homeTeamScore = bothScores[0]
                let awayTeamScore = bothScores[1]
                let homeTeamScore2 = homeTeamScore.components(separatedBy: "/")
                let awayTeamScore2 = awayTeamScore.components(separatedBy: "/")
                cell.homeSchoolBatBowlL.isHidden = false
                cell.awaySchoolBatBowlL.isHidden = false
                
                cell.homeTeamScoreLabel.text = homeTeamScore2[0].trimmingCharacters(in: .whitespacesAndNewlines) + "/" + homeTeamScore2[1].trimmingCharacters(in: .whitespacesAndNewlines)
                cell.homeTeamOverLabel.text = "Over: " + homeTeamScore2[4]
                
                cell.awayTeamScoreLabel.text = awayTeamScore2[0].trimmingCharacters(in: .whitespacesAndNewlines) + "/" + awayTeamScore2[1].trimmingCharacters(in: .whitespacesAndNewlines)
                cell.awayTeamOverLabel.text = "Over: " + awayTeamScore2[4]
                
                let home = array[indexPath.row].homeSchoolName.trimmingCharacters(in: .whitespacesAndNewlines)
                
                if home == homeTeamScore2[2].trimmingCharacters(in: .whitespacesAndNewlines) {
                    cell.homeSchoolBatBowlL.text = "(Bat)";
                    cell.awaySchoolBatBowlL.text = "(Bowl)";
                }
                else {
                    cell.homeSchoolBatBowlL.text = "(Bowl)";
                    cell.awaySchoolBatBowlL.text = "(Bat)";
                }
                
            }
            else {
                cell.homeTeamScoreLabel.text = "0/0"
                cell.homeTeamOverLabel.text = "Over: 0"
                cell.awayTeamScoreLabel.text = "0/0"
                cell.awayTeamOverLabel.text = "Over: 0"
                cell.homeSchoolBatBowlL.isHidden = true
                cell.awaySchoolBatBowlL.isHidden = true
            }
            
            cell.updateGameButton.tag = indexPath.row
            cell.updateGameButton.addTarget(self, action: #selector(LiveNowVC.updateGame(_:)), for: .touchUpInside)
            
            return cell
        }
        else {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gamecell", for: indexPath) as! GameTVCell
        
        print("Home School Name: ", array[indexPath.row].homeSchoolName)
        print("Away School Name: ", array[indexPath.row].awaySchoolName)
        print("Game: ", array[indexPath.row].sport + " " + array[indexPath.row].ageGroup + "/" + array[indexPath.row].team)
        
        cell.homeSchoolNameLabel.text = array[indexPath.row].homeSchoolName
        cell.awaySchoolNameLabel.text = array[indexPath.row].awaySchoolName
        let store = array[indexPath.row].schoolsType.components(separatedBy: "/")
        cell.homeSchoolTypeLabel.text = store[0]
        cell.awaySchoolTypeLabel.text = store[1]
        let encoded = array[indexPath.row].homeSchoolImageURL.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
        var url = URL(string: "http" + encoded!)
        cell.homeSchoolImage.kf.setImage(with: url,  placeholder: #imageLiteral(resourceName: "Place Holder"))
        let encoded2 = array[indexPath.row].awaySchoolImageURL.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
        url = URL(string: "http" + encoded2!)
        cell.awaySchoolImage.kf.setImage(with: url,  placeholder: #imageLiteral(resourceName: "Place Holder"))
        cell.gameTimeLabel.text = UTCToLocal(date: array[indexPath.row].startTime)
        cell.lastUpdateByLabel.text = array[indexPath.row].lastUpdateBy
        cell.gameStatus.text = array[indexPath.row].status
        
        if array[indexPath.row].chatBubble == "Yes" {
            cell.chatBubble.isHidden = false
        }
        else {
            cell.chatBubble.isHidden = true
        }
            
        if array[indexPath.row].ageGroup.contains("-") && array[indexPath.row].team.contains("-") {
            let game = array[indexPath.row]
            let ageGroupArray = game.ageGroup.split(separator: "-")
            let teamArray = game.team.split(separator: "-");
            cell.homeSchoolAgeTeamL.text = ageGroupArray[0] + "/" + teamArray[0]
            cell.awaySchoolAgeTeamL.text = ageGroupArray[1] + "/" + teamArray[1]
        }
        else {
            let game = array[indexPath.row]
            cell.homeSchoolAgeTeamL.text = game.ageGroup + "/" + game.team
            cell.awaySchoolAgeTeamL.text = game.ageGroup + "/" + game.team
        }
        
        var category = array[indexPath.row].category
        
        if category == "Boys" {
            category = "(B)"
        }
        else if category == "Girls" {
            category = "(G)"
        }
        
        do {
            if let notification = UserDefaults.standard.object(forKey: "Notification Array") as? Data {
                if let storedNotification = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, Game.self], from: notification) as? [Game] {
                    let index = storedNotification.firstIndex(where: {$0.gameID == array[indexPath.row].gameID })
                    if index != -1 && index != nil {
                        print("Game is present in notification list")
                        cell.notificationButton.setBackgroundImage(UIImage(named: "Alarm Colored"), for: .normal)
                    }
                    else {
                        print("Game is not present in notification list")
                        cell.notificationButton.setBackgroundImage(UIImage(named: "Alarm"), for: .normal)
                    }
                }
            }
        }
        catch {
            print(error)
        }

        cell.gameNameLabel.text = category + " " + array[indexPath.row].sport
        
        if array[indexPath.row].sport == "Cricket" {
            let cricStore = array[indexPath.row].score.components(separatedBy: "/")
            
            if cricStore.count == 5 {
                cell.overLabel.isHidden = false
                cell.homeSchoolBatBowlL.isHidden = false
                cell.awaySchoolBatBowlL.isHidden = false
                cell.overLabel.text = "Over: " + cricStore[4]
                cell.gameScoreLabel.text = cricStore[0].trimmingCharacters(in: .whitespacesAndNewlines) + "/" + cricStore[1].trimmingCharacters(in: .whitespacesAndNewlines)
                
                let home = array[indexPath.row].homeSchoolName
                
                if home == cricStore[2] {
                    cell.homeSchoolBatBowlL.text = "(Bat)"
                    cell.awaySchoolBatBowlL.text = "(Bowl)"
                }
                else {
                    cell.homeSchoolBatBowlL.text = "(Bowl)"
                    cell.awaySchoolBatBowlL.text = "(Bat)"
                }
                
                let status = array[indexPath.row].status
                let game = array[indexPath.row].sport
                
                if status == "ENDED" && game == "Cricket" {
                    let whoWon = array[indexPath.row].whoWon
                    cell.homeSchoolBatBowlL.isHidden = false
                    cell.awaySchoolBatBowlL.isHidden = false
                    if whoWon == home {
                        cell.homeSchoolBatBowlL.text = "WON"
                        cell.awaySchoolBatBowlL.text = "LOST"
                    }
                    else {
                        cell.homeSchoolBatBowlL.text = "LOST"
                        cell.awaySchoolBatBowlL.text = "WON"
                    }
                }
                
            }
            else {
                cell.overLabel.isHidden = true
                cell.homeSchoolBatBowlL.isHidden = true
                cell.awaySchoolBatBowlL.isHidden = true
                cell.gameScoreLabel.text = array[indexPath.row].score
            }
        }
        else {
            cell.overLabel.isHidden = true
            cell.homeSchoolBatBowlL.isHidden = true
            cell.awaySchoolBatBowlL.isHidden = true
            cell.gameScoreLabel.text = array[indexPath.row].score
            
        }
        
        cell.updateGameButton.tag = indexPath.row
        cell.updateGameButton.addTarget(self, action: #selector(LiveNowVC.updateGame(_:)), for: .touchUpInside)
        
        cell.notificationButton.tag = indexPath.row
        cell.notificationButton.addTarget(self, action: #selector(LiveNowVC.updateGame(_:)), for: .touchUpInside)
        
        return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)  {
        if editingStyle == .delete {
            let game = array[indexPath.row]
            array.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            tableView.reloadData()
            
            if isConnectedToNetwork() {
                deleteGame(gameID: game.gameID)
            }
            else {
                createAlert2(titleText: "Note", messageText: "Please connect to the Internet")
            }
        }
    }
    
    func deleteGame(gameID: String) {
        effectView.isHidden = false
        activityIndicator("Please Wait")
        AF.request("https://www.schools-live.com/app/apis/deleteGame.php", parameters: ["id": gameID])
            .validate()
            .responseString { response in
                
                switch(response.result) {
                    case .success(let data):
                        if data.contains("Game deleted successfully") {
                            self.effectView.isHidden = true
                            self.createAlert2(titleText: "Game Deleted", messageText: "Game deleted successfully")
                        }
                        else {
                            self.effectView.isHidden = true
                            self.createAlert2(titleText: "Note", messageText: "Couldn't delete Game")
                        }
                        break
                    
                    case .failure(let error):
                        self.effectView.isHidden = true
                        self.createAlert2(titleText: "Note", messageText: error.localizedDescription)
                        break;
                }
                
              /*  if let data = response.result.get() {
                    
                    if data.contains("Game deleted successfully") {
                        self.effectView.isHidden = true
                        self.createAlert2(titleText: "Game Deleted", messageText: "Game deleted successfully")
                    }
                    else {
                        self.effectView.isHidden = true
                        self.createAlert2(titleText: "Note", messageText: "Couldn't delete Game")
                    }
                    
                } */
        }
    }
    
    @IBAction func openMenu(_ sender: UIButton) {
        print("Button Clicked")
        NotificationCenter.default.post(name: NSNotification.Name("toggleSideMenu"), object: nil)
    }
    
    @IBAction func updateGame(_ sender: UIButton) {
        print("Update Game Clicked")
        let data = array[sender.tag] as Game
        print("Game Score: " + data.score)
        saveSelectedUpdateGame(game: data)
       // let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "UpdateCricketGame") as! ChangeSchoolVC
      //  self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    @IBAction func addGameToNotification(_ sender: UIButton) {
        print("Add Notification Clicked")
        let data = array[sender.tag] as Game
        
        do {
            if let notification = UserDefaults.standard.object(forKey: "Notification Array") as? Data {
                if var storedNotification = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, Game.self], from: notification) as? [Game] {
                    let index = storedNotification.firstIndex(where: {$0.gameID == data.gameID })
                    if index != -1 && index != nil {
                        storedNotification.remove(at: index!)
                        saveNotificationArray(notificationArray: storedNotification)
                        createAlert2(titleText: "Game Removed", messageText: "Game Removed from Notifications")
                        sender.setBackgroundImage(UIImage(named: "Alarm"), for: .normal)
                    }
                    else {
                        data.selectedForNotification = true
                        storedNotification.append(data)
                        saveNotificationArray(notificationArray: storedNotification)
                        createAlert2(titleText: "Game Added", messageText: "Game Added to Notifications")
                        sender.setBackgroundImage(UIImage(named: "Alarm Colored"), for: .normal)
                    }
                }
            }
            else {
                data.selectedForNotification = true
                notificationArray.append(data)
                saveNotificationArray(notificationArray: notificationArray)
                createAlert2(titleText: "Game Added", messageText: "Game Added to Notifications")
                sender.setBackgroundImage(UIImage(named: "Alarm Colored"), for: .normal)
            }
        }
        catch {
            print(error)
        }
        
  
        
        
    }
    
    @IBAction func goToResults(_ sender: UIButton) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "ResultsVC") as! ResultsVC
        self.navigationController?.pushViewController(secondViewController, animated: true) 
    }
    
    func UTCToLocal(date:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d-M-yyyy / hh:mm a"
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "d-M-yyyy / hh:mm a"
        
        return dateFormatter.string(from: dt!)
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
    
    func getGames(url: String, parameters: [String: String]) {
        effectView.isHidden = false
        activityIndicator("Please Wait")
        AF.request(url, parameters: parameters)
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
                                            let gameID = jsonArray[i]["Game_ID"].stringValue
                                            let homeSchoolName = jsonArray[i]["Home_School_Name"].stringValue
                                            let awaySchoolName = jsonArray[i]["Away_School_Name"].stringValue
                                            let category = jsonArray[i]["Category"].stringValue
                                            let schoolsType = jsonArray[i]["Schools_Type"].stringValue
                                            let sport = jsonArray[i]["Sport"].stringValue
                                            let ageGroup = jsonArray[i]["Age_Group"].stringValue
                                            let team = jsonArray[i]["Team"].stringValue
                                            let startTime = jsonArray[i]["Start_Time"].stringValue
                                            let weather = jsonArray[i]["Weather"].stringValue
                                            let temperature = jsonArray[i]["Temperature"].stringValue
                                            let status = jsonArray[i]["Status"].stringValue
                                            let score = jsonArray[i]["Score"].stringValue
                                            let lastUpdateBy = jsonArray[i]["Last_Update_By"].stringValue
                                            let lastUpdateTime = jsonArray[i]["Last_Update_Time"].stringValue
                                            let homeSchoolLogo = jsonArray[i]["Home_School_Logo"].stringValue
                                            let awaySchoolLogo = jsonArray[i]["Away_School_Logo"].stringValue
                                            let won = jsonArray[i]["Won"].stringValue
                                            let chat = jsonArray[i]["Chat"].stringValue
                                            
                                            self.array.append(Game(gameID: gameID, homeSchoolName: homeSchoolName, awaySchoolName: awaySchoolName, category: category, schoolsType: schoolsType, sport: sport, ageGroup: ageGroup, team: team, startTime: startTime, weather: weather, temperature: temperature, status: status, score: score, lastUpdateBy: lastUpdateBy, lastUpdateTime: lastUpdateTime, homeSchoolImageURL: homeSchoolLogo, awaySchoolImageURL: awaySchoolLogo, whoWon: won, chatBubble: chat, selectedForNotification: false))
                                            
                                        }
                                        self.effectView.isHidden = true
                                        self.tableView.reloadData()
                                        if self.refreshControl.isRefreshing {
                                            self.refreshControl.endRefreshing()
                                        }
                                        
                                    }
                                    
                                }
                                catch {
                                    print("Got in Catch")
                                }
                            }
                            
                        }
                        else {
                            self.effectView.isHidden = true
                            self.array.removeAll()
                            self.tableView.reloadData()
                            if self.refreshControl.isRefreshing {
                                self.refreshControl.endRefreshing()
                            }
                            self.createAlert2(titleText: "Note", messageText: "No Games to display")
                        }
                        break
                    
                    case .failure(let error):
                        self.effectView.isHidden = true
                        self.createAlert2(titleText: "Note", messageText: error.localizedDescription)
                        break;
                }
        }
        
    }
    
    @IBAction func openContainerVC(_ sender: UIButton) {
      /*  let vc: UIViewController! = self.storyboard!.instantiateViewController(withIdentifier: "ContainerVC")
        
        let window = UIApplication.shared.windows[0];
        window.rootViewController = vc; */
         self.navigationController?.popToRootViewController(animated: true)
    }


}
