//
//  ResultsVC.swift
//  Schools-Live
//
//  Created by Hamza  Amin on 12/9/17.
//  Copyright © 2017 Hamza  Amin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import JTAppleCalendar

class ResultsVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate {

    let outsideMonthColor = UIColor.gray
    let monthColor = UIColor.black
    let selectedMonthColor = UIColor.white
    let currentDateSelectedViewColor = UIColor(colorWithHexValue: 0x4e3f5d)
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var weekButton: UIButton!
    @IBOutlet weak var gameButton: UIButton!
    @IBOutlet weak var schoolTypeLabel: UILabel!
    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var schoolLocationLabel: UILabel!
    @IBOutlet weak var schoolWebsiteLabel: UILabel!
    @IBOutlet weak var homeSchoolBatBowlL: UILabel!
    @IBOutlet weak var awaySchoolBatBowlL: UILabel!
    @IBOutlet weak var calendarView: JTACMonthView!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var CUIView: UIView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    var array = [Game] ()
    var school: School?
    let messageFrame = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    var formatter = DateFormatter()
    var dateArray = [Date]()
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        CUIView.layer.borderColor = UIColor.black.cgColor
        CUIView.layer.borderWidth = 1
        CUIView.isHidden = true
        setupCalendar()
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(willEnterForeground), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(getWeek), name: .weekR, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(getGameResult), name: .gameR, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    @objc func willEnterForeground() {
        print("ResultsVC came in foreground")
        CUIView.isHidden = true
        if self.isViewLoaded && (self.view.window != nil) {
        
        weekButton.setTitle("THIS WEEK", for: .normal)
        gameButton.setTitle("ALL GAMES", for: .normal)
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
         //   schoolWebsiteLabel.text = school?.schoolWebsite
            if weekButton.titleLabel?.text == "THIS WEEK" {
                array.removeAll()
                tableView.reloadData()
                let range1 = Date().startOfWeek
                let range2 = Date().endOfWeek
                var game = gameButton.titleLabel?.text!
                let formatter = DateFormatter()
                formatter.calendar = Calendar(identifier: .gregorian)
                formatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
                formatter.dateFormat = "yyy-M-d"
                print("This Week First Date: ", formatter.string(from: range1!))
                print("This Week Last Date: ", formatter.string(from: range2!))
                
                if game == "ALL GAMES" {
                    let parameters = ["home": school?.schoolName, "away": school?.schoolName, "range1": formatter.string(from: range1!), "range2": formatter.string(from: range2!)]
                    getGames(url: "https://schools-live.com/app/apis/getAllEndedGamesInRange.php", parameters: parameters as! [String : String])
                }
                else {
                    
                    if game == "WATERPOLO" {
                        game = "Water polo"
                    }
                    
                    let parameters = ["home": school?.schoolName, "away": school?.schoolName, "sport": game,  "range1": formatter.string(from: range1!), "range2": formatter.string(from: range2!)]
                    getGames(url: "https://schools-live.com/app/apis/getEndedGamesInRange.php", parameters: parameters as! [String : String])
                }
            }
            else if weekButton.titleLabel?.text == "LAST WEEK" {
                array.removeAll()
                tableView.reloadData()
                let range1 = Date().startOfPreviousWeek
                let range2 = Date().endOfPreviousWeek
                var game = gameButton.titleLabel?.text!
                let formatter = DateFormatter()
                formatter.calendar = Calendar(identifier: .gregorian)
                formatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
                formatter.dateFormat = "yyy-M-d"
                print("Current Date: ", formatter.string(from: range1!))
                print("Next Week Date: ", formatter.string(from: range2!))
                
                if game == "ALL GAMES" {
                    let parameters = ["home": school?.schoolName, "away": school?.schoolName, "range1": formatter.string(from: range1!), "range2": formatter.string(from: range2!)]
                    getGames(url: "https://schools-live.com/app/apis/getAllEndedGamesInRange.php", parameters: parameters as! [String : String])
                }
                else {
                    
                    if game == "WATERPOLO" {
                        game = "Water polo"
                    }
                    
                    let parameters = ["home": school?.schoolName, "away": school?.schoolName, "sport": game,  "range1": formatter.string(from: range1!), "range2": formatter.string(from: range2!)]
                    getGames(url: "https://schools-live.com/app/apis/getEndedGamesInRange.php", parameters: parameters as! [String : String])
                }
            }
            else if weekButton.titleLabel?.text == "C.D. RANGE" {
                array.removeAll()
                tableView.reloadData()
                effectView.isHidden = true
                CUIView.isHidden = false
            }
        }
        }
        else {
            print("Results VC is NOT visible")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("View Will Appear Called")
        
        weekButton.setTitle("THIS WEEK", for: .normal)
        gameButton.setTitle("ALL GAMES", for: .normal)
        CUIView.isHidden = true
        
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
            if weekButton.titleLabel?.text == "THIS WEEK" {
                array.removeAll()
                tableView.reloadData()
                let range1 = Date().startOfWeek
                let range2 = Date().endOfWeek
                var game = gameButton.titleLabel?.text!
                let formatter = DateFormatter()
                formatter.calendar = Calendar(identifier: .gregorian)
                formatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
                formatter.dateFormat = "yyy-M-d"
                print("This Week First Date: ", formatter.string(from: range1!))
                print("This Week Last Date: ", formatter.string(from: range2!))
                
                if game == "ALL GAMES" {
                    let parameters = ["home": school?.schoolName, "away": school?.schoolName, "range1": formatter.string(from: range1!), "range2": formatter.string(from: range2!)]
                    getGames(url: "https://schools-live.com/app/apis/getAllEndedGamesInRange.php", parameters: parameters as! [String : String])
                }
                else {
                    
                    if game == "WATERPOLO" {
                        game = "Water polo"
                    }
                    
                    let parameters = ["home": school?.schoolName, "away": school?.schoolName, "sport": game,  "range1": formatter.string(from: range1!), "range2": formatter.string(from: range2!)]
                    getGames(url: "https://schools-live.com/app/apis/getEndedGamesInRange.php", parameters: parameters as! [String : String])
                }
            }
            else if weekButton.titleLabel?.text == "LAST WEEK" {
                array.removeAll()
                tableView.reloadData()
                let range1 = Date().startOfPreviousWeek
                let range2 = Date().endOfPreviousWeek
                var game = gameButton.titleLabel?.text!
                let formatter = DateFormatter()
                formatter.calendar = Calendar(identifier: .gregorian)
                formatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
                formatter.dateFormat = "yyyy-M-d"
                print("Current Date: ", formatter.string(from: range1!))
                print("Next Week Date: ", formatter.string(from: range2!))
                
                if game == "ALL GAMES" {
                    let parameters = ["home": school?.schoolName, "away": school?.schoolName, "range1": formatter.string(from: range1!), "range2": formatter.string(from: range2!)]
                    getGames(url: "https://schools-live.com/app/apis/getAllEndedGamesInRange.php", parameters: parameters as! [String : String])
                }
                else {
                    
                    if game == "WATERPOLO" {
                        game = "Water polo"
                    }
                    
                    let parameters = ["home": school?.schoolName, "away": school?.schoolName, "sport": game,  "range1": formatter.string(from: range1!), "range2": formatter.string(from: range2!)]
                    getGames(url: "https://schools-live.com/app/apis/getEndedGamesInRange.php", parameters: parameters as! [String : String])
                }
            }
            else if weekButton.titleLabel?.text == "C.D. RANGE" {
                array.removeAll()
                tableView.reloadData()
                effectView.isHidden = true
                CUIView.isHidden = false
            }
        }
    }
    
    func setupCalendar() {
        calendarView.allowsMultipleSelection = true
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        calendarView.scrollToDate(Date()) 
        
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
        
        print("Home School Name: ", array[indexPath.row].homeSchoolName)
        print("Away School Name: ", array[indexPath.row].awaySchoolName)
        print("Game: ", array[indexPath.row].sport + " " + array[indexPath.row].ageGroup + "/" + array[indexPath.row].team)
        
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
            cell.awaySchoolImage.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "Place Holder"))
            cell.gameTimeLabel.text = UTCToLocal(date: array[indexPath.row].startTime)
            cell.lastUpdateByLabel.text = array[indexPath.row].lastUpdateBy
            cell.homeTeamScoreLabel.adjustsFontSizeToFitWidth = true
            cell.awayTeamScoreLabel.adjustsFontSizeToFitWidth = true
            cell.homeTeamOverLabel.adjustsFontSizeToFitWidth = true
            cell.awayTeamOverLabel.adjustsFontSizeToFitWidth = true
            var category = array[indexPath.row].category
            
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
                let away = array[indexPath.row].awaySchoolName.trimmingCharacters(in: .whitespacesAndNewlines)
                
                if home == homeTeamScore2[2].trimmingCharacters(in: .whitespacesAndNewlines) {
                    cell.homeSchoolBatBowlL.text = "(Bat)";
                    cell.awaySchoolBatBowlL.text = "(Bowl)";
                }
                else {
                    print("Got in else here")
                    cell.homeSchoolBatBowlL.text = "(Bowl)";
                    cell.awaySchoolBatBowlL.text = "(Bat)";
                }
                print("Bat/Bowl team: ", homeTeamScore2[2])
                let status = array[indexPath.row].status
                let game = array[indexPath.row].sport
                
                if status == "FULL TIME" && game == "Cricket" {
                    print("Ended Game")
                    let whoWon = array[indexPath.row].whoWon.trimmingCharacters(in: .whitespacesAndNewlines)
                    cell.homeSchoolBatBowlL.isHidden = false
                    cell.awaySchoolBatBowlL.isHidden = false
                    if whoWon == home {
                        cell.homeSchoolBatBowlL.text = "WON"
                        cell.awaySchoolBatBowlL.text = "LOST"
                    }
                    else if whoWon == away {
                        cell.homeSchoolBatBowlL.text = "LOST"
                        cell.awaySchoolBatBowlL.text = "WON"
                    }
                    else if whoWon == "Draw" {
                        cell.homeSchoolBatBowlL.text = "Draw"
                        cell.awaySchoolBatBowlL.text = "Draw"
                    }
                    else if whoWon == "Tie" {
                        cell.homeSchoolBatBowlL.text = "Tie"
                        cell.awaySchoolBatBowlL.text = "Tie"
                    }
                    else {
                        //cell.homeSchoolBatBowlL.isHidden = true
                        //cell.awaySchoolBatBowlL.isHidden = true
                    }
                }
                else {
                    print("Not Ended Game")
                }
                
            }
            else {
                cell.homeTeamScoreLabel.text = "0/0"
                cell.homeTeamOverLabel.text = "Over: 0"
                cell.awayTeamScoreLabel.text = "0/0"
                cell.awayTeamOverLabel.text = "Over: 0"
                cell.homeSchoolBatBowlL.isHidden = true
                cell.awaySchoolBatBowlL.isHidden = true
                
                let home = array[indexPath.row].homeSchoolName.trimmingCharacters(in: .whitespacesAndNewlines)
                let away = array[indexPath.row].awaySchoolName.trimmingCharacters(in: .whitespacesAndNewlines)
                let status = array[indexPath.row].status
                let game = array[indexPath.row].sport
                
                if status == "FULL TIME" && game == "Cricket" {
                    print("Ended Game")
                    let whoWon = array[indexPath.row].whoWon.trimmingCharacters(in: .whitespacesAndNewlines)
                    cell.homeSchoolBatBowlL.isHidden = false
                    cell.awaySchoolBatBowlL.isHidden = false
                    if whoWon == home {
                        cell.homeSchoolBatBowlL.text = "WON"
                        cell.awaySchoolBatBowlL.text = "LOST"
                    }
                    else if whoWon == away {
                        cell.homeSchoolBatBowlL.text = "LOST"
                        cell.awaySchoolBatBowlL.text = "WON"
                    }
                    else if whoWon == "Draw" {
                        cell.homeSchoolBatBowlL.text = "Draw"
                        cell.awaySchoolBatBowlL.text = "Draw"
                    }
                    else if whoWon == "Tie" {
                        cell.homeSchoolBatBowlL.text = "Tie"
                        cell.awaySchoolBatBowlL.text = "Tie"
                    }
                    else {
                        cell.homeSchoolBatBowlL.isHidden = true
                        cell.awaySchoolBatBowlL.isHidden = true
                    }
                }
            }
            
            cell.updateGameButton.tag = indexPath.row
            cell.updateGameButton.setTitle("Game Details", for: .normal)
            cell.updateGameButton.addTarget(self, action: #selector(ResultsVC.updateGame(_:)), for: .touchUpInside)
            
            return cell
        }
        else {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gamecell", for: indexPath) as! GameTVCell
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
        cell.awaySchoolImage.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "Place Holder"))
        cell.gameTimeLabel.text = UTCToLocal(date: array[indexPath.row].startTime)
        cell.lastUpdateByLabel.text = array[indexPath.row].lastUpdateBy
      
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
            
        if array[indexPath.row].chatBubble == "Yes" {
            cell.chatBubble.isHidden = false
        }
        else {
            cell.chatBubble.isHidden = true
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
                cell.overLabel.text = "C. Over: " + cricStore[4]
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
                
                if status == "FULL TIME" && game == "Cricket" {
                    let whoWon = array[indexPath.row].whoWon
                    
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
            cell.gameScoreLabel.text = array[indexPath.row].score
            cell.homeSchoolBatBowlL.isHidden = true
            cell.awaySchoolBatBowlL.isHidden = true
            
        }
        cell.updateGameButton.tag = indexPath.row
        cell.updateGameButton.setTitle("Game Details", for: .normal)
        cell.updateGameButton.addTarget(self, action: #selector(ResultsVC.updateGame(_:)), for: .touchUpInside)
        
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
                
        }
    }
    
    @IBAction func openMenu(_ sender: UIButton) {
        print("Button Clicked")
        NotificationCenter.default.post(name: NSNotification.Name("toggleSideMenu"), object: nil)
    }
    
    @IBAction func updateGame(_ sender: UIButton) {
        print("Update Game Clicked")
        let data = array[sender.tag] as Game
        saveSelectedUpdateGame(game: data)
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
    
  /*  func getCurrentDate() -> Date? {
        return Calendar.current.date(byAdding: .day, value: 0, to: Date())
    } */
    
    func getCurrentDate(from sourceDate: Date) -> Date? {
        let Calendar = NSCalendar(calendarIdentifier: .gregorian)!
        let sourceComp = sourceDate.components
        var comp = DateComponents()
        comp.weekOfYear = sourceComp.weekOfYear!
        comp.weekday = 1
        comp.yearForWeekOfYear = sourceComp.yearForWeekOfYear
        return Calendar.date(from: comp)
    }
    
    func getLastWeekDate(from sourceDate: Date) -> Date? {
        let Calendar = NSCalendar(calendarIdentifier: .gregorian)!
        let sourceComp = sourceDate.components
        var comp = DateComponents()
        comp.weekOfYear = sourceComp.weekOfYear! - 1
        comp.weekday = 2
        comp.yearForWeekOfYear = sourceComp.yearForWeekOfYear
        return Calendar.date(from: comp)
    }
    
   /* func getLastWeekDate() -> Date? {
        return Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())
    } */
    
    func getWeekFirstDay(from sourceDate:Date) -> Date? {
        let Calendar = NSCalendar(calendarIdentifier: .gregorian)!
        let sourceComp = sourceDate.components
        var comp = DateComponents()
        comp.weekOfYear = sourceComp.weekOfYear
        comp.weekday = 2
        comp.yearForWeekOfYear = sourceComp.yearForWeekOfYear
        return Calendar.date(from: comp)
    }
    
    func getWeekLastDay(from sourceDate:Date) -> Date? {
        let Calendar = NSCalendar(calendarIdentifier: .gregorian)!
        let sourceComp = sourceDate.components
        var comp = DateComponents()
        comp.weekOfYear = sourceComp.weekOfYear! + 1
        comp.weekday = 1
        comp.yearForWeekOfYear = sourceComp.yearForWeekOfYear
        return Calendar.date(from: comp)
    }
    
    func getGames(url: String, parameters: [String: String]) {
        if isConnectedToNetwork() {
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
                        self.createAlert2(titleText: "Note", messageText: error.localizedDescription)
                        break;
                }
            }
        }
        else {
            createAlert2(titleText: "Note", messageText: "Please connect to the Internet")
        }
        
    }
    
    @objc func getWeek(notification: Notification) {
        print("Got Week Result")
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
                formatter.dateFormat = "yyy-M-d"
                print("This Week First Date: ", formatter.string(from: range1!))
                print("This Week Last Date: ", formatter.string(from: range2!))
                
                if game == "ALL GAMES" {
                    let parameters = ["home": school?.schoolName, "away": school?.schoolName, "range1": formatter.string(from: range1!), "range2": formatter.string(from: range2!)]
                    getGames(url: "https://schools-live.com/app/apis/getAllEndedGamesInRange.php", parameters: parameters as! [String : String])
                }
                else {
                    
                    if game == "WATERPOLO" {
                        game = "Water polo"
                    }
                    
                    let parameters = ["home": school?.schoolName, "away": school?.schoolName, "sport": game,  "range1": formatter.string(from: range1!), "range2": formatter.string(from: range2!)]
                    getGames(url: "https://schools-live.com/app/apis/getEndedGamesInRange.php", parameters: parameters as! [String : String])
                }
            }
            else if week == "LAST WEEK" {
                print("Next Week")
                array.removeAll()
                tableView.reloadData()
                let range1 = Date().startOfPreviousWeek
                let range2 = Date().endOfPreviousWeek
                var game = gameButton.titleLabel?.text!
                let formatter = DateFormatter()
                formatter.calendar = Calendar(identifier: .gregorian)
                formatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
                formatter.dateFormat = "yyy-M-d"
                print("Current Date: ", formatter.string(from: range1!))
                print("Next Week Date: ", formatter.string(from: range2!))
                
                if game == "ALL GAMES" {
                    let parameters = ["home": school?.schoolName, "away": school?.schoolName, "range1": formatter.string(from: range1!), "range2": formatter.string(from: range2!)]
                    getGames(url: "https://schools-live.com/app/apis/getAllEndedGamesInRange.php", parameters: parameters as! [String : String])
                }
                else {
                    
                    if game == "WATERPOLO" {
                        game = "Water polo"
                    }
                    
                    let parameters = ["home": school?.schoolName, "away": school?.schoolName, "sport": game,  "range1": formatter.string(from: range1!), "range2": formatter.string(from: range2!)]
                    getGames(url: "https://schools-live.com/app/apis/getEndedGamesInRange.php", parameters: parameters as! [String : String])
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
    
    @objc func getGameResult(notification: Notification) {
        print("Got Game Result")
        let week = weekButton.titleLabel?.text as String?
        var game = notification.object as! String
        self.gameButton.setTitle(game, for: .normal)
        
        school = retrieveSchool()
        
        if school == nil {
            
            DispatchQueue.main.async {
                self.createAlert(titleText: "Note", messageText: "Either add a new School or Select existing one from  Change School")
            }
            
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
                formatter.dateFormat = "yyy-M-d"
                print("This Week First Date: ", formatter.string(from: range1!))
                print("This Week Last Date: ", formatter.string(from: range2!))
                
                if game == "ALL GAMES" {
                    let parameters = ["home": school?.schoolName, "away": school?.schoolName, "range1": formatter.string(from: range1!), "range2": formatter.string(from: range2!)]
                    getGames(url: "https://schools-live.com/app/apis/getAllEndedGamesInRange.php", parameters: parameters as! [String : String])
                }
                else {
                    
                    if game == "WATERPOLO" {
                        game = "Water polo"
                    }
                    
                    let parameters = ["home": school?.schoolName, "away": school?.schoolName, "sport": game,  "range1": formatter.string(from: range1!), "range2": formatter.string(from: range2!)]
                    getGames(url: "https://schools-live.com/app/apis/getEndedGamesInRange.php", parameters: parameters as! [String : String])
                }
            }
            else if week == "LAST WEEK" {
                print("Next Week")
                array.removeAll()
                tableView.reloadData()
                let range1 = Date().startOfPreviousWeek
                let range2 = Date().endOfPreviousWeek
                let formatter = DateFormatter()
                formatter.calendar = Calendar(identifier: .gregorian)
                formatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
                formatter.dateFormat = "yyyy-M-d"
                print("Current Date: ", formatter.string(from: range1!))
                print("Next Week Date: ", formatter.string(from: range2!))
                
                if game == "ALL GAMES" {
                    let parameters = ["home": school?.schoolName, "away": school?.schoolName, "range1": formatter.string(from: range1!), "range2": formatter.string(from: range2!)]
                    getGames(url: "https://schools-live.com/app/apis/getAllEndedGamesInRange.php", parameters: parameters as! [String : String])
                }
                else {
                    
                    if game == "WATERPOLO" {
                        game = "Water polo"
                    }
                    
                    let parameters = ["home": school?.schoolName, "away": school?.schoolName, "sport": game,  "range1": formatter.string(from: range1!), "range2": formatter.string(from: range2!)]
                    getGames(url: "https://schools-live.com/app/apis/getEndedGamesInRange.php", parameters: parameters as! [String : String])
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
    
    @IBAction func openContainerVC(_ sender: UIButton) {
      /*  let vc: UIViewController! = self.storyboard!.instantiateViewController(withIdentifier: "ContainerVC")
        
        let window = UIApplication.shared.windows[0];
        window.rootViewController = vc; */
         self.navigationController?.popToRootViewController(animated: true)
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
                getGames(url: "https://schools-live.com/app/apis/getAllEndedGamesInRange.php", parameters: parameters as! [String : String])
            }
            else {
                
                if game == "WATERPOLO" {
                    game = "Water polo"
                }
                
                let parameters = ["home": school?.schoolName, "away": school?.schoolName, "sport": game,  "range1": formatter.string(from: range1), "range2": formatter.string(from: range2)]
                getGames(url: "https://schools-live.com/app/apis/getEndedGamesInRange.php", parameters: parameters as! [String : String])
            }
            
        }
        
    }
    
    @IBAction func calendarCancel(_ sender: UIButton) {
        CUIView.isHidden = true
        weekButton.setTitle("THIS WEEK", for: .normal)
    }
}

/*
class SavingViewController3: UIViewController {
    
    @IBOutlet weak var weekButton1: UIButton!
    @IBOutlet weak var weekButton2: UIButton!
    @IBOutlet weak var weekButton3: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func buttonDone(sender: UIButton) {
        NotificationCenter.default.post(name: .weekR, object: sender.titleLabel?.text)
        self.dismiss(animated: false, completion: nil)
    }
}

class SavingViewController4: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func buttonDone(sender: UIButton) {
        NotificationCenter.default.post(name: .gameR, object: sender.titleLabel?.text)
        self.dismiss(animated: false, completion: nil)
    }
} */

extension ResultsVC: JTACMonthViewDataSource {
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        print("Configure Calendar Function called")
        
        /*  let parameters = ConfigurationParameters(startDate: formatter.date(from: "2018 01 01")!, endDate: formatter.date(from: "2018 12 31")!)
         return parameters */
        
        if let startDate = formatter.date(from: formatter.string(from: formatter.date(from: "2017 01 01")!)) {
            
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
    
/*    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACMonthCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        // This function should have the same code as the cellForItemAt function
        let myCustomCell = cell as! CustomCalendarCell
        sharedFunctionToConfigureCell(myCustomCell: myCustomCell, cellState: cellState, date: date)
    }
*/
    func sharedFunctionToConfigureCell(myCustomCell: CustomCalendarCell, cellState: CellState, date: Date) {
        myCustomCell.dateLabel.text = cellState.text
        
        handleCellTextColor(view: myCustomCell, cellState: cellState)
        handleCellSelected(view: myCustomCell, cellState: cellState)
    }
    
}

extension ResultsVC: JTACMonthViewDelegate {
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let myCustomCell = calendar.dequeueReusableCell(withReuseIdentifier: "CustomCalendarCell", for: indexPath) as! CustomCalendarCell
        sharedFunctionToConfigureCell(myCustomCell: myCustomCell, cellState: cellState, date: date)
        return myCustomCell
    }
    
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let myCustomCell = cell as! CustomCalendarCell
        sharedFunctionToConfigureCell(myCustomCell: myCustomCell, cellState: cellState, date: date)
    }
    
    
   /* func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACMonthCell {
        let myCustomCell = calendar.dequeueReusableCell(withReuseIdentifier: "CustomCalendarCell", for: indexPath) as! CustomCalendarCell
        sharedFunctionToConfigureCell(myCustomCell: myCustomCell, cellState: cellState, date: date)
        return myCustomCell
    }*/
    
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
