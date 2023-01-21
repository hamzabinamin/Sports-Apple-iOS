//
//  File.swift
//  Schools-Live
//
//  Created by Hamza  Amin on 10/15/17.
//  Copyright © 2017 Hamza  Amin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import MessageUI
import JTAppleCalendar
import UserNotifications

class SchoolVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate, MFMailComposeViewControllerDelegate {
    
    let outsideMonthColor = UIColor.gray
    let monthColor = UIColor.black
    let selectedMonthColor = UIColor.white
    let currentDateSelectedViewColor = UIColor(colorWithHexValue: 0x4e3f5d)
    let isFront = true
  
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var weekButton: UIButton!
    @IBOutlet weak var gameButton: UIButton!
    @IBOutlet weak var schoolTypeLabel: UILabel!
    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var schoolLocationLabel: UILabel!
    @IBOutlet weak var schoolWebsiteLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var CUIView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var calendarView: JTACMonthView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
   // @IBOutlet weak var calendarContainerView: UIView!
    var formatter = DateFormatter()
    var dateArray = [Date]()
    var date1 = Date()
    var date2 = Date()
  //  var storeCalendar: JTAppleCalendarView

    var array = [Game] ()
    var backgroundFixtureArray = [Game] ()
    var backgroundLiveArray = [Game] ()
    var backgroundNotificationArray = [Game] ()
    var notificationArray = [Game] ()
    var school: School?
    let messageFrame = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    var refreshControl: UIRefreshControl!
  //  var counter = 0
  
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View DidLoad called")
        
        CUIView.layer.borderColor = UIColor.black.cgColor
        CUIView.layer.borderWidth = 1
        CUIView.isHidden = true
        setupCalendar()
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(willEnterForeground), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        
        let date = Date()
        
