//
//  UpdateGameCricketVC.swift
//  Schools-Live
//
//  Created by Hamza  Amin on 02/19/18.
//  Copyright © 2018 Hamza  Amin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class UpdateGameCricketVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var schoolTypeLabel: UILabel!
    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var schoolLocationLabel: UILabel!
    @IBOutlet weak var schoolWebsiteLabel: UILabel!
    @IBOutlet weak var homeSchoolIV: UIImageView!
    @IBOutlet weak var homeSchoolTypeL: UILabel!
    @IBOutlet weak var homeSchoolNameL: UILabel!
    @IBOutlet weak var homeSchoolBatBowlL: UILabel!
    @IBOutlet weak var homeSchoolAgeTeamL: UILabel!
    @IBOutlet weak var awaySchoolIV: UIImageView!
    @IBOutlet weak var awaySchoolTypeL: UILabel!
    @IBOutlet weak var awaySchoolNameL: UILabel!
    @IBOutlet weak var awaySchoolBatBowlL: UILabel!
    @IBOutlet weak var awaySchoolAgeTeamL: UILabel!
    @IBOutlet weak var homeSchoolScoreL: UILabel!
    @IBOutlet weak var awaySchoolScoreL: UILabel!
    @IBOutlet weak var chatBubble: UIImageView!
    @IBOutlet weak var startTimeL: UILabel!
    @IBOutlet weak var statusL: UILabel!
    @IBOutlet weak var homeSchoolOvers: UILabel!
    @IBOutlet weak var awaySchoolOvers: UILabel!
    @IBOutlet weak var temperatureL: UILabel!
    @IBOutlet weak var weatherL: UILabel!
    @IBOutlet weak var weatherIV: UIImageView!
    @IBOutlet weak var gameSportAndAgeGroupL: UILabel!
    @IBOutlet weak var userL: UILabel!
    @IBOutlet weak var lastUpdateTimeL: UILabel!
    @IBOutlet weak var oversTF: UITextField!
    @IBOutlet weak var wicketsTF: UITextField!
    @IBOutlet weak var battingTF: UITextField!
    @IBOutlet weak var bowlingTF: UITextField!
    @IBOutlet weak var shareB: UIButton!
    @IBOutlet weak var updateScoreB: UIButton!
    @IBOutlet weak var updateWeatherB: UIButton!
    @IBOutlet weak var chatB: UIButton!
    @IBOutlet weak var updateScore1: UIButton!
    @IBOutlet weak var cancelScore1: UIButton!
    @IBOutlet weak var updateEndCricketTeamB: UIButton!
    @IBOutlet weak var cancelEndCricketTeamB: UIButton!
    @IBOutlet weak var chatTV: UITextView!
    @IBOutlet weak var statusPickerView: UIPickerView!
    @IBOutlet weak var scorePickerView1: UIPickerView!
    @IBOutlet weak var scorePickerView2: UIPickerView!
    @IBOutlet weak var cricketScorePickerView: UIPickerView!
    @IBOutlet weak var weatherPickerView: UIPickerView!
    @IBOutlet weak var temperaturePickerView: UIPickerView!
    @IBOutlet weak var endCricketPickerView: UIPickerView!
    @IBOutlet weak var battingTeamTableView: UITableView!
    @IBOutlet weak var bowlingTeamTableView: UITableView!
    @IBOutlet weak var oversTableView: UITableView!
    @IBOutlet weak var wicketsTableView: UITableView!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var chatView: UIView!
    @IBOutlet weak var scoreView1: UIView!
    @IBOutlet weak var scoreView2: UIView!
    @IBOutlet weak var weatherView1: UIView!
    @IBOutlet weak var weatherView2: UIView!
    @IBOutlet weak var endCricketView: UIView!
    @IBOutlet weak var srollViewHeight: NSLayoutConstraint!
    
    let screenHeight = UIScreen.main.bounds.height
    let scrollViewContentHeight = 1200 as CGFloat

    var array = [Game] ()
    var chatArray = [Chat] ()
    var weatherArray = [ "Rainy", "Cloudy", "Partly Cloudy", "Sunshine", "Strong Wind" ]
    var temperatureSymbolArray = ["+", "-"]
    var temperatureArray = [Int] (0 ... 50)
    var gameStatusArray = [ "NOT STARTED", "1st HALF", "HALF TIME", "2nd HALF", "FULL TIME" ]
    var endCricketArray = ["Draw", "Tie"]
    var oversArray = [Int] (0 ... 150)
    var wicketsArray = [Int] (0 ... 10)
    var scoreArray = [Int] (0 ... 999)
    var cricketScoreArray = [Int] (0 ... 500)
    var battingArray = [String] ()
    var bowlingArray = [String] ()
    var school: School?
    var game: Game?
    var utcTime: String = ""
    var batting: String = ""
    var bowling: String = ""
    var overs: String = ""
    var didStatusCalled = false
    let messageFrame = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // CGSize(
        
        /*    scrollView.contentSize = CGSize(width: scrollView.frame.width, height:scrollViewContentHeight)
         scrollView.delegate = self
         chatTableView.delegate = self
         scrollView.bounces = false
         chatTableView.bounces = false
         chatTableView.isScrollEnabled = false */
        
        scoreView1.layer.borderColor = UIColor.black.cgColor
        scoreView1.layer.borderWidth = 1
        
        scoreView2.layer.borderColor = UIColor.black.cgColor
        scoreView2.layer.borderWidth = 1
        
        weatherView1.layer.borderColor = UIColor.black.cgColor
        weatherView1.layer.borderWidth = 1
        
        weatherView2.layer.borderColor = UIColor.black.cgColor
        weatherView2.layer.borderWidth = 1
        
        endCricketView.layer.borderColor = UIColor.black.cgColor
        endCricketView.layer.borderWidth = 1
        
        oversTableView.layer.borderColor = UIColor.black.cgColor
        oversTableView.layer.borderWidth = 1
        
        wicketsTableView.layer.borderColor = UIColor.black.cgColor
        wicketsTableView.layer.borderWidth = 1
        
        battingTeamTableView.layer.borderColor = UIColor.black.cgColor
        battingTeamTableView.layer.borderWidth = 1
        
        bowlingTeamTableView.layer.borderColor = UIColor.black.cgColor
        bowlingTeamTableView.layer.borderWidth = 1
        
        //  chatTableView.layer.borderColor = UIColor.black.cgColor
        //  chatTableView.layer.borderWidth = 1
        
        chatB.layer.cornerRadius = 15
        chatB.clipsToBounds = true
        
        chatTV.text = "Say Something!"
        chatTV.textColor = UIColor.lightGray
        
        chatTV.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapFunction(tapGestureRecognizer:)))
        statusL.isUserInteractionEnabled = true
        //tap.cancelsTouchesInView = false
        statusL.addGestureRecognizer(tap)
       // homeSchoolScoreL.adjustsFontSizeToFitWidth = true
      //  awaySchoolScoreL.adjustsFontSizeToFitWidth = true
      //  homeSchoolOvers.adjustsFontSizeToFitWidth = true
      //  awaySchoolOvers.adjustsFontSizeToFitWidth = true
        
        
        school = retrieveSchool()
        if school == nil {
            createAlert(titleText: "Note", messageText: "Either add a new School or Select existing one from  Change School")
            
        }
        else {
            schoolTypeLabel.text = school?.schoolType
            schoolNameLabel.text = school?.schoolName
            schoolLocationLabel.text = school?.schoolLocation
            
            game = retrieveSelectedUpdateGame()
            
            if game != nil {
                
                battingArray.append((game?.homeSchoolName)!)
                battingArray.append((game?.awaySchoolName)!)
                bowlingArray.append((game?.homeSchoolName)!)
                bowlingArray.append((game?.awaySchoolName)!)
                endCricketArray.append(contentsOf: battingArray)
                
                if game?.chatBubble == "Yes" {
                    chatBubble.isHidden = false
                }
                else {
                    chatBubble.isHidden = true
                }
                
                if game?.status == "FULL TIME" {
                    // updateScoreB.isEnabled = false
                    // updateScoreB.alpha = 0.5
                    statusL.isEnabled = false
                    statusL.isUserInteractionEnabled = false
                    statusL.alpha = 0.5
                    updateWeatherB.isEnabled = false
                    updateWeatherB.alpha = 0.5
                }
                let encoded = game?.homeSchoolImageURL.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
                var url = URL(string: "https" + encoded!)
                let store = game?.schoolsType.components(separatedBy: "/")
                homeSchoolNameL.text = game?.homeSchoolName
                homeSchoolTypeL.text = store?[0]
                homeSchoolIV.kf.setImage(with: url)
                let encoded2 = game?.awaySchoolImageURL.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
                url = URL(string: "https" + (encoded2)!)
                awaySchoolNameL.text = game?.awaySchoolName
                awaySchoolTypeL.text = store?[1]
                awaySchoolIV.kf.setImage(with: url)
                
                var category = game?.category
                let gameType: String! = game?.sport
                let gameAgeGroup = game?.ageGroup
                let gameTeam = game?.team
                //    print("Game Category: ", game?.category)
                if category == "Boys" {
                    category = "(B)"
                }
                else if category == "Girls" {
                    category = "(G)"
                }
                
                if (gameAgeGroup?.contains("-"))! && (gameTeam?.contains("-"))! {
                    let ageGroupArray = gameAgeGroup?.split(separator: "-")
                    let teamArray = gameTeam?.split(separator: "-");
                    homeSchoolAgeTeamL.text = ageGroupArray![0] + "/" + teamArray![0]
                    awaySchoolAgeTeamL.text = ageGroupArray![1] + "/" + teamArray![1]
                }
                else {
                    homeSchoolAgeTeamL.text = gameAgeGroup! + "/" + gameTeam!
                    awaySchoolAgeTeamL.text = gameAgeGroup! + "/" + gameTeam!
                }
                
                gameSportAndAgeGroupL.text = " \(category!) \(String(describing: gameType!))"
                
                startTimeL.text = UTCToLocal(date: (game?.startTime)!)
                statusL.text = game?.status
                temperatureL.text = game?.temperature
                userL.text = game?.lastUpdateBy
                lastUpdateTimeL.text = UTCToLocal(date: (game?.lastUpdateTime)!)
                
                if (game?.score.contains("*"))! {
                    let bothScores = game?.score.components(separatedBy: "*")
                    let homeTeamScore = bothScores![0]
                    let awayTeamScore = bothScores![1]
                    let homeTeamScore2 = homeTeamScore.components(separatedBy: "/")
                    let awayTeamScore2 = awayTeamScore.components(separatedBy: "/")
                    homeSchoolBatBowlL.isHidden = false
                    awaySchoolBatBowlL.isHidden = false
                    
                    homeSchoolScoreL.text = homeTeamScore2[0].trimmingCharacters(in: .whitespacesAndNewlines) + "/" + homeTeamScore2[1].trimmingCharacters(in: .whitespacesAndNewlines)
                    homeSchoolOvers.text = "Over: " + homeTeamScore2[4]
                    
                    awaySchoolScoreL.text = awayTeamScore2[0].trimmingCharacters(in: .whitespacesAndNewlines) + "/" + awayTeamScore2[1].trimmingCharacters(in: .whitespacesAndNewlines)
                    awaySchoolOvers.text = "Over: " + awayTeamScore2[4]
                    
                    if homeSchoolNameL.text?.trimmingCharacters(in: .whitespacesAndNewlines) == homeTeamScore2[2].trimmingCharacters(in: .whitespacesAndNewlines) {
                        homeSchoolBatBowlL.text = "(Bat)";
                        awaySchoolBatBowlL.text = "(Bowl)";
                    }
                    else {
                        homeSchoolBatBowlL.text = "(Bowl)";
                        awaySchoolBatBowlL.text = "(Bat)";
                    }
                    
                }
                else {
                    homeSchoolScoreL.text = "0/0"
                    homeSchoolOvers.text = "Over: 0"
                    awaySchoolScoreL.text = "0/0"
                    awaySchoolOvers.text = "Over: 0"
                    homeSchoolBatBowlL.isHidden = true
                    awaySchoolBatBowlL.isHidden = true
                }
                
                if game?.status == "FULL TIME" && game?.sport == "Cricket" {
                    let whoWon = game?.whoWon
                    homeSchoolBatBowlL.isHidden = false
                    awaySchoolBatBowlL.isHidden = false
                    homeSchoolNameL.text = homeSchoolNameL.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    if whoWon == homeSchoolNameL.text {
                        homeSchoolBatBowlL.text = "WON";
                        awaySchoolBatBowlL.text = "LOST";
                    }
                    else if whoWon == awaySchoolNameL.text {
                        homeSchoolBatBowlL.text = "LOST";
                        awaySchoolBatBowlL.text = "WON";
                    }
                    else if whoWon == "Draw" {
                        homeSchoolBatBowlL.text = "Draw";
                        awaySchoolBatBowlL.text = "Draw";
                    }
                    else if whoWon == "Tie" {
                        homeSchoolBatBowlL.text = "Tie";
                        awaySchoolBatBowlL.text = "Tie";
                    }
                    else {
                      //  homeSchoolBatBowlL.isHidden = true
                     //   awaySchoolBatBowlL.isHidden = true
                    }
                }
                
                if game?.weather == "Rainy" {
                    weatherIV.image = UIImage(named: "Rainy")
                    weatherL.text = game?.weather
                }
                else if game?.weather == "Cloudy" {
                    weatherIV.image = UIImage(named: "Cloudy")
                    weatherL.text = game?.weather
                }
                else if game?.weather == "Partly Cloudy" {
                    weatherIV.image = UIImage(named: "Partly Cloudy")
                    weatherL.text = game?.weather
                }
                else if game?.weather == "Sunshine" {
                    weatherIV.image = UIImage(named: "Sunny")
                    weatherL.text = game?.weather
                }
                else if game?.weather == "Strong Wind" {
                    weatherIV.image = UIImage(named: "Windy")
                    weatherL.text = game?.weather
                }
                
            }
            
            
        }
        
        scoreView2.isHidden = true
        oversTableView.isHidden = true
        wicketsTableView.isHidden = true
        battingTeamTableView.isHidden = true
        bowlingTeamTableView.isHidden = true
        
        self.hideKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if isConnectedToNetwork() {
            getChat(gameid: (game?.gameID)!)
        }
        else {
            createAlert2(titleText: "Note", messageText: "Please connect to the Internet")
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        print("Text view begin editing called")
        if chatTV.textColor == UIColor.lightGray {
            chatTV.text = nil
            chatTV.textColor = UIColor.black
        }
        scrollView.setContentOffset(CGPoint(x:0, y:chatTV.frame.origin.y), animated: true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("Text view end editing callled")
        if chatTV.text.isEmpty {
            chatTV.text = "Say Something!"
            chatTV.textColor = UIColor.lightGray
        }
        scrollView.setContentOffset(CGPoint(x:0, y:0), animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == oversTableView {
            return oversArray.count
        }
        else if tableView == wicketsTableView {
            return wicketsArray.count
        }
        else if tableView == battingTeamTableView {
            return battingArray.count
        }
        else if tableView == bowlingTeamTableView {
            return bowlingArray.count
        }
        else if tableView == chatTableView {
            return chatArray.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell :UITableViewCell!
        
        if tableView == oversTableView {
            cell = tableView.dequeueReusableCell(withIdentifier: "overcell")
            cell?.textLabel?.text = String(describing: oversArray[indexPath.row])
            cell?.textLabel?.adjustsFontSizeToFitWidth = true
            return cell!
        }
        else if tableView == wicketsTableView {
            cell = tableView.dequeueReusableCell(withIdentifier: "wicketcell")
            cell?.textLabel?.text = String(describing: wicketsArray[indexPath.row])
            return cell!
        }
        else if tableView == battingTeamTableView {
            cell = tableView.dequeueReusableCell(withIdentifier: "battingcell")
            cell?.textLabel?.text = battingArray[indexPath.row]
            return cell!
        }
        else if tableView == bowlingTeamTableView {
            cell = tableView.dequeueReusableCell(withIdentifier: "bowlingcell")
            cell?.textLabel?.text = bowlingArray[indexPath.row]
            return cell!
        }
        else if tableView == chatTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "chatcell", for: indexPath) as! chatTVCell
            
            cell.chatLabel.text = chatArray[indexPath.row].message
            cell.nameLabel.text = chatArray[indexPath.row].name
            cell.dateLabel.text = chatArray[indexPath.row].time
            
            return cell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == oversTableView {
            let cell = tableView.cellForRow(at: indexPath)
            oversTF.text = cell?.textLabel?.text
            oversTableView.isHidden = true
            print("Selected an Over")
            view.endEditing(true)
            tableView.reloadData()
        }
        else if tableView == wicketsTableView {
            let cell = tableView.cellForRow(at: indexPath)
            wicketsTF.text = cell?.textLabel?.text
            wicketsTableView.isHidden = true
            print("Selected a Wicket")
            view.endEditing(true)
            tableView.reloadData()
        }
        else if tableView == battingTeamTableView {
            let cell = tableView.cellForRow(at: indexPath)
            battingTF.text = cell?.textLabel?.text
            battingTeamTableView.isHidden = true
            print("Selected a Batting team")
            view.endEditing(true)
            tableView.reloadData()
        }
        else if tableView == bowlingTeamTableView {
            let cell = tableView.cellForRow(at: indexPath)
            bowlingTF.text = cell?.textLabel?.text
            bowlingTeamTableView.isHidden = true
            print("Selected a Bowling team")
            view.endEditing(true)
            tableView.reloadData()
        }
        else if tableView == chatTableView {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        if pickerView == temperaturePickerView {
            return 2
        }
        else {
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView == statusPickerView {
            return gameStatusArray.count
        }
        else if pickerView == scorePickerView1 {
            return scoreArray.count
        }
        else if pickerView == scorePickerView2 {
            return scoreArray.count
        }
        else if pickerView == cricketScorePickerView {
            return cricketScoreArray.count
        }
        else if pickerView == weatherPickerView {
            
            if didStatusCalled == true {
                return gameStatusArray.count
            }
            else {
                return weatherArray.count
            }
        }
        else if pickerView == temperaturePickerView {
            
            if component == 0 {
                return temperatureSymbolArray.count
            }
            else {
                return temperatureArray.count
            }
        }
        else if pickerView == endCricketPickerView {
            return endCricketArray.count
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        self.view.endEditing(true)
        
        if pickerView == statusPickerView {
            return gameStatusArray[row]
        }
        else if pickerView == scorePickerView1 {
            return "\(scoreArray[row])"
        }
        else if pickerView == scorePickerView2 {
            return "\(scoreArray[row])"
        }
        else if pickerView == cricketScorePickerView {
            return "\(cricketScoreArray[row])"
        }
        else if pickerView == weatherPickerView {
            
            if didStatusCalled == true {
                return gameStatusArray[row]
            }
            else {
                return "\(weatherArray[row])"
            }
        }
        else if pickerView == temperaturePickerView {
            if component == 0 {
                return temperatureSymbolArray[row]
            }
            else {
                return "\(temperatureArray[row])"
            }
        }
        else if pickerView == endCricketPickerView {
            return endCricketArray[row]
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == statusPickerView {
            statusL.text = gameStatusArray[row]
            pickerView.isHidden = true
        }
        else if pickerView == weatherPickerView {
            
            if didStatusCalled == true {
                statusL.text = gameStatusArray[row]
            }
            else {
                
                weatherL.text = weatherArray[row]
                
                if weatherPickerView.selectedRow(inComponent: 0) == 0 {
                    weatherIV.image = UIImage(named: "Rainy")
                }
                else if weatherPickerView.selectedRow(inComponent: 0) == 1 {
                    weatherIV.image = UIImage(named: "Cloudy")
                }
                else if weatherPickerView.selectedRow(inComponent: 0) == 2 {
                    weatherIV.image = UIImage(named: "Partly Cloudy")
                }
                else if weatherPickerView.selectedRow(inComponent: 0) == 3 {
                    weatherIV.image = UIImage(named: "Sunny")
                }
                else if weatherPickerView.selectedRow(inComponent: 0) == 4 {
                    weatherIV.image = UIImage(named: "Windy")
                }
            }
            
        }
        else  if pickerView == temperaturePickerView {
            temperatureL.text = temperatureSymbolArray[pickerView.selectedRow(inComponent: 0)] + "\(temperatureArray[pickerView.selectedRow(inComponent: 1)])" + "°C"
        }
        // self.view.endEditing(false)
    }
    
    
    /*  func scrollViewDidScroll(_ scrollView: UIScrollView) {
     let yOffset = scrollView.contentOffset.y
     
     if scrollView == self.scrollView {
     if yOffset >= scrollViewContentHeight - screenHeight {
     scrollView.isScrollEnabled = false
     chatTableView.isScrollEnabled = true
     }
     }
     
     if scrollView == self.chatTableView {
     if yOffset <= 0 {
     self.scrollView.isScrollEnabled = true
     self.chatTableView.isScrollEnabled = false
     }
     }
     } */
    
    func UTCToLocal(date:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "d-M-yyyy / hh:mm a"
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
    
    func shareGame(shareText: String) {
        
        let activityController = UIActivityViewController(activityItems: [shareText, URL.init(string: "https://schools-live.com")! ], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
    
    @objc func tapFunction(tapGestureRecognizer: UITapGestureRecognizer) {
        print("Tap Works")
        didStatusCalled = true
        weatherPickerView.reloadAllComponents()
        
        let status = game?.status
        
        if status == "NOT STARTED" {
            weatherPickerView.selectRow(0, inComponent: 0, animated: true)
        }
        else if status == "1st HALF" {
            weatherPickerView.selectRow(1, inComponent: 0, animated: true)
        }
        else if status == "HALF TIME" {
            weatherPickerView.selectRow(2, inComponent: 0, animated: true)
        }
        else if status == "2nd HALF" {
            weatherPickerView.selectRow(3, inComponent: 0, animated: true)
        }
        
        weatherView1.isHidden = false
        //statusPickerView.isHidden = false
        //bannerView.isHidden = true
    }
    
    func updateGameRealFunction() {
        let id = game?.gameID
        let weather = weatherL.text
        let temperature = temperatureL.text
        let status = statusL.text
        var score = ""
        let homeSchoolOver = homeSchoolOvers.text!.replacingOccurrences(of: "Over: ", with: "")
        let awaySchoolOver = awaySchoolOvers.text!.replacingOccurrences(of: "Over: ", with: "")
        
        score = " \(String(describing: homeSchoolScoreL.text!)) \("/") \(batting) \("/") \(bowling) \("/") \(String(describing: homeSchoolOver)) \("*") \(String(describing: awaySchoolScoreL.text!)) \("/") \(batting) \("/") \(bowling) \("/") \(String(describing: awaySchoolOver)) "
            game?.score = score
            saveSelectedUpdateGame(game: game!)
            // save game preferences
        
        
        if self.retrieveUser() != nil {
            let user = self.retrieveUser()
            let updateBy = user?.getFullName()
            let updateTime = utcTime
            
            if isConnectedToNetwork() {
                updateGame(gameID: id!, weather: weather!, temperature: temperature!, status: status!, score: score, lastupdate: updateBy!, lastupdatetime: updateTime)
            }
            else {
                createAlert2(titleText: "Note", messageText: "Please connect to the Internet")
            }
            
        }
    }
    
    @IBAction func shareGame(_ sender: UIButton) {
        
        let category = game?.category
        let gameType: String! = game?.sport
        let gameAgeGroup = game?.ageGroup.split(separator: "-")
        let homeAgeGroup = gameAgeGroup![0]
        let awayAgeGroup = gameAgeGroup![1]
        let gameTeam = game?.team.split(separator: "-")
        let homeTeam = gameTeam![0]
        let awayTeam = gameTeam![1]
        let gameStatus = game?.status
        let homeSchool = game?.homeSchoolName.trimmingCharacters(in: .whitespacesAndNewlines)
        let awaySchool = game?.awaySchoolName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if gameType  != "Cricket" {
            let homeScore = game?.score.split(separator: "-")[0]
            let awayScore = game?.score.split(separator: "-")[1]
            
            let shareText = " \(String(describing: category!)) \(String(describing: gameType!)) \(String(describing: gameAgeGroup!)) \(String(describing: gameTeam!)) \(String(describing: gameStatus!)) \("-") \(String(describing: homeSchool!)) \(String(describing: homeScore!)) \("-") \(String(describing: awaySchool!)) \(String(describing: awayScore!)) \("via @SchoolsLive") "
            
            shareGame(shareText: shareText)
        }
        else {
            
            if game?.status == "FULL TIME" {
                
                if game?.whoWon.trimmingCharacters(in: .whitespacesAndNewlines) == game?.homeSchoolName.trimmingCharacters(in: .whitespacesAndNewlines) {
                    let shareText = "Match Ended: " + (game?.whoWon.trimmingCharacters(in: .whitespacesAndNewlines))! + " Won"
                    shareGame(shareText: shareText)
                }
                else if game?.whoWon.trimmingCharacters(in: .whitespacesAndNewlines) == game?.awaySchoolName.trimmingCharacters(in: .whitespacesAndNewlines) {
                    let shareText = "Match Ended: " + (game?.whoWon.trimmingCharacters(in: .whitespacesAndNewlines))! + " Won"
                    shareGame(shareText: shareText)
                }
                else if game?.whoWon == "Tie" {
                    let shareText = "Game Tied between " + (game?.homeSchoolName.trimmingCharacters(in: .whitespacesAndNewlines))! + " and " + (game?.awaySchoolName.trimmingCharacters(in: .whitespacesAndNewlines))!
                    shareGame(shareText: shareText)
                }
                else if game?.whoWon == "Draw" {
                    let shareText = "Game Draw between " + (game?.homeSchoolName.trimmingCharacters(in: .whitespacesAndNewlines))! + " and " + (game?.awaySchoolName.trimmingCharacters(in: .whitespacesAndNewlines))!
                    shareGame(shareText: shareText)
                }
                
            }
            else {
            if (game?.score.contains("*"))! {
                
                let bothScores = game?.score.components(separatedBy: "*")
                let homeTeamScore = bothScores![0]
                let awayTeamScore = bothScores![1]
                let homeTeamScore2 = homeTeamScore.components(separatedBy: "/")
                let awayTeamScore2 = awayTeamScore.components(separatedBy: "/")
                
                let bat = homeTeamScore2[2].trimmingCharacters(in: .whitespacesAndNewlines)
                let bowl = homeTeamScore2[3].trimmingCharacters(in: .whitespacesAndNewlines)
                var score = ""
                var overs = ""
                var wickets = ""
                if bat.trimmingCharacters(in: .whitespacesAndNewlines) == game?.homeSchoolName.trimmingCharacters(in: .whitespacesAndNewlines) {
                    score = homeTeamScore2[0]
                    overs = homeTeamScore2[4]
                    wickets = homeTeamScore2[1]
                }
                else if bat.trimmingCharacters(in: .whitespacesAndNewlines) == game?.awaySchoolName.trimmingCharacters(in: .whitespacesAndNewlines) {
                    score = awayTeamScore2[0]
                    overs = awayTeamScore2[4]
                    wickets = awayTeamScore2[1]
                }
                
               /* let shareText = " \(String(describing: category!)) \(String(describing: gameType!)) \(String(describing: gameAgeGroup!)) \(String(describing: gameTeam!)) \("-") \(String(describing: bat)) \("(Bat)") \("-") \(String(describing: bowl)) \("(Bowl)") \("-") \(String(describing: score)) \("/") \(String(describing: wickets))  \("Overs: ") \(String(describing: overs)) \("via @SchoolsLive") " */
                
                let shareText = " \(String(describing: category!)) \(String(describing: gameType!)) \("-") \(String(describing: homeAgeGroup))\(String(describing: homeTeam)) \(String(describing: bat)) \("(Bat)") \("-") \(String(describing: awayAgeGroup))\(String(describing: awayTeam)) \(String(describing: bowl)) \("(Bowl)") \("-") \(String(describing: score))\("/")\(String(describing: wickets))  \("Overs: ")\(String(describing: overs)) \("via @SchoolsLive") "
                
                shareGame(shareText: shareText)
            }
            else {
                let score1 = game?.score.split(separator: "/")[0]
                let score2 = game?.score.split(separator: "/")[1]
                
              /*  let shareText = " \(String(describing: category!)) \(String(describing: gameType!)) \(String(describing: gameAgeGroup!)) \(String(describing: gameTeam!)) \("-") \(String(describing: homeSchool!))  \(String(describing: score1!)) \("-") \(String(describing: awaySchool!)) \(String(describing: score2!)) \("via @SchoolsLive") " */
              
                let shareText = " \(String(describing: category!)) \(String(describing: gameType!)) \("-") \(String(describing: homeAgeGroup))\(String(describing: homeTeam)) \(String(describing: homeSchool!)) \(String(describing: score1!))  \("-") \(String(describing: awayAgeGroup))\(String(describing: awayTeam)) \(String(describing: awaySchool!)) \(String(describing: score2!)) \("via @SchoolsLive") "
                
                shareGame(shareText: shareText)
            }
            }
        }
        
    }
    
    @IBAction func openMenu(_ sender: UIButton) {
        print("Button Clicked")
        NotificationCenter.default.post(name: NSNotification.Name("toggleSideMenu"), object: nil)
    }
    
    @IBAction func submitChat(_ sender: UIButton) {
        
        if chatTV.text.count > 0 && chatTV.text != "Say Something!" {
            let user = retrieveUser()
            let phoneNumber = user?.phoneNumber
            let name = user?.getFullName()
            var message = chatTV.text
            message = message?.replacingOccurrences(of: "'", with: "\\'")
            let time = Date().preciseLocalTime
            let gameID = game?.gameID
            
            if isConnectedToNetwork() {
                insertChat(phone: phoneNumber!, name: name!, message: message!, time: time, gameid: gameID!)
            }
            else {
                createAlert2(titleText: "Note", messageText: "Please connect to the Internet")
            }
        }
        else {
            createAlert2(titleText: "Note", messageText: "Please type a message first")
        }
        
    }
    
    @IBAction func updateScore1(_ sender: UIButton) {
      //  let a = scoreArray[scorePickerView1.selectedRow(inComponent: 0)]
      //  let b = scoreArray[scorePickerView2.selectedRow(inComponent: 0)]
      //  scoreL.text = "\(a)" + " - " + "\(b)"
        utcTime = Date().preciseGMTTime
        lastUpdateTimeL.text = UTCToLocal(date: Date().preciseGMTTime)
        scoreView1.isHidden = true
        updateGameRealFunction()
    }
    
    @IBAction func cancelScore1(_ sender: UIButton) {
        scoreView1.isHidden = true
    }
    
    @IBAction func updateScore(_ sender: UIButton) {
        
        if game?.status != "HALF TIME" {
            if game?.status != "NOT STARTED" {
                if game?.sport == "Cricket" {
                    if game?.status != "FULL TIME" {
                        scoreView2.isHidden = false
                        
                        if (game?.score.contains("*"))! {
                            let bothScores = game?.score.components(separatedBy: "*")
                            let homeTeamScore = bothScores![0]
                            let awayTeamScore = bothScores![1]
                            let homeTeamScore2 = homeTeamScore.components(separatedBy: "/")
                            let awayTeamScore2 = awayTeamScore.components(separatedBy: "/")
                            
                            let homeTeam = homeTeamScore2[2].trimmingCharacters(in: .whitespacesAndNewlines)
                            
                            if battingArray[0].contains(homeTeam) {
                                battingTF.text = battingArray[0]
                                bowlingTF.text = battingArray[1]
                           
                                let score = homeTeamScore2[0].trimmingCharacters(in: .whitespacesAndNewlines)
                                let intIndex : Int = Int(score)!
                                let index = cricketScoreArray.firstIndex(of: intIndex)
                                cricketScorePickerView.selectRow(index!, inComponent: 0, animated: true)
                             
                                if homeTeamScore2[4] == "0" {
                                    oversTF.text = "0"
                                }
                                else {
                                    let overs = homeTeamScore2[4]
                                    oversTF.text = String(describing: overs)
                                }
                                
                                if homeTeamScore2[1] == "0" {
                                    wicketsTF.text = "0"
                                }
                                else {
                                    let wickets = homeTeamScore2[1]
                                    wicketsTF.text = String(describing: wickets)
                                }
                                
                            }
                            else {
                                battingTF.text = battingArray[1]
                                bowlingTF.text = battingArray[0]
                                
                                let score = awayTeamScore2[0].trimmingCharacters(in: .whitespacesAndNewlines)
                                let intIndex : Int = Int(score)!
                                let index = cricketScoreArray.firstIndex(of: intIndex)
                                cricketScorePickerView.selectRow(index!, inComponent: 0, animated: true)
                            
                                if awayTeamScore2[4] == "0" {
                                    oversTF.text = "0"
                                }
                                else {
                                    let overs = awayTeamScore2[4]
                                    oversTF.text = String(describing: overs)
                                }
                                
                                if awayTeamScore2[1] == "0" {
                                    wicketsTF.text = "0"
                                }
                                else {
                                    let wickets = awayTeamScore2[1]
                                    wicketsTF.text = String(describing: wickets)
                                }
                            }
                            
                        }
                    }
                    else {
                        endCricketView.isHidden = false
                    }
                    
                }
                else {
                    
                    let score1 = game?.score.split(separator: "-")[0].trimmingCharacters(in: .whitespacesAndNewlines)
                    let score2 = game?.score.split(separator: "-")[1].trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    let intIndex1 : Int = Int(score1!)!
                    let intIndex2 : Int = Int(score2!)!
                    
                    let index1 = scoreArray.firstIndex(of: intIndex1)
                    let index2 = scoreArray.firstIndex(of: intIndex2)
                    
                    scorePickerView1.selectRow(index1!, inComponent: 0, animated: true)
                    scorePickerView2.selectRow(index2!, inComponent: 0, animated: true)
                    
                    
                    scoreView1.isHidden = false
                }
            }
            else {
                createAlert2(titleText: "Note", messageText: "Please update the Game Status to 1st Half before updating Score")
            }
        }
        else {
            createAlert2(titleText: "Note", messageText: "You can't update score during Half Time")
            
        }
    }
    
    
    @IBAction func updateCricketScore(_ sender: UIButton) {
        
        let score = cricketScorePickerView.selectedRow(inComponent: 0)
        let wickets = wicketsTF.text
        overs = oversTF.text!
        batting = (battingTF.text?.trimmingCharacters(in: .whitespacesAndNewlines))!
        bowling = (bowlingTF.text?.trimmingCharacters(in: .whitespacesAndNewlines))!
        print("Overs: ", overs)
        homeSchoolBatBowlL.isHidden = false
        awaySchoolBatBowlL.isHidden = false
        
        if String(describing: score).count < 1 || (wickets?.count)! < 1 || batting.count < 1 || bowling.count < 1 {
            createAlert2(titleText: "Note", messageText: "Please fill all the fields")
        }
        else if batting == bowling {
             createAlert2(titleText: "Note", messageText: "Batting and Bowling teams can't be same")
        }
        else {
        if homeSchoolNameL.text?.trimmingCharacters(in: .whitespacesAndNewlines) == batting {
            homeSchoolBatBowlL.text = "(Bat)"
            awaySchoolBatBowlL.text = "(Bowl)"
            homeSchoolScoreL.text = String(describing: score) + "/" + wickets!
            homeSchoolOvers.text = "Over: " + overs
        }
        else {
            homeSchoolBatBowlL.text = "(Bowl)"
            awaySchoolBatBowlL.text = "(Bat)"
            awaySchoolScoreL.text = String(describing: score) + "/" + wickets!
            awaySchoolOvers.text = "Over: " + overs
        }
     
        utcTime = Date().preciseGMTTime
        lastUpdateTimeL.text = UTCToLocal(date: Date().preciseGMTTime)
        scoreView2.isHidden = true
        updateGameRealFunction()
        }
    }
    
    
    @IBAction func cancelCricketScore(_ sender: UIButton) {
        scoreView2.isHidden = true
    }
    
    @IBAction func dropDownWickets(_ sender: UIButton) {
        //wicketsTableView.isHidden = false
        wicketsTableView.isHidden = !wicketsTableView.isHidden
    }
    
    @IBAction func dropDownOvers(_ sender: UIButton) {
        //oversTableView.isHidden = false
        oversTableView.isHidden = !oversTableView.isHidden
    }
    
    @IBAction func dropDownBatting(_ sender: UIButton) {
        //battingTeamTableView.isHidden = false
        battingTeamTableView.isHidden = !battingTeamTableView.isHidden
    }
    
    @IBAction func dropDownBowling(_ sender: UIButton) {
        //bowlingTeamTableView.isHidden = false
        bowlingTeamTableView.isHidden = !bowlingTeamTableView.isHidden
        
    }
    
    @IBAction func updateWeather(_ sender: UIButton) {
        didStatusCalled = false
        weatherPickerView.reloadAllComponents()
        
        let status = game?.weather
        
        if status == "Rainy" {
            weatherPickerView.selectRow(0, inComponent: 0, animated: true)
        }
        else if status == "Cloudy" {
            weatherPickerView.selectRow(1, inComponent: 0, animated: true)
        }
        else if status == "Partly Cloudy" {
            weatherPickerView.selectRow(2, inComponent: 0, animated: true)
        }
        else if status == "Sunshine" {
            weatherPickerView.selectRow(3, inComponent: 0, animated: true)
        }
        else if status == "Strong Wind" {
            weatherPickerView.selectRow(4, inComponent: 0, animated: true)
        }
        
        weatherView1.isHidden = false
    }
    
    @IBAction func updateFirstWeather(_ sender: UIButton) {
        
        if didStatusCalled == false {
            weatherView1.isHidden = true
            
            var temperature = game?.temperature
            
            if (temperature?.contains("+"))! {
                temperaturePickerView.selectRow(0, inComponent: 0, animated: true)
                temperature = temperature?.replacingOccurrences(of: "+", with: "")
                temperature = temperature?.replacingOccurrences(of: "°C", with: "")
                let index = temperatureArray.firstIndex(of: Int(temperature!)!)
                temperaturePickerView.selectRow(index!, inComponent: 1, animated: true)
            }
            else {
                temperaturePickerView.selectRow(1, inComponent: 0, animated: true)
                temperature = temperature?.replacingOccurrences(of: "-", with: "")
                temperature = temperature?.replacingOccurrences(of: "°C", with: "")
                let index = temperatureArray.firstIndex(of: Int(temperature!)!)
                temperaturePickerView.selectRow(index!, inComponent: 1, animated: true)
            }
            weatherView2.isHidden = false
        }
        else {
            // send update request for status
            utcTime = Date().preciseGMTTime
            lastUpdateTimeL.text = UTCToLocal(date: utcTime)
            let status = statusL.text
            game?.status = status!
            let updateBy = self.retrieveUser()?.getFullName()
            saveSelectedUpdateGame(game: game!)
            weatherView1.isHidden = true
            
            if isConnectedToNetwork() {
                updateGameStatus(gameID: (game?.gameID)!, status: status!, updateby: updateBy!, updatetime: utcTime)
            }
            else {
                createAlert2(titleText: "Note", messageText: "Please connect to the Internet")
            }
            
        }
        
    }
    
    @IBAction func cancelWeather(_ sender: UIButton) {
        weatherView1.isHidden = true
    }
    
    @IBAction func updateTempWeather(_ sender: UIButton) {
        weatherView2.isHidden = true
        
        // update weather & temperature
        let weather = weatherL.text
        let temp = temperatureL.text
        game?.weather = weather!
        game?.temperature = temp!
        saveSelectedUpdateGame(game: game!)
        utcTime = Date().preciseGMTTime
        lastUpdateTimeL.text = UTCToLocal(date: utcTime)
        let updateBy = self.retrieveUser()?.getFullName()
        
        if isConnectedToNetwork() {
            updateGameWeatherAndTemp(gameID: (game?.gameID)!, weather: weather!, temp: temp!, updateby: updateBy!, updatetime: utcTime)
        }
        else {
            createAlert2(titleText: "Note", messageText: "Please connect to the Internet")
        }
    }
    
    @IBAction func cancelTempWeather(_ sender: UIButton) {
        weatherView2.isHidden = true
    }
    
    @IBAction func cancelEndCricketView(_ sender: UIButton) {
        endCricketView.isHidden = true
    }
    
    @IBAction func updateEndCricket(_ sender: UIButton) {
        
      //  if (game?.score.contains("*"))! {
            utcTime = Date().preciseGMTTime
            lastUpdateTimeL.text = UTCToLocal(date: utcTime)
            let whoWon = endCricketArray[endCricketPickerView.selectedRow(inComponent: 0)].trimmingCharacters(in: .whitespacesAndNewlines)
            game?.whoWon = whoWon
            homeSchoolBatBowlL.isHidden = false
            awaySchoolBatBowlL.isHidden = false
            
            if whoWon == game?.homeSchoolName.trimmingCharacters(in: .whitespacesAndNewlines) {
                homeSchoolBatBowlL.text = "Won"
                awaySchoolBatBowlL.text = "Lost"
            }
            else if whoWon == game?.awaySchoolName.trimmingCharacters(in: .whitespacesAndNewlines) {
                homeSchoolBatBowlL.text = "Lost"
                awaySchoolBatBowlL.text = "Won"
            }
            else if whoWon == "Draw" {
                homeSchoolBatBowlL.text = "Draw"
                awaySchoolBatBowlL.text = "Draw"
            }
            else if whoWon == "Tie" {
                homeSchoolBatBowlL.text = "Tie"
                awaySchoolBatBowlL.text = "Tie"
            }
            else {
                homeSchoolBatBowlL.isHidden = true
                awaySchoolBatBowlL.isHidden = true
            }
            utcTime = Date().preciseGMTTime
            let updateBy = retrieveUser()?.getFullName()
            
            if isConnectedToNetwork() {
                endCricketView.isHidden = true
                updateEndGame(gameID: (game?.gameID)!, score: whoWon, lastupdate: updateBy!, lastupdatetime: utcTime)
            }
            else {
                createAlert2(titleText: "Note", messageText: "Please connect to the Internet")
            }
            
      //  }
     /*   else {
            createAlert2(titleText: "Note", messageText: "No Score to determine who won")
        } */
        
    }
    
    func insertChat(phone: String, name: String, message: String, time: String, gameid: String) {
        effectView.isHidden = false
        activityIndicator("Please Wait")
        AF.request("https://schools-live.com/app/apis/insertMessage.php", parameters: ["phone": phone, "name": name, "message": message, "time": time, "gameid": gameid])
            .validate()
            .responseString { response in
                
                switch(response.result) {
                    case .success(let data):
                        if data.contains("New record created successfully") {
                            //saveUser(user: <#T##User#>)
                            self.chatTV.text = ""
                            let gameID = self.game?.gameID
                            //self.getChat(gameid: gameID!)
                            self.getChat(gameid: gameID!)
                        }
                        else {
                            self.effectView.isHidden = true
                            self.createAlert2(titleText: "Note", messageText: "We couldn't save your message")
                        }
                        break
                    
                    case .failure(let error):
                        self.effectView.isHidden = true
                        self.createAlert(titleText: "Note", messageText: error.localizedDescription)
                        break;
                }
        }
    }
    
    /* func getChat(gameid: String) {
     effectView.isHidden = false
     activityIndicator("Please Wait")
     Alamofire.request("http://schools-live.com/getMessages.php", parameters: ["gameid": gameid])
     .validate()
     .responseString { response in
     
     if let data = response.result.value {
     
     if data.contains("Got Result") {
     
     }
     else {
     self.effectView.isHidden = true
     }
     
     }
     
     }
     } */
    
    func getChat(gameid: String) {
        effectView.isHidden = false
        activityIndicator("Please Wait")
        AF.request("https://schools-live.com/app/apis/getMessages.php", parameters: ["gameid": gameid])
            .validate()
            .responseString { response in
                
                switch(response.result) {
                    case .success(let data):
                        if data.contains("Got Result<br>") {
                            self.chatArray.removeAll()
                            let newData = data.replacingOccurrences(of: "Got Result<br>", with: "")
                            
                            if let store = (newData as NSString).data(using: String.Encoding.utf8.rawValue) {
                                do {
                                    let json = try JSON(data: store)
                                    
                                    if let jsonArray = json.array {
                                        
                                        for i in 0..<jsonArray.count {
                                            let phoneNumber = jsonArray[i]["Phone_Number"].stringValue
                                            let name = jsonArray[i]["Name"].stringValue
                                            let message = jsonArray[i]["Message"].stringValue
                                            let time = jsonArray[i]["Time"].stringValue
                                            
                                            self.chatArray.append(Chat(phoneNumber: phoneNumber, name: name, message: message, time: time))
                                            
                                        }
                                        self.effectView.isHidden = true
                                        self.chatTableView.reloadData()
                                        //   self.chatTableView.rowHeight = 44
                                    }
                                    
                                }
                                catch {
                                    print("Got in Catch")
                                }
                            }
                            
                        }
                        else {
                            self.effectView.isHidden = true
                            self.chatArray.removeAll()
                            self.chatTableView.reloadData()
                        }
                        break
                    
                    case .failure(let error):
                        self.effectView.isHidden = true
                        self.createAlert(titleText: "Note", messageText: error.localizedDescription)
                        break;
                }
        }
        
    }
    
    func updateGameWeatherAndTemp(gameID: String, weather: String, temp: String, updateby: String, updatetime: String) {
        effectView.isHidden = false
        activityIndicator("Please Wait")
        AF.request("https://www.schools-live.com/app/apis/updateGameWeatherAndTemp.php", parameters: ["id": gameID, "weather": weather, "temp": temp, "updateby": updateby, "updatetime": updatetime])
            .validate()
            .responseString { response in
                
                switch(response.result) {
                    case .success(let data):
                        if data.contains("Record updated successfully") {
                            let user = self.retrieveUser()
                            let phoneNumber = user?.phoneNumber
                            let lastUpdate = Date().preciseGMTTime
                            var totalUpdates = user?.totalUpdates
                            totalUpdates = String(describing: Int(totalUpdates!)! + 1)
                            user?.lastUpdateTime = lastUpdate
                            user?.totalUpdates = totalUpdates!
                            self.updateUser2(phonenumber: phoneNumber!, lastupdate: lastUpdate, totalupdates: totalUpdates!, user: user!)
                        }
                        else {
                            self.effectView.isHidden = true
                            self.createAlert2(titleText: "Note", messageText: "There was an Error")
                        }
                        break
                    
                    case .failure(let error):
                        self.effectView.isHidden = true
                        self.createAlert(titleText: "Note", messageText: error.localizedDescription)
                        break;
                }
        }
    }
    
    func updateGameStatus(gameID: String, status: String, updateby: String, updatetime: String) {
        effectView.isHidden = false
        activityIndicator("Please Wait")
        AF.request("https://www.schools-live.com/app/apis/updateGameStatus.php", parameters: ["id": gameID, "status": status, "updateby": updateby, "updatetime": updatetime])
            .validate()
            .responseString { response in
                
                switch(response.result) {
                    case .success(let data):
                        if data.contains("Record updated successfully") {
                            let user = self.retrieveUser()
                            let phoneNumber = user?.phoneNumber
                            let lastUpdate = Date().preciseGMTTime
                            var totalUpdates = user?.totalUpdates
                            totalUpdates = String(describing: Int(totalUpdates!)! + 1)
                            user?.lastUpdateTime = lastUpdate
                            user?.totalUpdates = totalUpdates!
                            self.updateUser2(phonenumber: phoneNumber!, lastupdate: lastUpdate, totalupdates: totalUpdates!, user: user!)
                        }
                        else {
                            self.effectView.isHidden = true
                            self.createAlert2(titleText: "Note", messageText: "There was an Error")
                        }
                        break
                    
                    case .failure(let error):
                        self.effectView.isHidden = true
                        self.createAlert(titleText: "Note", messageText: error.localizedDescription)
                        break;
                }
        }
        
    }
    
    func updateGame(gameID: String, weather: String, temperature: String, status: String, score: String, lastupdate: String, lastupdatetime: String) {
        effectView.isHidden = false
        activityIndicator("Please Wait")
        AF.request("https://www.schools-live.com/app/apis/updateGame.php", parameters: ["id": gameID, "weather": weather, "temperature": temperature, "status": status, "score": score, "lastupdate": lastupdate, "lastupdatetime": lastupdatetime])
            .validate()
            .responseString { response in
                
                switch(response.result) {
                    case .success(let data):
                        if data.contains("Record updated successfully") {
                            let user = self.retrieveUser()
                            let phoneNumber = user?.phoneNumber
                            let lastUpdate = Date().preciseGMTTime
                            var totalUpdates = user?.totalUpdates
                            totalUpdates = String(describing: Int(totalUpdates!)! + 1)
                            user?.lastUpdateTime = lastupdate
                            user?.totalUpdates = totalUpdates!
                            self.updateUser2(phonenumber: phoneNumber!, lastupdate: lastUpdate, totalupdates: totalUpdates!, user: user!)
                        }
                        else {
                            print("Response Error: ", data)
                            self.effectView.isHidden = true
                            self.createAlert2(titleText: "Note", messageText: "There was an Error")
                        }
                        break
                    
                    case .failure(let error):
                        self.effectView.isHidden = true
                        self.createAlert(titleText: "Note", messageText: error.localizedDescription)
                        break;
                }
        }
        
    }
    
    func updateEndGame(gameID: String, score: String, lastupdate: String, lastupdatetime: String) {
        effectView.isHidden = false
        activityIndicator("Please Wait")
        AF.request("https://www.schools-live.com/app/apis/updateEndGameScore.php", parameters: ["id": gameID, "score": score, "update": lastupdate, "updatetime": lastupdatetime])
            .validate()
            .responseString { response in
                
                switch(response.result) {
                    case .success(let data):
                        if data.contains("Record updated successfully") {
                            let user = self.retrieveUser()
                            let phoneNumber = user?.phoneNumber
                            let lastUpdate = Date().preciseGMTTime
                            var totalUpdates = user?.totalUpdates
                            totalUpdates = String(describing: Int(totalUpdates!)! + 1)
                            user?.lastUpdateTime = lastupdate
                            user?.totalUpdates = totalUpdates!
                            self.updateUser2(phonenumber: phoneNumber!, lastupdate: lastUpdate, totalupdates: totalUpdates!, user: user!)
                        }
                        else {
                            self.effectView.isHidden = true
                            self.createAlert2(titleText: "Note", messageText: "There was an Error")
                        }
                        break
                    
                    case .failure(let error):
                        self.effectView.isHidden = true
                        self.createAlert(titleText: "Note", messageText: error.localizedDescription)
                        break;
                }
        }
        
    }
    
    func updateUser2(phonenumber: String, lastupdate: String, totalupdates: String, user: User) {
        effectView.isHidden = false
        activityIndicator("Please Wait")
        AF.request("https://www.schools-live.com/app/apis/updateUser2.php", parameters: ["phonenumber": phonenumber, "lastupdate": lastupdate, "totalupdates": totalupdates])
            .validate()
            .responseString { response in
                
                switch(response.result) {
                    case .success(let data):
                        if data.contains("Record updated successfully") {
                            
                            if self.game?.status == "FULL TIME" {
                                
                                // remove from notification list as game has ENDED
                                do {
                                    if let notification = UserDefaults.standard.object(forKey: "Notification Array") as? Data {
                                        if var storedNotification = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, Game.self], from: notification) as? [Game] {
                                            
                                            let index = storedNotification.firstIndex(where: { $0.gameID == self.game?.gameID } )
                                            
                                            if index != nil && index != -1 {
                                                print("ENDED game being deleted from notification list")
                                                storedNotification.remove(at: index!)
                                                self.saveNotificationArray(notificationArray: storedNotification)
                                            }
                                            
                                        }
                                    }
                                }
                                catch {
                                    print(error)
                                }
                           
                                
                            }
                            self.saveUser(user: user)
                            self.userL.text = user.getFullName()
                            self.effectView.isHidden = true
                            self.createAlert2(titleText: "Game Updated", messageText: "Game Updated Successfully")
                        }
                        else {
                            self.effectView.isHidden = true
                            self.createAlert2(titleText: "Note", messageText: "There was an Error")
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

