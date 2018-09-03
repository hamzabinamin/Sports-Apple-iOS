//
//  CumulativeGoalsChartVC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 6/11/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit
import JGProgressHUD
import AWSCognitoIdentityProvider

class CumulativeGoalsChartVC: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var emptyGoalsLabel: UILabel!
    let aaChartView = AAChartView()
    var aaChartModel: AAChartModel?
    var hud: JGProgressHUD?
    var pool: AWSCognitoIdentityUserPool?
    var session: Activity = Activity()
    var goal: Goal = Goal()
    var array: [Activity] = []
    var goalArray: [Goal] = []
    var countArray = [Int](repeating: 0, count: 52)
    var set: Set<ExerciseItem> = []
    let formatter = DateFormatter()
    var seriesArray: [[String: Any]] = []
    var testArray: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        for i in 1...52 {
            testArray.append("1,092")
        }
        getGoals()
    }
    
    func setupViews() {
        hud = self.createLoadingHUD()
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
        self.formatter.dateFormat = "MM/dd/yyyy h:mm a"
        self.formatter.locale = Locale(identifier:"en_US_POSIX")
        //let chartViewWidth  = self.view.frame.size.width;
        //let chartViewHeight = self.view.frame.size.height;
        //let aaChartView = AAChartView()
        //aaChartView.frame = CGRect(x:0,y:0,width:chartViewWidth,height:chartViewHeight)
        aaChartView.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = aaChartView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 121)
        let bottomConstraint = aaChartView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        let leadingConstraint = aaChartView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
        let trailingConstraint = aaChartView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        // set the content height of aachartView
        //aaChartView?.contentHeight = self.view.frame.size.height
        self.view.addSubview(aaChartView)
        NSLayoutConstraint.activate([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
        
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        
    /*    self.aaChartModel = AAChartModel.init()
            .chartType(AAChartType.Column)//Can be any of the chart types listed under `AAChartType`.
            .zoomType(AAChartZoomType.XY)
            .animationType(AAChartAnimationType.Bounce)
            .stacking(AAChartStackingType.False)
            //.title("TITLE")//The chart title
            .dataLabelEnabled(false) //Enable or disable the data labels. Defaults to false
            .tooltipValueSuffix("")//the value suffix of the chart tooltip
            .categories(["Week 1", "Week 2", "Week 3", "Week 4", "Week 5", "Week 6", "Week 7", "Week 8", "Week 9", "Week 10",
                         "Week 11", "Week 12", "Week 13", "Week 14", "Week 15", "Week 16", "Week 17", "Week 18", "Week 19", "Week 20",
                         "Week 21", "Week 22", "Week 23", "Week 24", "Week 25", "Week 26", "Week 27", "Week 28", "Week 29", "Week 30",
                         "Week 31", "Week 32", "Week 33", "Week 34", "Week 35", "Week 36", "Week 37", "Week 38", "Week 39", "Week 40",
                         "Week 41", "Week 42", "Week 43", "Week 44", "Week 45", "Week 46", "Week 47", "Week 48", "Week 49", "Week 50", "Week 51", "Week 52"])
            .colorsTheme(["#fe117c","#ffc069","#06caf4","#7dffc0"])
            .series([
                AASeriesElement()
                    .name("Bench Press")
                    .data([2000.0, 2500.9, 2900.5, 3400.5, 3180.2, 4210.5, 4925.2, 4826.5, 5123.3, 5118.3,
                           3000.0, 3500.9, 3900.5, 4400.5, 4180.2, 5210.5, 5925.2, 5826.5, 6123.3, 6118.3,
                           4000.0, 4500.9, 4900.5, 5400.5, 5180.2, 6210.5, 6925.2, 8826.5, 5123.3, 5118.3,
                           3000.0, 3500.9, 3900.5, 4400.5, 4180.2, 5210.5, 5925.2, 5826.5, 6123.3, 6118.3,
                           3000.0, 3500.9, 3900.5, 4400.5, 4180.2, 5210.5, 5925.2, 5826.5, 6123.3, 6118.3,
                           4000.0])
                    .toDic()!,
                AASeriesElement()
                    .name("Sit Ups")
                    .data([200.0, 250.9, 290.5, 340.5, 318.2, 421.5, 492.2, 482.5, 512.3, 511.3,
                           300.0, 350.9, 390.5, 440.5, 418.2, 520.5, 592.2, 582.5, 612.3, 611.3,
                           400.0, 450.9, 490.5, 540.5, 518.2, 621.5, 692.2, 882.5, 512.3, 511.3,
                           300.0, 350.9, 390.5, 440.5, 418.2, 521.5, 592.2, 582.5, 612.3, 611.3,
                           300.0, 350.9, 390.5, 440.5, 418.2, 521.5, 592.2, 582.5, 612.3, 611.3,
                           400.0])
                    .toDic()!,
                AASeriesElement()
                    .name("Push Ups")
                    .data([300.0, 450.9, 390.5, 340.5, 518.2, 721.5, 792.2, 482.5, 512.3, 511.3,
                           400.0, 550.9, 490.5, 440.5, 418.2, 720.5, 692.2, 582.5, 612.3, 611.3,
                           500.0, 650.9, 590.5, 540.5, 518.2, 621.5, 692.2, 882.5, 512.3, 511.3,
                           600.0, 550.9, 690.5, 640.5, 418.2, 521.5, 592.2, 582.5, 612.3, 611.3,
                           700.0, 550.9, 790.5, 740.5, 418.2, 521.5, 592.2, 582.5, 612.3, 611.3,
                           500.0])
                    .toDic()!,
                AASeriesElement()
                    .name("Running")
                    .data([3000.0, 4500.9, 3900.5, 3400.5, 5180.2, 7210.5, 7920.2, 4802.5, 5102.3, 5101.3,
                           4000.0, 5500.9, 4900.5, 4400.5, 4180.2, 7200.5, 6920.2, 5802.5, 6102.3, 6101.3,
                           5000.0, 6500.9, 5900.5, 5400.5, 5180.2, 6201.5, 6920.2, 8802.5, 5102.3, 5101.3,
                           6000.0, 5500.9, 6900.5, 6400.5, 4180.2, 5201.5, 5920.2, 5802.5, 6102.3, 6101.3,
                           7000.0, 5500.9, 7900.5, 7400.5, 4180.2, 5201.5, 5920.2, 5802.5, 6102.3, 6101.3,
                           5000.0])
                    .toDic()!,])
        
        self.aaChartView.aa_drawChartWithChartModel(self.aaChartModel!) */
    }
    
    func getSessions() {
        self.showHUD(hud: hud!)
        self.formatter.dateFormat = "yyyy"
        let date = self.formatter.string(from: Date())
        session.queryActivity(userId: (pool?.currentUser()?.username)!, date: date) { (response, responseArray) in
            
            DispatchQueue.main.async {
                self.hideHUD(hud: self.hud!)
            }
            print("Response: " + response)
            if response == "success" {
                DispatchQueue.main.async {
                    self.array = responseArray
                    self.formatter.dateFormat = "MM/dd/yyyy h:mm a"
                    for item in self.array {
                        for activity in item._exerciseList! {
                            let exerciseItem = ExerciseItem()
                            exerciseItem.exerciseID = activity["exerciseID"] as! String
                            exerciseItem.exerciseName = activity["exerciseName"] as! String
                            
                            
                            if !self.set.contains(exerciseItem) {
                               
                            }
                            else {
                                let storedExerciseItem = self.set.first(where: {$0.exerciseID == exerciseItem.exerciseID})
                                self.set.remove(storedExerciseItem!)
                                
                                let date = self.formatter.date(from: item._date!)
                                let weekNumber = Calendar.current.component(.weekOfYear, from: date!)
                                
                                switch(weekNumber) {
                                case(1):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[1] += Int(activity["Count"] as! String)!
                                    }
                                case(2):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[2] += Int(activity["Count"] as! String)!
                                    }
                                case(3):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[3] += Int(activity["Count"] as! String)!
                                    }
                                case(4):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[4] += Int(activity["Count"] as! String)!
                                    }
                                case(5):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[5] += Int(activity["Count"] as! String)!
                                    }
                                case(6):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[6] += Int(activity["Count"] as! String)!
                                    }
                                case(7):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[7] += Int(activity["Count"] as! String)!
                                    }
                                case(8):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[8] += Int(activity["Count"] as! String)!
                                    }
                                case(9):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[9] += Int(activity["Count"] as! String)!
                                    }
                                case(10):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[10] += Int(activity["Count"] as! String)!
                                    }
                                    
                                case(11):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[11] += Int(activity["Count"] as! String)!
                                    }
                                case(12):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[12] += Int(activity["Count"] as! String)!
                                    }
                                case(13):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[13] += Int(activity["Count"] as! String)!
                                    }
                                case(14):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[14] += Int(activity["Count"] as! String)!
                                    }
                                case(15):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[15] += Int(activity["Count"] as! String)!
                                    }
                                case(16):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[16] += Int(activity["Count"] as! String)!
                                    }
                                case(17):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[17] += Int(activity["Count"] as! String)!
                                    }
                                case(18):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[18] += Int(activity["Count"] as! String)!
                                    }
                                case(19):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[19] += Int(activity["Count"] as! String)!
                                    }
                                case(20):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[20] += Int(activity["Count"] as! String)!
                                    }
                                    
                                case(21):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[21] += Int(activity["Count"] as! String)!
                                    }
                                case(22):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[22] += Int(activity["Count"] as! String)!
                                    }
                                case(23):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[23] += Int(activity["Count"] as! String)!
                                    }
                                case(24):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[24] += Int(activity["Count"] as! String)!
                                    }
                                case(25):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[25] += Int(activity["Count"] as! String)!
                                    }
                                case(26):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[26] += Int(activity["Count"] as! String)!
                                    }
                                case(27):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[27] += Int(activity["Count"] as! String)!
                                    }
                                case(28):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[28] += Int(activity["Count"] as! String)!
                                    }
                                case(29):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[29] += Int(activity["Count"] as! String)!
                                    }
                                case(30):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[30] += Int(activity["Count"] as! String)!
                                    }
                                    
                                case(31):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[31] += Int(activity["Count"] as! String)!
                                    }
                                case(32):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[32] += Int(activity["Count"] as! String)!
                                    }
                                case(33):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[33] += Int(activity["Count"] as! String)!
                                    }
                                case(34):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[34] += Int(activity["Count"] as! String)!
                                    }
                                case(35):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[35] += Int(activity["Count"] as! String)!
                                    }
                                case(36):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[36] += Int(activity["Count"] as! String)!
                                    }
                                case(37):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[37] += Int(activity["Count"] as! String)!
                                    }
                                case(38):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[38] += Int(activity["Count"] as! String)!
                                    }
                                case(39):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[39] += Int(activity["Count"] as! String)!
                                    }
                                case(40):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[40] += Int(activity["Count"] as! String)!
                                    }
                                    
                                case(41):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[41] += Int(activity["Count"] as! String)!
                                    }
                                case(42):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[42] += Int(activity["Count"] as! String)!
                                    }
                                case(43):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[43] += Int(activity["Count"] as! String)!
                                    }
                                case(44):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[44] += Int(activity["Count"] as! String)!
                                    }
                                case(45):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[45] += Int(activity["Count"] as! String)!
                                    }
                                case(46):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[46] += Int(activity["Count"] as! String)!
                                    }
                                case(47):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[47] += Int(activity["Count"] as! String)!
                                    }
                                case(48):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[48] += Int(activity["Count"] as! String)!
                                    }
                                case(49):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[49] += Int(activity["Count"] as! String)!
                                    }
                                case(50):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[50] += Int(activity["Count"] as! String)!
                                    }
                                    
                                case(51):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[51] += Int(activity["Count"] as! String)!
                                    }
                                case(52):
                                    if activity["Count"] != nil {
                                        storedExerciseItem?.weeklyCount[52] += Int(activity["Count"] as! String)!
                                    }
                                    
                                default:
                                    break
                                }
                                self.set.insert(storedExerciseItem!)
                            }
                        }
                    }
                    var exerciseItemArray: [ExerciseItem] = Array(self.set)
                    exerciseItemArray = exerciseItemArray.sorted(by: { $0.exerciseName < $1.exerciseName })
                    for item in exerciseItemArray {
                        print("Item Name: ", item.exerciseName)
                        print("Item Weight: ", item.exerciseWeightAmount)
                        print("Item Count: ", item.exerciseCount)
                        
                        if item.goalCount != 0 {
                            
                            for (index, element) in item.weeklyCount.enumerated() {
                                print("Week: ", "\(index+1)" + " , Count: ", element)
                            }
                            
                            let element = AASeriesElement()
                            element.name(item.exerciseName)
                            element.data(item.weeklyCount)
                            //element.data(self.testArray)
                            //self.seriesArray.append(element)
                            let store = element.toDic()
                            self.seriesArray.append(store!)
                            
                            for step in self.testArray {
                                print("Step:", step)
                            }
                        }
                    }
                    print("Series array count: ", self.seriesArray.count)
                    
                    self.aaChartModel = AAChartModel.init()
                        .chartType(AAChartType.Column)//Can be any of the chart types listed under `AAChartType`.
                        .zoomType(AAChartZoomType.XY)
                        .animationType(AAChartAnimationType.Bounce)
                        .stacking(AAChartStackingType.False)
                        //.title("TITLE")//The chart title
                        .dataLabelEnabled(false) //Enable or disable the data labels. Defaults to false
                        //.tooltipValueSuffix("")//the value suffix of the chart tooltip
                        .categories(["Week 1", "Week 2", "Week 3", "Week 4", "Week 5", "Week 6", "Week 7", "Week 8", "Week 9", "Week 10",
                                     "Week 11", "Week 12", "Week 13", "Week 14", "Week 15", "Week 16", "Week 17", "Week 18", "Week 19", "Week 20",
                                     "Week 21", "Week 22", "Week 23", "Week 24", "Week 25", "Week 26", "Week 27", "Week 28", "Week 29", "Week 30",
                                     "Week 31", "Week 32", "Week 33", "Week 34", "Week 35", "Week 36", "Week 37", "Week 38", "Week 39", "Week 40",
                                     "Week 41", "Week 42", "Week 43", "Week 44", "Week 45", "Week 46", "Week 47", "Week 48", "Week 49", "Week 50", "Week 51", "Week 52"])
                       // .colorsTheme(["#fe117c","#ffc069","#06caf4","#7dffc0"])
                        .series(self.seriesArray)
                    
                    self.aaChartView.aa_drawChartWithChartModel(self.aaChartModel!)
                    
                    if self.seriesArray.count == 0 {
                        DispatchQueue.main.async {
                            self.emptyGoalsLabel.isHidden = false
                            self.aaChartView.isHidden = true
                        }
                    }
                    else {
                        self.emptyGoalsLabel.isHidden = true
                        self.aaChartView.isHidden = false
                    }
                }
            }
            else if response == "no result" {
                DispatchQueue.main.async {
                     self.emptyGoalsLabel.text = "No sessions added to calculate values"
                     self.emptyGoalsLabel.isHidden = false
                     self.aaChartView.isHidden = true
                }
            }
            else {
                print("Response: " + response)
            }
        }
    }
    
    func getGoals() {
        self.showHUD(hud: hud!)
        self.formatter.dateFormat = "yyyy"
        let date = self.formatter.string(from: Date())
        print("Date: ", date)
        self.goal.queryGoal(userId: (pool?.currentUser()?.username)!, date: date) { (response, responseArray) in
            DispatchQueue.main.async {
                self.hideHUD(hud: self.hud!)
            }
            if response == "success" {
                DispatchQueue.main.async {
                    self.emptyGoalsLabel.isHidden = true
                    self.aaChartView.isHidden = false
                    self.goalArray = responseArray
                    
                    for item in self.goalArray {
                        let exerciseItem = ExerciseItem()
                        exerciseItem.exerciseID = item._exercise!["ID"]!
                        exerciseItem.exerciseName = item._exercise!["Name"]!
                        
                        if !self.set.contains(exerciseItem) {
                            
                            if item._weight?.intValue != nil {
                                exerciseItem.goalWeight = (item._weight?.intValue)!
                            }
                            else if item._distance?.intValue != nil {
                                exerciseItem.goalDistance = (item._distance?.intValue)!
                            }
                            else if item._time?.intValue != nil {
                                exerciseItem.goalTime = (item._time?.intValue)!
                            }
                            else if item._calories?.intValue != nil {
                                exerciseItem.goalCount = (item._calories?.intValue)!
                            }
                            self.set.insert(exerciseItem)
                        }
                        else {
                            let storedExerciseItem = self.set.first(where: {$0.exerciseID == exerciseItem.exerciseID})
                            self.set.remove(storedExerciseItem!)
                            
                            if item._weight?.intValue != nil {
                                storedExerciseItem?.goalWeight += (item._weight?.intValue)!
                            }
                            else if item._distance?.intValue != nil {
                                storedExerciseItem?.goalDistance += (item._distance?.intValue)!
                            }
                            else if item._time?.intValue != nil {
                                storedExerciseItem?.goalTime += (item._time?.intValue)!
                            }
                            else if item._calories?.intValue != nil {
                                storedExerciseItem?.goalCount += (item._calories?.intValue)!
                            }
                            self.set.insert(storedExerciseItem!)
                        }
                    }
                    self.getSessions()
                }
            }
            else {
                    DispatchQueue.main.async {
                    self.emptyGoalsLabel.text = "You haven't added any goals"
                    self.emptyGoalsLabel.isHidden = false
                    self.aaChartView.isHidden = true
                }
            }
        }
    }
    
    @objc func goBack() {
        self.dismiss(animated: true, completion: nil)
    }
}