        let firstDay = getWeekFirstDay(from: date)
        let lastDay = getWeekLastDay(from: date)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyy-M-d"
        print("First Day: ", formatter.string(from: firstDay!))
        print("Last Day: ", formatter.string(from: lastDay!))
        
        
         NotificationCenter.default.addObserver(self, selector: #selector(openGames), name: NSNotification.Name("openGames"), object: nil)
        
         NotificationCenter.default.addObserver(self, selector: #selector(openChange), name: NSNotification.Name("openChange"), object: nil)
        
         NotificationCenter.default.addObserver(self, selector: #selector(openEdit), name: NSNotification.Name("openEdit"), object: nil)
        
         NotificationCenter.default.addObserver(self, selector: #selector(openAdd), name: NSNotification.Name("openAdd"), object: nil)
        
         NotificationCenter.default.addObserver(self, selector: #selector(openNotifications), name: NSNotification.Name("openNotifications"), object: nil)
        
         NotificationCenter.default.addObserver(self, selector: #selector(openLeaderboard), name: NSNotification.Name("openLeaderboard"), object: nil)
        
         NotificationCenter.default.addObserver(self, selector: #selector(openUserSettings), name: NSNotification.Name("openUserSettings"), object: nil)
        
         NotificationCenter.default.addObserver(self, selector: #selector(openGetInTouch), name: NSNotification.Name("openGetInTouch"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(getWeek), name: .week, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(getGame), name: .game, object: nil)
     
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
       //newGetWeekFirstDay()
       //newGetNextFirstDay()
        //newestCurrentWeekRange()
        let startWeek = Date().startOfWeek
        let endWeek = Date().endOfWeek
        let startNextWeek = Date().startOfNextWeek
        let endNextWeek = Date().endOfNextWeek
        let startPreviousWeek = Date().startOfPreviousWeek
        let endPreviousWeek = Date().endOfPreviousWeek
        
        print(startWeek ?? "not found start date")
        print(endWeek ?? "not found end date")
        print(startNextWeek ?? "not found start date")
        print(endNextWeek ?? "not found end date")
        print(startPreviousWeek ?? "not found start date")
        print(endPreviousWeek ?? "not found end date")
        
        /*    if let nav = (UIApplication.shared.keyWindow?.rootViewController as? UINavigationController)?.viewControllers {
          //  var vc = nav.topViewController
            print("Called check method")
            if let loginVC = nav[0] as? LiveNowVC{
                
               print("Current Top view is LiveView")
            }
            else {
                print("Current Top view is not LiveView")
                  NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
            }
        }
        else {
            print("No View controllers")
        }
    */
     /*   UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
            
            if error != nil {
                print("Authorization Unsuccessful")
            }
            else {
                 print("Authorization Successful")
            }
        } */
        
       // UserDefaults.standard.removeObject(forKey: "Notification Array")
        //removePersistentDomain(forName: "Notification Array")
        
      //  _ = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(getFixtureGames), userInfo: nil, repeats: true)
     //    _ = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(getLiveGames), userInfo: nil, repeats: true)
     //   _ = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(loopThrouhNotifications), userInfo: nil, repeats: true)
        
    }
    
    @objc func willEnterForeground() {
        print("SchoolVC Entered Foreground")
         CUIView.isHidden = true
        if self.isViewLoaded && (self.view.window != nil) {
            print("School VC is visible")
            
            //weekButton.setTitle("THIS WEEK", for: .normal)
            //gameButton.setTitle("ALL GAMES", for: .normal)
            CUIView.isHidden = true
            
            school = retrieveSchool()
            
            if school == nil {
                
                DispatchQueue.main.async {
                  /*  self.createAlert(titleText: "Note", messageText: "Either add a new School or Select existing one from  Change School")  */
                    let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChangeSchool") as! ChangeSchoolVC
                    self.navigationController?.pushViewController(secondViewController, animated: true)
                }
            }
            else {
                schoolTypeLabel.text = school?.schoolType
                schoolNameLabel.text = school?.schoolName
                schoolLocationLabel.text = school?.schoolLocation
                if weekButton.titleLabel?.text == "THIS WEEK" {
                    array.removeAll()
                    tableView.reloadData()
                    let range1 = Date().startOfWeek
                    let range2 = Date().endOfWeek
                    var game = gameButton.titleLabel?.text!
                    let formatter = DateFormatter()
                    formatter.calendar = Calendar(identifier: .gregorian)
                    formatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
                    formatter.dateFormat = "yyyy-M-d"
                    print("This Week First Date: ", formatter.string(from: range1!))
                    print("This Week Last Date: ", formatter.string(from: range2!))
                    
                    if game == "ALL GAMES" {
                        let parameters = ["home": school?.schoolName, "away": school?.schoolName, "range1": formatter.string(from: range1!), "range2": formatter.string(from: range2!)]
                        
                        if isConnectedToNetwork() {
                            getGames(url: "https://schools-live.com/app/apis/getAllFixtureGamesInRange.php", parameters: parameters as! [String : String])
                        }
                        else {
                            createAlert2(titleText: "Note", messageText: "Please connect to the Internet")
                        }
                    }
                    else {
                        
                        if game == "WATERPOLO" {
                            game = "Water polo"
                        }
                        
                        let parameters = ["home": school?.schoolName, "away": school?.schoolName, "sport": game,  "range1": formatter.string(from: range1!), "range2": formatter.string(from: range2!)]
                        
                        if isConnectedToNetwork() {
                            getGames(url: "https://schools-live.com/app/apis/getFixtureGamesInRange.php", parameters: parameters as! [String : String])
                        }
                        else {
                            createAlert2(titleText: "Note", messageText: "Please connect to the Internet")
                        }
                    }
                }
                else if weekButton.titleLabel?.text == "NEXT WEEK" {
                    array.removeAll()
                    tableView.reloadData()
                    let range1 = Date().startOfNextWeek
                    let range2 = Date().endOfNextWeek
                    var game = gameButton.titleLabel?.text!
                    let formatter = DateFormatter()
                    formatter.calendar = Calendar(identifier: .gregorian)
                    formatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
                    formatter.dateFormat = "yyyy-M-d"
                    print("Current Date: ", formatter.string(from: range1!))
                    print("Next Week Date: ", formatter.string(from: range2!))
                    
                    if game == "ALL GAMES" {
                        let parameters = ["home": school?.schoolName, "away": school?.schoolName, "range1": formatter.string(from: range1!), "range2": formatter.string(from: range2!)]
                        
                        if isConnectedToNetwork() {
                            getGames(url: "https://schools-live.com/app/apis/getAllFixtureGamesInRange.php", parameters: parameters as! [String : String])
                        }
                        else {
                            createAlert2(titleText: "Note", messageText: "Please connect to the Internet")
                        }
                    }
                    else {
                        
                        if game == "WATERPOLO" {
                            game = "Water polo"
                        }
                        
                        let parameters = ["home": school?.schoolName, "away": school?.schoolName, "sport": game,  "range1": formatter.string(from: range1!), "range2": formatter.string(from: range2!)]
                        
                        if isConnectedToNetwork() {
                            getGames(url: "https://schools-live.com/app/apis/getFixtureGamesInRange.php", parameters: parameters as! [String : String])
                        }
                        else {
                            createAlert2(titleText: "Note", messageText: "Please connect to the Internet")
                        }
                    }
                }
                else if weekButton.titleLabel?.text == "C.D. RANGE" {
                    array.removeAll()
                    tableView.reloadData()
                    effectView.isHidden = true
                    CUIView.isHidden = false
                    // mainView.alpha = 0.6
                    //  self.view.backgroundColor = UIColor.clear.withAlphaComponent(0.7)
                }
            }
            
        } else {
            print("School VC is NOT visible")
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("View Did Appear")
        CUIView.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("View Did Disappear")
        CUIView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("View Will Appear Called SchoolVC")
      
        //weekButton.setTitle("THIS WEEK", for: .normal)
        //gameButton.setTitle("ALL GAMES", for: .normal)
        CUIView.isHidden = true
        
        school = retrieveSchool()
        
        if school == nil {
            
            DispatchQueue.main.async {
               /* self.createAlert(titleText: "Note", messageText: "Either add a new School or Select existing one from  Change School") */
                
                 //self.performSegue(withIdentifier: "ChangeSchool", sender: nil)
                let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChangeSchool") as! ChangeSchoolVC
                self.navigationController?.pushViewController(secondViewController, animated: true)
            }
        }
        else {
            schoolTypeLabel.text = school?.schoolType
            schoolNameLabel.text = school?.schoolName
            schoolLocationLabel.text = school?.schoolLocation
        if weekButton.titleLabel?.text == "THIS WEEK" {
            array.removeAll()
            tableView.reloadData()
            //let range1 = getWeekFirstDay(from: Date())
            //let range2 = getWeekLastDay(from: Date())
            let range1 = Date().startOfWeek
            let range2 = Date().endOfWeek
            var game = gameButton.titleLabel?.text!
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .gregorian)
            formatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
            formatter.dateFormat = "yyyy-M-d"
            print("This Week First Date: ", formatter.string(from: range1!))
            print("This Week Last Date: ", formatter.string(from: range2!))
            
            if game == "ALL GAMES" {
                let parameters = ["home": school?.schoolName.trimmingCharacters(in: .whitespacesAndNewlines), "away": school?.schoolName.trimmingCharacters(in: .whitespacesAndNewlines), "range1": formatter.string(from: range1!), "range2": formatter.string(from: range2!)]
                
                if isConnectedToNetwork() {
                    getGames(url: "https://schools-live.com/app/apis/getAllFixtureGamesInRange.php", parameters: parameters as! [String : String])
                }
                else {
                     createAlert2(titleText: "Note", messageText: "Please connect to the Internet")
                }
            }
            else {
                
                if game == "WATERPOLO" {
                    game = "Water polo"
                }
                
                let parameters = ["home": school?.schoolName, "away": school?.schoolName, "sport": game,  "range1": formatter.string(from: range1!), "range2": formatter.string(from: range2!)]
                
                if isConnectedToNetwork() {
                    getGames(url: "https://schools-live.com/app/apis/getFixtureGamesInRange.php", parameters: parameters as! [String : String])
                }
                else {
                    createAlert2(titleText: "Note", messageText: "Please connect to the Internet")
                }
            }
        }
        else if weekButton.titleLabel?.text == "NEXT WEEK" {
            array.removeAll()
            tableView.reloadData()
            let range1 = Date().startOfNextWeek
            let range2 = Date().endOfNextWeek
            var game = gameButton.titleLabel?.text!
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .gregorian)
            formatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
            formatter.dateFormat = "yyyy-M-d"
            print("Current Date: ", formatter.string(from: range1!))
            print("Next Week Date: ", formatter.string(from: range2!))
            
            if game == "ALL GAMES" {
                let parameters = ["home": school?.schoolName, "away": school?.schoolName, "range1": formatter.string(from: range1!), "range2": formatter.string(from: range2!)]
                
                if isConnectedToNetwork() {
                    getGames(url: "https://schools-live.com/app/apis/getAllFixtureGamesInRange.php", parameters: parameters as! [String : String])
                }
                else {
                    createAlert2(titleText: "Note", messageText: "Please connect to the Internet")
                }
            }
            else {
                
                if game == "WATERPOLO" {
                    game = "Water polo"
                }
                
                let parameters = ["home": school?.schoolName, "away": school?.schoolName, "sport": game,  "range1": formatter.string(from: range1!), "range2": formatter.string(from: range2!)]
                
                if isConnectedToNetwork() {
                    getGames(url: "https://schools-live.com/app/apis/getFixtureGamesInRange.php", parameters: parameters as! [String : String])
                }
                else {
                    createAlert2(titleText: "Note", messageText: "Please connect to the Internet")
                }
            }
        }
        else if weekButton.titleLabel?.text == "C.D. RANGE" {
            array.removeAll()
            tableView.reloadData()
            effectView.isHidden = true
            CUIView.isHidden = false
           // mainView.alpha = 0.6
           //  self.view.backgroundColor = UIColor.clear.withAlphaComponent(0.7)
        }
      }
    }
    
    func sendNotification(gameType: String, gameDetails: String, inseconds: TimeInterval, completion: @escaping (_ Success: Bool) -> ()) {
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: inseconds, repeats: false)
        let content = UNMutableNotificationContent()
        content.title = "Schools-Live"
        content.subtitle = gameType
        content.body = gameDetails
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: "customNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            
            if error != nil {
                completion(false)
            }
            else {
                completion(true)
            }
        }
        
    }
    
    @objc func getFixtureGames() {
        
        let home = school?.schoolName
        
        AF.request("https://schools-live.com/app/apis/getAllFixturesGames.php", parameters: ["home": home!, "away": home!])
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
                                                
                                                self.backgroundFixtureArray.append(Game(gameID: gameID, homeSchoolName: homeSchoolName, awaySchoolName: awaySchoolName, category: category, schoolsType: schoolsType, sport: sport, ageGroup: ageGroup, team: team, startTime: startTime, weather: weather, temperature: temperature, status: status, score: score, lastUpdateBy: lastUpdateBy, lastUpdateTime: lastUpdateTime, homeSchoolImageURL: homeSchoolLogo, awaySchoolImageURL: awaySchoolLogo, whoWon: won, chatBubble: chat, selectedForNotification: false))
                                            }
                                            
                                            if self.backgroundFixtureArray.count > 0 {
                                                
                                                for i in 0..<self.backgroundFixtureArray.count {
                                                    
                                                    let game = self.backgroundFixtureArray[i]
                                                    let gameTime = self.UTCToLocal(date: game.startTime)
                                                    let currentTime = Date().preciseLocalTime
                                                    let dateFormatter = DateFormatter()
                                                    dateFormatter.dateFormat = "d-M-yyyy / hh:mm a"
                                                    //dateFormatter.timeZone = TimeZone(abbreviation: .current)
                                                    let gameDate = dateFormatter.date(from: gameTime)
                                                    let currentDate = dateFormatter.date(from: currentTime)
                                                
                                                    let timeDiff = currentDate?.timeIntervalSince(gameDate!)
                                                   
                                                   /* timeDiff =  floor(timeDiff!/1000);
                                                    let seconds : double_t = fmod(timeDiff!, 60);
                                                    let minutes  : double_t = fmod((timeDiff! / 60) , 60);
                                                
                                                    var userCalendar = Calendar.current
                                                    userCalendar.timeZone = TimeZone.current
                                                    let requestedComponent: Set<Calendar.Component> = [.hour,.minute,.second]
                                                    let startTime = currentDate
                                                    let endTime = dateFormatter.date(from: "2-2-18 / 09:40 PM")
                                                    let timeDifference = userCalendar.dateComponents(requestedComponent, from: endTime!, to: startTime!)
                                                    print(timeDifference)
                                                    
                                                    let date = Calendar(identifier: .gregorian).date(from: timeDifference)
                                                    dateFormatter.dateFormat = "HH:mm:ss"
                                                    let dateString =  dateFormatter.string(from: date!) */

                                                    
                                                   // let timeDiffMin = minutes
                                                    
                                                    print("Game Details: ", game.homeSchoolName + "/" + game.awaySchoolName)
                                                    print("Game Time: ", gameTime)
                                                    print("Current Time: ", currentTime)
                                                    print("Game Date: ", dateFormatter.string(from: gameDate!))
                                                     print("Current Date: ", dateFormatter.string(from: currentDate!))
                                                    print("Difference in Minutes: ", timeDiff!/60)
                                                   
                                                    let store: Double = timeDiff!/60
                                                    
                                                    if store >= 0 {
                                                        
                                                        if store <= 10 || store >= 10 {
                                                            
                                                            if game.sport != "CRICKET" {
                                                                let category = game.category
                                                                let sport = game.sport
                                                                let ageGroup = game.ageGroup
                                                                let team = game.team
                                                                let home = game.homeSchoolName
                                                                let away = game.awaySchoolName
                                                                let score1 = game.score.split(separator: "-")[0]
                                                                let score2 = game.score.split(separator: "-")[1]
                                                                let text = " \(category) \(sport) \(ageGroup) \(team) \("-") \(home) \(score1) \("-") \(away) \(score2) "
                                                                
                                                                if UserDefaults.standard.object(forKey: "Notification Switch") != nil {
                                                                    
                                                                    if UserDefaults.standard.bool(forKey: "Notification Switch") == true {
                                                                        self.sendNotification(gameType: "Live Game Right Now!", gameDetails: text, inseconds: 1) { (success) in
                                                                            
                                                                            if success {
                                                                                print("Sent Notification")
                                                                            }
                                                                            else {
                                                                                print("Notification didn't go")
                                                                            }
                                                                        }
                                                                    }
                                                                    
                                                                }
                                                                
                                                            }
                                                            else {
                                                                if game.score.split(separator: "/").count == 5 {
                                                                    let category = game.category
                                                                    let sport = game.sport
                                                                    let ageGroup = game.ageGroup
                                                                    let team = game.team
                                                                   // let home = game.homeSchoolName
                                                                   // let away = game.awaySchoolName
                                                                    let bat = game.score.split(separator: "/")[2]
                                                                    let bowl = game.score.split(separator: "/")[3]
                                                                    let score = game.score.split(separator: "/")[0]
                                                                    let wickets = game.score.split(separator: "/")[1]
                                                                    let overs = game.score.split(separator: "/")[4]
                                                                    let text = " \(category) \(sport) \(ageGroup) \(team) \("-") \(bat) \("(Bat)") \("-") \(bowl) \("(Bowl)") \("-") \(score) \("\\") \(wickets)  \("Overs: ") \(overs) "
                                                                    
                                                                    print("Category: ", category)
                                                                    print("Sport: ", sport)
                                                                    print("Age Group: ", ageGroup)
                                                                    print("Team: ", team)
                                                                    print("Bat: ", bat)
                                                                    print("Bowl: ", bowl)
                                                                    print("Score: ", score)
                                                                    print("Wickets: ", wickets)
                                                                    print("Overs: ", overs)
                                                                    
                                                                  /*  let shareText = " \(String(describing: gameType!)) \(String(describing: ageGroup!)) \(String(describing: team!)) \("-") \(String(describing: bat!)) \("(Bat)") \("-") \(String(describing: bowl!)) \("(Bowl)") \("-") \(String(describing: score!)) \("\\") \(String(describing: wickets!))  \("Overs: ") \(String(describing: overs!)) " */
                                                                    
                                                                    if UserDefaults.standard.object(forKey: "Notification Switch") != nil {
                                                                        
                                                                        if UserDefaults.standard.bool(forKey: "Notification Switch") == true {
                                                                            self.sendNotification(gameType: "Live Game Right Now!", gameDetails: text, inseconds: 1) { (success) in
                                                                                
                                                                                if success {
                                                                                    print("Sent Notification")
                                                                                }
                                                                                else {
                                                                                    print("Notification didn't go")
                                                                                }
                                                                            }
                                                                        }
                                                                        
                                                                    }
                                                            
                                                                }
                                                                else {
                                                                    let category = game.category
                                                                    let sport = game.sport
                                                                    let ageGroup = game.ageGroup
                                                                    let team = game.team
                                                                    let home = game.homeSchoolName
                                                                    let away = game.awaySchoolName
                                                                    let score1 = game.score.split(separator: "/")[0]
                                                                    let score2 = game.score.split(separator: "/")[1]
                                                                    let text = " \(category) \(sport) \(ageGroup) \(team) \("-") \(home) \(score1) \("-") \(away) \(score2) "
                                                                    
                                                                    if UserDefaults.standard.object(forKey: "Notification Switch") != nil {
                                                                        
                                                                        if UserDefaults.standard.bool(forKey: "Notification Switch") == true {
                                                                            self.sendNotification(gameType: "Live Game Right Now!", gameDetails: text, inseconds: 1) { (success) in
                                                                                
                                                                                if success {
                                                                                    print("Sent Notification")
                                                                                }
                                                                                else {
                                                                                    print("Notification didn't go")
                                                                                }
                                                                            }
                                                                        }
                                                                        
                                                                    }
                                                                }
                                                            }
                                                            
                                                            self.updateGameStatus(gameID: game.gameID, status: "1st HALF")
                                                        }
                                                        
                                                    }
                                                    else {
                                                        print("Game is in future")
                                                    }
                                                    
                                           
                                                }
                                                self.backgroundFixtureArray.removeAll()
                                                
                                            }
                                            else {
                                                print("No Fixture Game")
                                            }
                                            
                                        }
                                        
                                    }
                                    catch {
                                        print("Got in Catch")
                                    }
                                }
                                
                            }
                            else {
                              
                            }
                            break
                        
                        case .failure(let error):
                            self.effectView.isHidden = true
                            self.createAlert(titleText: "Note", messageText: error.localizedDescription)
                            break;
                    }
                    

            }
    }
    
    typealias CompletionHandler = (_ success:Bool) -> Void
    func getFixtureGamesBG(completionHandler: @escaping CompletionHandler) {
        
        let home = school?.schoolName
        
        AF.request("https://schools-live.com/app/apis/getAllFixturesGames.php", parameters: ["home": home!, "away": home!])
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
                                            
                                            self.backgroundFixtureArray.append(Game(gameID: gameID, homeSchoolName: homeSchoolName, awaySchoolName: awaySchoolName, category: category, schoolsType: schoolsType, sport: sport, ageGroup: ageGroup, team: team, startTime: startTime, weather: weather, temperature: temperature, status: status, score: score, lastUpdateBy: lastUpdateBy, lastUpdateTime: lastUpdateTime, homeSchoolImageURL: homeSchoolLogo, awaySchoolImageURL: awaySchoolLogo, whoWon: won, chatBubble: chat, selectedForNotification: false))
                                        }
                                        
                                        if self.backgroundFixtureArray.count > 0 {
                                            
                                            for i in 0..<self.backgroundFixtureArray.count {
                                                
                                                let game = self.backgroundFixtureArray[i]
                                                let gameTime = self.UTCToLocal(date: game.startTime)
                                                let currentTime = Date().preciseLocalTime
                                                let dateFormatter = DateFormatter()
                                                dateFormatter.dateFormat = "d-M-yyyy / hh:mm a"
                                                //dateFormatter.timeZone = TimeZone(abbreviation: .current)
                                                let gameDate = dateFormatter.date(from: gameTime)
                                                let currentDate = dateFormatter.date(from: currentTime)
                                                
                                                let timeDiff = currentDate?.timeIntervalSince(gameDate!)
                                                
                                                /* timeDiff =  floor(timeDiff!/1000);
                                                 let seconds : double_t = fmod(timeDiff!, 60);
                                                 let minutes  : double_t = fmod((timeDiff! / 60) , 60);
                                                 
                                                 var userCalendar = Calendar.current
                                                 userCalendar.timeZone = TimeZone.current
                                                 let requestedComponent: Set<Calendar.Component> = [.hour,.minute,.second]
                                                 let startTime = currentDate
                                                 let endTime = dateFormatter.date(from: "2-2-18 / 09:40 PM")
                                                 let timeDifference = userCalendar.dateComponents(requestedComponent, from: endTime!, to: startTime!)
                                                 print(timeDifference)
                                                 
                                                 let date = Calendar(identifier: .gregorian).date(from: timeDifference)
                                                 dateFormatter.dateFormat = "HH:mm:ss"
                                                 let dateString =  dateFormatter.string(from: date!) */
                                                
                                                
                                                // let timeDiffMin = minutes
                                                
                                                print("Game Details: ", game.homeSchoolName + "/" + game.awaySchoolName)
                                                print("Game Time: ", gameTime)
                                                print("Current Time: ", currentTime)
                                                print("Game Date: ", dateFormatter.string(from: gameDate!))
                                                print("Current Date: ", dateFormatter.string(from: currentDate!))
                                                print("Difference in Minutes: ", timeDiff!/60)
                                                
                                                let store: Double = timeDiff!/60
                                                
                                                if store >= 0 {
                                                    
                                                    if store <= 10 || store >= 10 {
                                                        
                                                        if game.sport != "CRICKET" {
                                                            let category = game.category
                                                            let sport = game.sport
                                                            let ageGroup = game.ageGroup
                                                            let team = game.team
                                                            let home = game.homeSchoolName
                                                            let away = game.awaySchoolName
                                                            let score1 = game.score.split(separator: "-")[0]
                                                            let score2 = game.score.split(separator: "-")[1]
                                                            let text = " \(category) \(sport) \(ageGroup) \(team) \("-") \(home) \(score1) \("-") \(away) \(score2) "
                                                            
                                                            if UserDefaults.standard.object(forKey: "Notification Switch") != nil {
                                                                
                                                                if UserDefaults.standard.bool(forKey: "Notification Switch") == true {
                                                                    self.sendNotification(gameType: "Live Game Right Now!", gameDetails: text, inseconds: 1) { (success) in
                                                                        
                                                                        if success {
                                                                            print("Sent Notification")
                                                                        }
                                                                        else {
                                                                            print("Notification didn't go")
                                                                        }
                                                                    }
                                                                }
                                                                
                                                            }
                                                            
                                                        }
                                                        else {
                                                            if game.score.split(separator: "/").count == 5 {
                                                                let category = game.category
                                                                let sport = game.sport
                                                                let ageGroup = game.ageGroup
                                                                let team = game.team
                                                                // let home = game.homeSchoolName
                                                                // let away = game.awaySchoolName
                                                                let bat = game.score.split(separator: "/")[2]
                                                                let bowl = game.score.split(separator: "/")[3]
                                                                let score = game.score.split(separator: "/")[0]
                                                                let wickets = game.score.split(separator: "/")[1]
                                                                let overs = game.score.split(separator: "/")[4]
                                                                let text = " \(category) \(sport) \(ageGroup) \(team) \("-") \(bat) \("(Bat)") \("-") \(bowl) \("(Bowl)") \("-") \(score) \("\\") \(wickets)  \("Overs: ") \(overs) "
                                                                
                                                                print("Category: ", category)
                                                                print("Sport: ", sport)
                                                                print("Age Group: ", ageGroup)
                                                                print("Team: ", team)
                                                                print("Bat: ", bat)
                                                                print("Bowl: ", bowl)
                                                                print("Score: ", score)
                                                                print("Wickets: ", wickets)
                                                                print("Overs: ", overs)
                                                                
                                                                /*  let shareText = " \(String(describing: gameType!)) \(String(describing: ageGroup!)) \(String(describing: team!)) \("-") \(String(describing: bat!)) \("(Bat)") \("-") \(String(describing: bowl!)) \("(Bowl)") \("-") \(String(describing: score!)) \("\\") \(String(describing: wickets!))  \("Overs: ") \(String(describing: overs!)) " */
                                                                
                                                                if UserDefaults.standard.object(forKey: "Notification Switch") != nil {
                                                                    
                                                                    if UserDefaults.standard.bool(forKey: "Notification Switch") == true {
                                                                        self.sendNotification(gameType: "Live Game Right Now!", gameDetails: text, inseconds: 1) { (success) in
                                                                            
                                                                            if success {
                                                                                print("Sent Notification")
                                                                            }
                                                                            else {
                                                                                print("Notification didn't go")
                                                                            }
                                                                        }
                                                                    }
                                                                    
                                                                }
                                                                
                                                            }
                                                            else {
                                                                let category = game.category
                                                                let sport = game.sport
                                                                let ageGroup = game.ageGroup
                                                                let team = game.team
                                                                let home = game.homeSchoolName
                                                                let away = game.awaySchoolName
                                                                let score1 = game.score.split(separator: "/")[0]
                                                                let score2 = game.score.split(separator: "/")[1]
                                                                let text = " \(category) \(sport) \(ageGroup) \(team) \("-") \(home) \(score1) \("-") \(away) \(score2) "
                                                                
                                                                if UserDefaults.standard.object(forKey: "Notification Switch") != nil {
                                                                    
                                                                    if UserDefaults.standard.bool(forKey: "Notification Switch") == true {
                                                                        self.sendNotification(gameType: "Live Game Right Now!", gameDetails: text, inseconds: 1) { (success) in
                                                                            
                                                                            if success {
                                                                                print("Sent Notification")
                                                                            }
                                                                            else {
                                                                                print("Notification didn't go")
                                                                            }
                                                                        }
                                                                    }
                                                                    
                                                                }
                                                            }
                                                        }
                                                        
                                                        self.updateGameStatus(gameID: game.gameID, status: "1st HALF")
                                                    }
                                                    
                                                }
                                                else {
                                                    print("Game is in future")
                                                }
                                                
                                                
                                            }
                                            completionHandler(true)
                                            self.backgroundFixtureArray.removeAll()
                                            
                                        }
                                        else {
                                            print("No Fixture Game")
                                        }
                                        
                                    }
                                    
                                }
                                catch {
                                    print("Got in Catch")
                                }
                            }
                            
                        }
                        else {
                            completionHandler(false)
                        }
                        break
                    
                    case .failure(let error):
                        self.effectView.isHidden = true
                        self.createAlert(titleText: "Note", messageText: error.localizedDescription)
                        break;
                }
        }
    }
    
    @objc func loopThrouhNotifications() {
        
        do {
            if let notification = UserDefaults.standard.object(forKey: "Notification Array") as? Data {
                if let storedNotification = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, Game.self], from: notification) as? [Game] {
                    
                    if storedNotification.count > 0 {
                        
                        for i in 0..<storedNotification.count {
                            print("Notification Array not empty: ", i)
                            let store = storedNotification[i]
                            let gameID = store.gameID
                            getNotificationGames(gameID: gameID, originalGame: store)
                            
                        }
                    }
                    else {
                        print("Notification array has zero elements")
                    }
                }
            }
            else {
                print("Notification array not created yet")
            }
        }
        catch {
            print(error)
        }
    }
    
    func getNotificationGames(gameID: String, originalGame: Game) {
        
        AF.request("https://schools-live.com/app/apis/getGame.php", parameters: ["id": gameID])
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
                                            
                                            self.backgroundNotificationArray.append(Game(gameID: gameID, homeSchoolName: homeSchoolName, awaySchoolName: awaySchoolName, category: category, schoolsType: schoolsType, sport: sport, ageGroup: ageGroup, team: team, startTime: startTime, weather: weather, temperature: temperature, status: status, score: score, lastUpdateBy: lastUpdateBy, lastUpdateTime: lastUpdateTime, homeSchoolImageURL: homeSchoolLogo, awaySchoolImageURL: awaySchoolLogo, whoWon: won, chatBubble: chat, selectedForNotification: false))
                                        }
                                        
                                        if self.backgroundNotificationArray.count > 0 {
                                            
                                            for i in 0..<self.backgroundNotificationArray.count {
                                                
                                                let game = self.backgroundNotificationArray[i]
                                                
                                                if game.score == originalGame.score {
                                                    print("Game: ", game.homeSchoolName + "/" + game.awaySchoolName)
                                                    print("Original Game Score: ", originalGame.score)
                                                    print("Game Score: ", game.score)
                                                    print("Game score same as Original")
                                                }
                                                else {
                                                    print("Game score changed")
                                                    print("Game: ", game.homeSchoolName + "/" + game.awaySchoolName)
                                                    print("Original Game Score: ", originalGame.score)
                                                    print("Game Score: ", game.score)
                                                    
                                                    if UserDefaults.standard.object(forKey: "Notification Switch") != nil {
                                                        
                                                        if UserDefaults.standard.bool(forKey: "Notification Switch") == true {
                                                            
                                                            if game.sport != "CRICKET" {
                                                                let category = game.category
                                                                let sport = game.sport
                                                                let ageGroup = game.ageGroup
                                                                let team = game.team
                                                                let home = game.homeSchoolName
                                                                let away = game.awaySchoolName
                                                                let score1 = game.score.split(separator: "-")[0]
                                                                let score2 = game.score.split(separator: "-")[1]
                                                                let text = " \(category) \(sport) \(ageGroup) \(team) \("-") \(home) \(score1) \("-") \(away) \(score2) "
                                                                
                                                                self.sendNotification(gameType: "Score Update!", gameDetails: text, inseconds: 1) { (success) in
                                                                    
                                                                    if success {
                                                                        print("Sent Notification")
                                                                    }
                                                                    else {
                                                                        print("Notification didn't go")
                                                                    }
                                                                }
                                                                
                                                            }
                                                            else if game.sport == "CRICKET" {
                                                                if game.score.split(separator: "/").count == 5 {
                                                                    let category = game.category
                                                                    let sport = game.sport
                                                                    let ageGroup = game.ageGroup
                                                                    let team = game.team
                                                                    // let home = game.homeSchoolName
                                                                    // let away = game.awaySchoolName
                                                                    let bat = game.score.split(separator: "/")[2]
                                                                    let bowl = game.score.split(separator: "/")[3]
                                                                    let score = game.score.split(separator: "/")[0]
                                                                    let wickets = game.score.split(separator: "/")[1]
                                                                    let overs = game.score.split(separator: "/")[4]
                                                                    let text = " \(category) \(sport) \(ageGroup) \(team) \("-") \(bat) \("(Bat)") \("-") \(bowl) \("(Bowl)") \("-") \(score) \("/") \(wickets)  \("Overs: ") \(overs) "
                                                                    
                                                                    self.sendNotification(gameType: "Score Update!", gameDetails: text, inseconds: 1) { (success) in
                                                                        
                                                                        if success {
                                                                            print("Sent Notification")
                                                                        }
                                                                        else {
                                                                            print("Notification didn't go")
                                                                        }
                                                                    }
                                                                    
                                                                }
                                                                else {
                                                                    let category = game.category
                                                                    let sport = game.sport
                                                                    let ageGroup = game.ageGroup
                                                                    let team = game.team
                                                                    let home = game.homeSchoolName
                                                                    let away = game.awaySchoolName
                                                                    let score1 = game.score.split(separator: "/")[0]
                                                                    let score2 = game.score.split(separator: "/")[1]
                                                                    let text = " \(category) \(sport) \(ageGroup) \(team) \("-") \(home) \(score1) \("-") \(away) \(score2) "
                                                                    
                                                                    self.sendNotification(gameType: "Score Update!", gameDetails: text, inseconds: 1) { (success) in
                                                                        
                                                                        if success {
                                                                            print("Sent Notification")
                                                                        }
                                                                        else {
                                                                            print("Notification didn't go")
                                                                        }
                                                                    }
                                                                    
                                                                }
                                                                
                                                        }
                                                        
                                                    }
                                                    
                                                    
                                                }
                                    
                                                    
                                                }
                                                
                                                // replace new score in the notification array
                                                do {
                                                    if let notification = UserDefaults.standard.object(forKey: "Notification Array") as? Data {
                                                        if var storedNotification = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, Game.self], from: notification) as? [Game] {
                                                            let index = storedNotification.firstIndex(where: {$0.gameID == originalGame.gameID })
                                                            if index != -1 && index != nil {
                                                                originalGame.score = game.score
                                                                storedNotification[index!] = originalGame
                                                                self.saveNotificationArray(notificationArray: storedNotification)
                                                          //      saveNotificationArray(notificationArray: storedNotification)
                                                            }
                                                            else {
                                                           
                                                            }
                                                        }
                                                    }
                                                }
                                                catch {
                                                    print(error)
                                                }
                                            }
                                             self.backgroundNotificationArray.removeAll()
                                        }
                                        else {
                                            print("No Game")
                                        }
                                        
                                    }
                                    
                                }
                                catch {
                                    print("Got in Catch")
                                }
                            }
                            
                        }
                        else {
                            
                        }
                        break
                    
                    case .failure(let error):
                        self.effectView.isHidden = true
                        self.createAlert(titleText: "Note", messageText: error.localizedDescription)
                        break;
                }
        }
    }
    
    @objc func getLiveGames() {
        
        let home = school?.schoolName
        
        AF.request("https://schools-live.com/app/apis/getAllLiveGames.php", parameters: ["home": home!, "away": home!])
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
                                            
                                            self.backgroundLiveArray.append(Game(gameID: gameID, homeSchoolName: homeSchoolName, awaySchoolName: awaySchoolName, category: category, schoolsType: schoolsType, sport: sport, ageGroup: ageGroup, team: team, startTime: startTime, weather: weather, temperature: temperature, status: status, score: score, lastUpdateBy: lastUpdateBy, lastUpdateTime: lastUpdateTime, homeSchoolImageURL: homeSchoolLogo, awaySchoolImageURL: awaySchoolLogo, whoWon: won, chatBubble: chat, selectedForNotification: false))
                                        }
                                        
                                        if self.backgroundLiveArray.count > 0 {
                                            
                                            for i in 0..<self.backgroundLiveArray.count {
                                                
                                                let game = self.backgroundLiveArray[i]
                                                let gameTime = self.UTCToLocal(date: game.startTime)
                                                let currentTime = Date().preciseLocalTime
                                                let dateFormatter = DateFormatter()
                                                dateFormatter.dateFormat = "d-M-yyyy / hh:mm a"
                                                //dateFormatter.timeZone = TimeZone(abbreviation: .current)
                                                let gameDate = dateFormatter.date(from: gameTime)
                                                let currentDate = dateFormatter.date(from: currentTime)
                                                
                                                let timeDiff = currentDate?.timeIntervalSince(gameDate!)
                                                
                                                print("Game Details: ", game.homeSchoolName + "/" + game.awaySchoolName)
                                                print("Game Time: ", gameTime)
                                                print("Current Time: ", currentTime)
                                                print("Game Date: ", dateFormatter.string(from: gameDate!))
                                                print("Current Date: ", dateFormatter.string(from: currentDate!))
                                                print("Difference in Minutes: ", timeDiff!/60)
                                                
                                                let store: Double = timeDiff!/60
                                            
                                                        if game.sport != "CRICKET" && store > 7200 {
                                                            let category = game.category
                                                            let sport = game.sport
                                                            let ageGroup = game.ageGroup
                                                            let team = game.team
                                                            let home = game.homeSchoolName
                                                            let away = game.awaySchoolName
                                                            let score1 = game.score.split(separator: "-")[0]
                                                            let score2 = game.score.split(separator: "-")[1]
                                                            let text = " \(category) \(sport) \(ageGroup) \(team) \("-") \(home) \(score1) \("-") \(away) \(score2) "
                                                            
                                                            if UserDefaults.standard.object(forKey: "Notification Switch") != nil {
                                                                
                                                                if UserDefaults.standard.bool(forKey: "Notification Switch") == true {
                                                                    self.sendNotification(gameType: "Game Ended!", gameDetails: text, inseconds: 1) { (success) in
                                                                        
                                                                        if success {
                                                                            print("Sent Notification")
                                                                        }
                                                                        else {
                                                                            print("Notification didn't go")
                                                                        }
                                                                    }
                                                                }
                                                                
                                                            }
                                                        }
                                                        else if game.sport == "CRICKET" && store > 18000 {
                                                            if game.score.split(separator: "/").count == 5 {
                                                                let category = game.category
                                                                let sport = game.sport
                                                                let ageGroup = game.ageGroup
                                                                let team = game.team
                                                                // let home = game.homeSchoolName
                                                                // let away = game.awaySchoolName
                                                                let bat = game.score.split(separator: "/")[2]
                                                                let bowl = game.score.split(separator: "/")[3]
                                                                let score = game.score.split(separator: "/")[0]
                                                                let wickets = game.score.split(separator: "/")[1]
                                                                let overs = game.score.split(separator: "/")[4]
                                                                let text = " \(category) \(sport) \(ageGroup) \(team) \("-") \(bat) \("(Bat)") \("-") \(bowl) \("(Bowl)") \("-") \(score) \("/") \(wickets)  \("Overs: ") \(overs) "
                                                                
                                                                if UserDefaults.standard.object(forKey: "Notification Switch") != nil {
                                                                    
                                                                    if UserDefaults.standard.bool(forKey: "Notification Switch") == true {
                                                                        self.sendNotification(gameType: "Game Ended!", gameDetails: text, inseconds: 1) { (success) in
                                                                            
                                                                            if success {
                                                                                print("Sent Notification")
                                                                            }
                                                                            else {
                                                                                print("Notification didn't go")
                                                                            }
                                                                        }
                                                                    }
                                                                    
                                                                }
                                                            }
                                                            else {
                                                                let category = game.category
                                                                let sport = game.sport
                                                                let ageGroup = game.ageGroup
                                                                let team = game.team
                                                                let home = game.homeSchoolName
                                                                let away = game.awaySchoolName
                                                                let score1 = game.score.split(separator: "/")[0]
                                                                let score2 = game.score.split(separator: "/")[1]
                                                                let text = " \(category) \(sport) \(ageGroup) \(team) \("-") \(home) \(score1) \("-") \(away) \(score2) "
                                                                
                                                                if UserDefaults.standard.object(forKey: "Notification Switch") != nil {
                                                                    
                                                                    if UserDefaults.standard.bool(forKey: "Notification Switch") == true {
                                                                        self.sendNotification(gameType: "Game Ended!", gameDetails: text, inseconds: 1) { (success) in
                                                                            
                                                                            if success {
                                                                                print("Sent Notification")
                                                                            }
                                                                            else {
                                                                                print("Notification didn't go")
                                                                            }
                                                                        }
                                                                    }
                                                                    
                                                                }
                                                                
                                                            }
                                                        }
                                                self.updateGameStatus(gameID: game.gameID, status: "FULL TIME")
                                            }
                                            self.backgroundLiveArray.removeAll()
                                        }
                                        else {
                                            print("No Fixture Game")
                                        }
                                        
                                    }
                                    
                                }
                                catch {
                                    print("Got in Catch")
                                }
                            }
                            
                        }
                        else {
                            
                        }
                        break
                    
                    case .failure(let error):
                        self.effectView.isHidden = true
                        self.createAlert(titleText: "Note", messageText: error.localizedDescription)
                        break;
                }
        }
    }
    
    func updateGameStatus(gameID: String, status: String) {
        AF.request("https://www.schools-live.com/app/apis/updateGameStatusService.php", parameters: ["id": gameID, "status": status])
            .validate()
            .responseString { response in
                
                switch(response.result) {
                    case .success(let data):
                        if data.contains("Record updated successfully") {
                          
                        }
                        else {
                            
                        }
                        break
                    
                    case .failure(let error):
                        print(error.localizedDescription)
                        break;
                }
                
        }
        
    }
    
    func setupCalendar() {
        calendarView.allowsMultipleSelection = true
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
        calendarView.visibleDates { (visibleDates) in
            self.setupViewsOfCalendar(from: visibleDates)
        }
        
    }
    
    func setupViewsOfCalendar(from visibleDates: DateSegmentInfo) {
        let date = visibleDates.monthDates.first!.date
    
        self.formatter.dateFormat = "yyyy"
        self.yearLabel.text = formatter.string(from: date)
    
        self.formatter.dateFormat = "MMMM"
        self.monthLabel.text = formatter.string(from: date)
    }
    
    func handleCellTextColor(view: JTACDayCell?, cellState: CellState) {
        guard let validCell = view as? CustomCalendarCell else { return }
        if cellState.isSelected {
            validCell.dateLabel.textColor = selectedMonthColor
        }
        else {
            if cellState.dateBelongsTo == .thisMonth {
                validCell.dateLabel.textColor = monthColor
            }
            else {
                validCell.dateLabel.textColor = outsideMonthColor
            }
        }
    }
    
    func handleCellSelected(view: JTACDayCell?, cellState: CellState) {
        guard let validCell = view as? CustomCalendarCell else { return }
        if cellState.isSelected {
            validCell.selectedView.isHidden = false
        } else {
                validCell.selectedView.isHidden = true
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
           
            var category = array[indexPath.row].category
            
            if category == "Boys" {
                category = "(B)"
            }
            else if category == "Girls" {
                category = "(G)"
            }
            
            cell.gameNameLabel.text = category + " " + array[indexPath.row].sport
            cell.homeTeamScoreLabel.text = array[indexPath.row].score
            cell.awayTeamScoreLabel.text = array[indexPath.row].score
            cell.homeTeamOverLabel.text = "Over: 0"
            cell.awayTeamOverLabel.text = "Over: 0"
            cell.homeSchoolBatBowlL.isHidden = true
            cell.awaySchoolBatBowlL.isHidden = true
            
            cell.updateGameButton.tag = indexPath.row
            cell.updateGameButton.addTarget(self, action: #selector(SchoolVC.updateGame(_:)), for: .touchUpInside)
            
            cell.notificationButton.tag = indexPath.row
            cell.notificationButton.addTarget(self, action: #selector(SchoolVC.updateGame(_:)), for: .touchUpInside)
            
            
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
            
        var category = array[indexPath.row].category
        
        if category == "Boys" {
            category = "(B)"
        }
        else if category == "Girls" {
            category = "(G)"
        }
        
        cell.gameNameLabel.text = category + " " + array[indexPath.row].sport
        
        cell.overLabel.isHidden = true
        cell.gameScoreLabel.text = array[indexPath.row].score
    
        cell.updateGameButton.tag = indexPath.row
        cell.updateGameButton.addTarget(self, action: #selector(SchoolVC.updateGame(_:)), for: .touchUpInside)
        
        cell.notificationButton.tag = indexPath.row
        cell.notificationButton.addTarget(self, action: #selector(SchoolVC.updateGame(_:)), for: .touchUpInside)
        
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
    
    func sendEmail() {
        
        if MFMailComposeViewController.canSendMail() {
            print("Can Send mail through MFMail")
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            
            composeVC.setToRecipients(["info@schools-live.com"])
            composeVC.setSubject("Schools-Live")
            composeVC.setMessageBody("", isHTML: false)
            
            self.present(composeVC, animated: true, completion: nil)
        }
        else {
            print("Sending mail through mailto")
            let url = URL(string: "mailto:" + "info@schools-live.com" + "?" + "subject=Schools-Live")
        if #available(iOS 10.0, *) {
            print("With completion handler")
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }
        else {
            print("Without completion")
            UIApplication.shared.openURL(url!)
        }
    }
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updateGame(_ sender: UIButton) {
        print("Update Game Clicked")
        let data = array[sender.tag] as Game
        saveSelectedUpdateGame(game: data)
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
    
    @IBAction func calendarOK(_ sender: UIButton) {
        formatter.dateFormat = "yyyy-M-d"
        
        if dateArray.count < 2 {
            createAlert2(titleText: "Note", messageText: "Please select two date ranges")
        }
        else {
            weekButton.setTitle("THIS WEEK", for: .normal)
            print("Date 1: " + formatter.string(from: dateArray[0]))
            print("Date 2: " + formatter.string(from: dateArray[1]))
            
            /////
            CUIView.isHidden = true
            array.removeAll()
            tableView.reloadData()
            let range1 = dateArray[0]
            let range2 = dateArray[1]
            var game = gameButton.titleLabel?.text!
            print("Current Date: ", formatter.string(from: range1))
            print("Next Week Date: ", formatter.string(from: range2))
            
            if game == "ALL GAMES" {
                let parameters = ["home": school?.schoolName, "away": school?.schoolName, "range1": formatter.string(from: range1), "range2": formatter.string(from: range2)]
                
                if isConnectedToNetwork() {
                    getGames(url: "https://schools-live.com/app/apis/getAllFixtureGamesInRange.php", parameters: parameters as! [String : String])
                }
                else {
                    createAlert2(titleText: "Note", messageText: "Please connect to the Internet")
                }
            }
            else {
                
                if game == "WATERPOLO" {
                    game = "Water polo"
                }
                
                let parameters = ["home": school?.schoolName, "away": school?.schoolName, "sport": game,  "range1": formatter.string(from: range1), "range2": formatter.string(from: range2)]
                
                if isConnectedToNetwork() {
                    getGames(url: "https://schools-live.com/app/apis/getFixtureGamesInRange.php", parameters: parameters as! [String : String])
                }
                else {
                    createAlert2(titleText: "Note", messageText: "Please connect to the Internet")
                }
            }
            
        }
        
    }
    
    @IBAction func calendarCancel(_ sender: UIButton) {
        CUIView.isHidden = true
        weekButton.setTitle("THIS WEEK", for: .normal)
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
            self.performSegue(withIdentifier: "ChangeSchool", sender: nil)
            
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Prepare for Segue called")
        if segue.identifier == "showPopUp1" {
            let popOverViewController = segue.destination
            popOverViewController.popoverPresentationController?.delegate = self
        }
        else if segue.identifier == "showPopUp2" {
            let popOverViewController = segue.destination
            popOverViewController.popoverPresentationController?.delegate = self
        }
        
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        print("Popover dismissed")
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func getWeekFirstDay(from sourceDate:Date) -> Date? {
        let Calendar = NSCalendar(calendarIdentifier: .gregorian)!
       // Calendar.locale = Locale(identifier: "de_DE")
        Calendar.firstWeekday = 2
        let sourceComp = sourceDate.components
        var comp = DateComponents()
        comp.weekOfYear = sourceComp.weekOfYear
        comp.weekday = 2
        comp.yearForWeekOfYear = sourceComp.yearForWeekOfYear
        return Calendar.date(from: comp)
    }
    
   /* func getCurrentDate() -> Date? {
        return Calendar.current.date(byAdding: .day, value: 0, to: Date())
    } */
    
    func getCurrentDate(from sourceDate:Date) -> Date? {
        let Calendar = NSCalendar(calendarIdentifier: .gregorian)!
        let sourceComp = sourceDate.components
        var comp = DateComponents()
        comp.weekOfYear = sourceComp.weekOfYear! + 1
        comp.weekday = 2
        comp.yearForWeekOfYear = sourceComp.yearForWeekOfYear
        return Calendar.date(from: comp)
    }
    
    func getNextWeek(from sourceDate:Date) -> Date? {
        let Calendar = NSCalendar(calendarIdentifier: .gregorian)!
        let sourceComp = sourceDate.components
        var comp = DateComponents()
        comp.weekOfYear = sourceComp.weekOfYear! + 2
        comp.weekday = 1
        comp.yearForWeekOfYear = sourceComp.yearForWeekOfYear
        return Calendar.date(from: comp)
    }
    
    /* func getNextWeek() -> Date? {
        return Calendar.current.date(byAdding: .day, value: 7, to: Date())
    } */
    
   func getWeekLastDay(from sourceDate:Date) -> Date? {
        let Calendar = NSCalendar(calendarIdentifier: .gregorian)!
       // Calendar.locale = Locale(identifier: "de_DE")
        let sourceComp = sourceDate.components
        var comp = DateComponents()
        comp.weekOfYear = sourceComp.weekOfYear! + 1
        comp.weekday = 1
        comp.yearForWeekOfYear = sourceComp.yearForWeekOfYear
        return Calendar.date(from: comp)
    }
    
    func newGetWeekFirstDay() {
        var customCalendar = Calendar(identifier: .gregorian)
        customCalendar.firstWeekday = 1
        var startDate = Date()
        var interval = TimeInterval()
        customCalendar.dateInterval(of: .weekOfMonth, start: &startDate, interval: &interval, for: Date())
        let endDate = startDate.addingTimeInterval(interval - 1)
        print("Custom Calendar Week Interval")
        print(startDate, endDate)
    }
    
    func newestCurrentWeekRange() {
        var calendar = Calendar.current
        calendar.firstWeekday = 3
        let startOfWeek = calendar.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!
        
        print(startOfWeek)
        print(endOfWeek)
    }
    
  /*  func newGetNextWeekFirstDay() {
        var customCalendar = Calendar(identifier: .gregorian)
        customCalendar.firstWeekday = 2
        var startDate = Date()
        (customCalendar.current as NSCalendar).date(byAdding: .day, to: 7, options: <#T##NSCalendar.Options#>)
        var interval = TimeInterval()
        //comp.weekOfYear = sourceComp.weekOfYear!
        //comp.weekday = 7
        //comp.yearForWeekOfYear = sourceComp.yearForWeekOfYear
        
        customCalendar.dateInterval(of: .weekOfMonth + 1, start: &startDate, interval: &interval, for: Date())
        let endDate = startDate.addingTimeInterval(interval - 1)
        print("Custom Calendar Week Interval")
        print(startDate, endDate)
    }
    
    func newGetPreviousWeekFirstDay() {
        var customCalendar = Calendar(identifier: .gregorian)
        customCalendar.firstWeekday = 2
        var startDate = Date()
        var interval = TimeInterval()
     //   customCalendar.dateInterval(of: .weekOfMonth - 1, start: &startDate, interval: &interval, for: Date())
        let endDate = startDate.addingTimeInterval(interval - 1)
        print("Custom Calendar Week Interval")
        print(startDate, endDate)
    } */
    
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
                                        if(self.refreshControl.isRefreshing) {
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
                            if(self.refreshControl.isRefreshing) {
                                self.refreshControl.endRefreshing()
                            }
                            DispatchQueue.main.async {
                                self.createAlert2(titleText: "Note", messageText: "No Games to display")
                            }
                        }
                        break
                    
                    case .failure(let error):
                        self.effectView.isHidden = true
                        print(error.localizedDescription)
                        break;
                }
                
        }
        //print("Something went wrong 2")
        
    }
    
    @objc func getWeek(notification: Notification) {
        print("Got Week")
        let week = notification.object as! String
        self.weekButton.setTitle(week, for: .normal)
        
        school = retrieveSchool()
        
        if school == nil {
            createAlert(titleText: "Note", messageText: "Either add a new School or Select existing one from  Change School")
            
        }
        else {
            print("Week: ", week)
            if week == "THIS WEEK" {
                print("This Week")
                array.removeAll()
                tableView.reloadData()
                let range1 = Date().startOfWeek
                let range2 = Date().endOfWeek
                var game = gameButton.titleLabel?.text!
                let formatter = DateFormatter()
                formatter.calendar = Calendar(identifier: .gregorian)
                formatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
                formatter.dateFormat = "yyyy-M-d"
                print("This Week First Date: ", formatter.string(from: range1!))
                print("This Week Last Date: ", formatter.string(from: range2!))
                
                if game == "ALL GAMES" {
                    let parameters = ["home": school?.schoolName, "away": school?.schoolName, "range1": formatter.string(from: range1!), "range2": formatter.string(from: range2!)]
                    
                    if isConnectedToNetwork() {
                        getGames(url: "https://schools-live.com/app/apis/getAllFixtureGamesInRange.php", parameters: parameters as! [String : String])
                    }
                    else {
                        createAlert2(titleText: "Note", messageText: "Please connect to the Internet")
                    }
                }
                else {
                    
                    if game == "WATERPOLO" {
                        game = "Water polo"
                    }
                    
                    let parameters = ["home": school?.schoolName, "away": school?.schoolName, "sport": game,  "range1": formatter.string(from: range1!), "range2": formatter.string(from: range2!)]
                    
                    if isConnectedToNetwork() {
                        getGames(url: "https://schools-live.com/app/apis/getFixtureGamesInRange.php", parameters: parameters as! [String : String])
                    }
                    else {
                        createAlert2(titleText: "Note", messageText: "Please connect to the Internet")
                    }
                }
            }
            else if week == "NEXT WEEK" {
                print("Next Week")
                array.removeAll()
                tableView.reloadData()
                let range1 = Date().startOfNextWeek
                let range2 = Date().endOfNextWeek
                var game = gameButton.titleLabel?.text!
                let formatter = DateFormatter()
                formatter.calendar = Calendar(identifier: .gregorian)
                formatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
                formatter.dateFormat = "yyyy-M-d"
                print("Current Date: ", formatter.string(from: range1!))
                print("Next Week Date: ", formatter.string(from: range2!))
                
                if game == "ALL GAMES" {
                    let parameters = ["home": school?.schoolName, "away": school?.schoolName, "range1": formatter.string(from: range1!), "range2": formatter.string(from: range2!)]
                    
                    if isConnectedToNetwork() {
                        getGames(url: "https://schools-live.com/app/apis/getAllFixtureGamesInRange.php", parameters: parameters as! [String : String])
                    }
                    else {
                        createAlert2(titleText: "Note", messageText: "Please connect to the Internet")
                    }
                }
                else {
                    
                    if game == "WATERPOLO" {
                        game = "Water polo"
                    }
                    
                    let parameters = ["home": school?.schoolName, "away": school?.schoolName, "sport": game,  "range1": formatter.string(from: range1!), "range2": formatter.string(from: range2!)]
                    
                    if isConnectedToNetwork() {
                        getGames(url: "https://schools-live.com/app/apis/getFixtureGamesInRange.php", parameters: parameters as! [String : String])
                    }
                    else {
                        createAlert2(titleText: "Note", messageText: "Please connect to the Internet")
                    }
                }
            }
            else if week == "C.D. RANGE" {
                array.removeAll()
                tableView.reloadData()
                effectView.isHidden = true
                CUIView.isHidden = false
            }
        }
    }
    
    @objc func getGame(notification: Notification) {
        print("Got Game Schools VC")
        let week = weekButton.titleLabel?.text as String?
        var game = notification.object as! String
        self.gameButton.setTitle(game, for: .normal)
        
        school = retrieveSchool()
        
        if school == nil {
            createAlert(titleText: "Note", messageText: "Either add a new School or Select existing one from  Change School")
            
        }
        else {
            print("Week: ", week!)
            print("Game: ", game)
            if week == "THIS WEEK" {
                print("This Week")
                array.removeAll()
                tableView.reloadData()
                let range1 = Date().startOfWeek
                let range2 = Date().endOfWeek
                let formatter = DateFormatter()
                formatter.calendar = Calendar(identifier: .gregorian)
                formatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
                formatter.dateFormat = "yyyy-M-d"
                print("This Week First Date: ", formatter.string(from: range1!))
                print("This Week Last Date: ", formatter.string(from: range2!))
                
                if game == "ALL GAMES" {
                    let parameters = ["home": school?.schoolName, "away": school?.schoolName, "range1": formatter.string(from: range1!), "range2": formatter.string(from: range2!)]
                    
                    if isConnectedToNetwork() {
                        getGames(url: "https://schools-live.com/app/apis/getAllFixtureGamesInRange.php", parameters: parameters as! [String : String])
                    }
                    else {
                        createAlert2(titleText: "Note", messageText: "Please connect to the Internet")
                    }
                }
                else {
                    
                    if game == "WATERPOLO" {
                        game = "Water polo"
                    }
                    
                    let parameters = ["home": school?.schoolName, "away": school?.schoolName, "sport": game,  "range1": formatter.string(from: range1!), "range2": formatter.string(from: range2!)]
                    
                    if isConnectedToNetwork() {
                        getGames(url: "https://schools-live.com/app/apis/getFixtureGamesInRange.php", parameters: parameters as! [String : String])
                    }
                    else {
                        createAlert2(titleText: "Note", messageText: "Please connect to the Internet")
                    }
                }
            }
            else if week == "NEXT WEEK" {
                print("Next Week")
                array.removeAll()
                tableView.reloadData()
                let range1 = Date().startOfNextWeek
                let range2 = Date().endOfNextWeek
                let formatter = DateFormatter()
                formatter.calendar = Calendar(identifier: .gregorian)
                formatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
                formatter.dateFormat = "yyyy-M-d"
                print("Current Date: ", formatter.string(from: range1!))
                print("Next Week Date: ", formatter.string(from: range2!))
                
                if game == "ALL GAMES" {
                    let parameters = ["home": school?.schoolName, "away": school?.schoolName, "range1": formatter.string(from: range1!), "range2": formatter.string(from: range2!)]
                    
                    if isConnectedToNetwork() {
                        getGames(url: "https://schools-live.com/app/apis/getAllFixtureGamesInRange.php", parameters: parameters as! [String : String])
                    }
                    else {
                        createAlert2(titleText: "Note", messageText: "Please connect to the Internet")
                    }
                }
                else {
                    
                    if game == "WATERPOLO" {
                        game = "Water polo"
                    }
                    
                    let parameters = ["home": school?.schoolName, "away": school?.schoolName, "sport": game,  "range1": formatter.string(from: range1!), "range2": formatter.string(from: range2!)]
                    
                    if isConnectedToNetwork() {
                        getGames(url: "https://schools-live.com/app/apis/getFixtureGamesInRange.php", parameters: parameters as! [String : String])
                    }
                    else {
                        createAlert2(titleText: "Note", messageText: "Please connect to the Internet")
                    }
                }
            }
            else if week == "C.D. RANGE" {
                array.removeAll()
                tableView.reloadData()
                effectView.isHidden = true
                CUIView.isHidden = false
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
                        self.createAlert(titleText: "Note", messageText: error.localizedDescription)
                        break;
                }
        }
    }
    
    @objc func openGames() {
        print("Opening Games")
         NotificationCenter.default.post(name: NSNotification.Name("toggleSideMenu"), object: nil)
        //performSegue(withIdentifier: "Games", sender: nil)
       
        /*let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ContainerVC")
        //self.present(vc, animated: true, completion: nil)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = vc */
        
      /*  let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "ContainerVC") as! ContainerVC
        self.navigationController?.pushViewController(secondViewController, animated: true) */
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func openChange() {
         print("Opening Change School")
         NotificationCenter.default.post(name: NSNotification.Name("toggleSideMenu"), object: nil)
         //performSegue(withIdentifier: "Change", sender: nil)
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChangeSchool") as! ChangeSchoolVC
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    @objc func openEdit() {
         print("Opening Edit School")
         NotificationCenter.default.post(name: NSNotification.Name("toggleSideMenu"), object: nil)
         //performSegue(withIdentifier: "Edit", sender: nil)
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "EditSchool") as! EditSchool1VC
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    @objc func openAdd() {
         print("Opening Add Game")
         NotificationCenter.default.post(name: NSNotification.Name("toggleSideMenu"), object: nil)
         //performSegue(withIdentifier: "Add", sender: nil)
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddSchool") as! AddSchoolVC
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    @objc func openNotifications() {
         print("Opening Notifications")
         NotificationCenter.default.post(name: NSNotification.Name("toggleSideMenu"), object: nil)
         //performSegue(withIdentifier: "Notifications", sender: nil)
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "Notification") as! NotificationsVC
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    @objc func openLeaderboard() {
         print("Opening Learderboard")
         NotificationCenter.default.post(name: NSNotification.Name("toggleSideMenu"), object: nil)
         //performSegue(withIdentifier: "Leader", sender: nil)
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "Leaderboard") as! LeaderboardVC
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    @objc func openUserSettings() {
         print("Opening User Settings")
         NotificationCenter.default.post(name: NSNotification.Name("toggleSideMenu"), object: nil)
         //performSegue(withIdentifier: "User Settings", sender: nil)
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "UserSettings") as! UserSettingsVC
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    @objc func openGetInTouch() {
         print("Opening Get in Touch")
         NotificationCenter.default.post(name: NSNotification.Name("toggleSideMenu"), object: nil)
         sendEmail()
       // performSegue(withIdentifier: "Get In Touch", sender: nil)
    }
    
    @IBAction func openMenu(_ sender: UIButton) {
        print("Button Clicked")
        NotificationCenter.default.post(name: NSNotification.Name("toggleSideMenu"), object: nil)
        
    }
    
    
}

class SavingViewController: UIViewController {
    
     @IBOutlet weak var weekButton1: UIButton!
     @IBOutlet weak var weekButton2: UIButton!
     @IBOutlet weak var weekButton3: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func buttonDone(sender: UIButton) {
        
        if sender.tag == 1 {
            print("Call from ResultVC")
            NotificationCenter.default.post(name: .weekR, object: sender.titleLabel?.text)
            self.dismiss(animated: false, completion: nil)
            
        }
        else {
            print("Call from SchoolVC")
            NotificationCenter.default.post(name: .week, object: sender.titleLabel?.text)
            self.dismiss(animated: false, completion: nil)
            
        }
    }
}

class SavingViewController2: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func buttonDone(sender: UIButton) {
        
        if sender.tag == 1 {
            print("Call from ResultVC")
            NotificationCenter.default.post(name: .gameR, object: sender.titleLabel?.text)
            self.dismiss(animated: false, completion: nil)
        }
        else {
            NotificationCenter.default.post(name: .game, object: sender.titleLabel?.text)
            self.dismiss(animated: false, completion: nil)
        }
    }
}

extension Date {
    var components:DateComponents {
        let cal = NSCalendar.current
        return cal.dateComponents(Set([.year, .month, .day, .hour, .minute, .second, .weekday, .weekOfYear, .yearForWeekOfYear]), from: self)
    }
}

extension SchoolVC: JTACMonthViewDataSource {
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        print("Configure Calendar Function called")
        
      /*  let parameters = ConfigurationParameters(startDate: formatter.date(from: "2018 01 01")!, endDate: formatter.date(from: "2018 12 31")!)
        return parameters */
        
        if let startDate = formatter.date(from: formatter.string(from: Date())) {
            
            let year = Calendar.current.component(.year, from: Date())
            // Get the first day of next year
            if let firstOfNextYear = Calendar.current.date(from: DateComponents(year: year + 1, month: 1, day: 1)) {
                // Get the last day of the current year
                let lastOfYear = Calendar.current.date(byAdding: .day, value: -1, to: firstOfNextYear)
                let lastDate = formatter.date(from: formatter.string(from: lastOfYear!))
                let parameters = ConfigurationParameters(startDate: startDate, endDate: lastDate!)
                return parameters
            }
        }
        return ConfigurationParameters(startDate: formatter.date(from: "2017-01-01")!, endDate: formatter.date(from: "2017-12-31")!)
        
    }
    
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        // This function should have the same code as the cellForItemAt function
        let myCustomCell = cell as! CustomCalendarCell
        sharedFunctionToConfigureCell(myCustomCell: myCustomCell, cellState: cellState, date: date)
    }
    
    func sharedFunctionToConfigureCell(myCustomCell: CustomCalendarCell, cellState: CellState, date: Date) {
        myCustomCell.dateLabel.text = cellState.text
        
       handleCellTextColor(view: myCustomCell, cellState: cellState)
       handleCellSelected(view: myCustomCell, cellState: cellState)
    }
    
}

extension SchoolVC: JTACMonthViewDelegate {
    
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let myCustomCell = calendar.dequeueReusableCell(withReuseIdentifier: "CustomCalendarCell", for: indexPath) as! CustomCalendarCell
        sharedFunctionToConfigureCell(myCustomCell: myCustomCell, cellState: cellState, date: date)
        return myCustomCell
    }
    
    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState) {
            handleCellSelected(view: cell, cellState: cellState)
            handleCellTextColor(view: cell, cellState: cellState)
        
        print("In Select Date (Count): ", calendar.selectedDates.count)
            print("In Select Date: ", calendar.selectedDates)
        dateArray = calendar.selectedDates
    }
    
    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState) {
            handleCellSelected(view: cell, cellState: cellState)
            handleCellTextColor(view: cell, cellState: cellState)
            dateArray = calendar.selectedDates
 
    }
    
    func calendar(_ calendar: JTACMonthView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
            setupViewsOfCalendar(from: visibleDates)
    }
    
    func calendar(_ calendar: JTACMonthView, shouldSelectDate date: Date, cell: JTACMonthCell?, cellState: CellState) -> Bool {
        print("Should Select Date called")
        
        if calendar.selectedDates.count < 2 {
            return true
       }
        else {
            return false
        }
    }
}

extension UIColor {
    
    convenience init(colorWithHexValue value: Int, alpha:CGFloat = 1.0) {
        self.init (
            red:CGFloat((value & 0xFF0000) >> 16) / 255.0,
            green:CGFloat((value & 0x00FF00) >> 8) / 255.0,
            blue:CGFloat(value & 0x0000FF) / 255.0,
            alpha:alpha
        )
    }
    
}

/*public extension UIDevice {
    public var type: Model {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
                
            }
        }
        var modelMap : [ String : Model ] = [
            "i386"       : .simulator,
            "x86_64"     : .simulator,
            "iPod1,1"    : .iPod1,
            "iPod2,1"    : .iPod2,
            "iPod3,1"    : .iPod3,
            "iPod4,1"    : .iPod4,
            "iPod5,1"    : .iPod5,
            "iPad2,1"    : .iPad2,
            "iPad2,2"    : .iPad2,
            "iPad2,3"    : .iPad2,
            "iPad2,4"    : .iPad2,
            "iPad2,5"    : .iPadMini1,
            "iPad2,6"    : .iPadMini1,
            "iPad2,7"    : .iPadMini1,
            "iPhone3,1"  : .iPhone4,
            "iPhone3,2"  : .iPhone4,
            "iPhone3,3"  : .iPhone4,
            "iPhone4,1"  : .iPhone4S,
            "iPhone5,1"  : .iPhone5,
            "iPhone5,2"  : .iPhone5,
            "iPhone5,3"  : .iPhone5C,
            "iPhone5,4"  : .iPhone5C,
            "iPad3,1"    : .iPad3,
            "iPad3,2"    : .iPad3,
            "iPad3,3"    : .iPad3,
            "iPad3,4"    : .iPad4,
            "iPad3,5"    : .iPad4,
            "iPad3,6"    : .iPad4,
            "iPhone6,1"  : .iPhone5S,
            "iPhone6,2"  : .iPhone5S,
            "iPad4,1"    : .iPadAir1,
            "iPad4,2"    : .iPadAir2,
            "iPad4,4"    : .iPadMini2,
            "iPad4,5"    : .iPadMini2,
            "iPad4,6"    : .iPadMini2,
            "iPad4,7"    : .iPadMini3,
            "iPad4,8"    : .iPadMini3,
            "iPad4,9"    : .iPadMini3,
            "iPad6,3"    : .iPadPro9_7,
            "iPad6,11"   : .iPadPro9_7,
            "iPad6,4"    : .iPadPro9_7_cell,
            "iPad6,12"   : .iPadPro9_7_cell,
            "iPad6,7"    : .iPadPro12_9,
            "iPad6,8"    : .iPadPro12_9_cell,
            "iPad7,3"    : .iPadPro10_5,
            "iPad7,4"    : .iPadPro10_5_cell,
            "iPhone7,1"  : .iPhone6plus,
            "iPhone7,2"  : .iPhone6,
            "iPhone8,1"  : .iPhone6S,
            "iPhone8,2"  : .iPhone6Splus,
            "iPhone8,4"  : .iPhoneSE,
            "iPhone9,1"  : .iPhone7,
            "iPhone9,2"  : .iPhone7plus,
            "iPhone9,3"  : .iPhone7,
            "iPhone9,4"  : .iPhone7plus,
            "iPhone10,1" : .iPhone8,
            "iPhone10,2" : .iPhone8plus,
            "iPhone10,3" : .iPhoneX
        ]
        
        if let model = modelMap[String.init(validatingUTF8: modelCode!)!] {
            return model
        }
        return Model.unrecognized
    }
} */

extension Date {
    var startOfWeek: Date? {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.firstWeekday = 2
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 1, to: sunday)
    }
    
    var endOfWeek: Date? {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.firstWeekday = 2
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 7, to: sunday)
    }
    
    var startOfNextWeek: Date? {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.firstWeekday = 2
        guard let sunday = gregorian.date(from:
            gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        let store = gregorian.date(byAdding: .weekOfMonth, value: 1, to: sunday)
        return gregorian.date(byAdding: .day, value: 1, to: store!)
    }
    
    var endOfNextWeek: Date? {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.firstWeekday = 2
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        let store = gregorian.date(byAdding: .weekOfMonth, value: 1, to: sunday)
        return gregorian.date(byAdding: .day, value: 7, to: store!)
    }
    
    var startOfPreviousWeek: Date? {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.firstWeekday = 2
        guard let sunday = gregorian.date(from:
            gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        let store = gregorian.date(byAdding: .weekOfMonth, value: -1, to: sunday)
        return gregorian.date(byAdding: .day, value: 1, to: store!)
    }
    
    var endOfPreviousWeek: Date? {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.firstWeekday = 2
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        let store = gregorian.date(byAdding: .weekOfMonth, value: -1, to: sunday)
        return gregorian.date(byAdding: .day, value: 7, to: store!)
    }
}
