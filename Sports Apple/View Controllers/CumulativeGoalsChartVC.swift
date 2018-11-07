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
        
        //self.formatter.dateFormat = "MM/dd/yyyy h:mm a"
        self.formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
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
                    
                    //self.formatter.dateFormat = "MM/dd/yyyy h:mm a"
                    self.formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    
                    for item in self.array {
                        let date = self.formatter.date(from: item._date!)
                        let weekNumber = Calendar.current.component(.weekOfYear, from: date!)
                        
                        if self.set.contains(where: {$0.exerciseName == "Calories"}) || self.set.contains(where: {$0.exerciseName == "Calorie"}) || self.set.contains(where: {$0.exerciseName == "calories"}) || self.set.contains(where: {$0.exerciseName == "calorie"}) {
                            let storedExerciseItem = self.set.first(where: {$0.exerciseName == "Calories" || $0.exerciseName == "Calorie" || $0.exerciseName == "calories" || $0.exerciseName == "calorie" })
                            self.set.remove(storedExerciseItem!)
                            
                            switch(weekNumber) {
                            case(1):
                              if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[1] += (item._calories?.floatValue)!
                                }
                            case(2):
                               if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[2] += (item._calories?.floatValue)!
                               }
                            case(3):
                               if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[3] += (item._calories?.floatValue)!
                                }
                            case(4):
                              if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[4] += (item._calories?.floatValue)!
                                }
                            case(5):
                              if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[5] += (item._calories?.floatValue)!
                                }
                            case(6):
                              if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[6] += (item._calories?.floatValue)!
                                }
                            case(7):
                                if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[7] += (item._calories?.floatValue)!
                                }
                            case(8):
                               if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[8] += (item._calories?.floatValue)!
                                }
                            case(9):
                               if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[9] += (item._calories?.floatValue)!
                                }
                            case(10):
                               if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[10] += (item._calories?.floatValue)!
                                }
                            case(11):
                                if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[11] += (item._calories?.floatValue)!
                                }
                            case(12):
                               if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[12] += (item._calories?.floatValue)!
                                }
                            case(13):
                              if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[13] += (item._calories?.floatValue)!
                                }
                            case(14):
                              if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[14] += (item._calories?.floatValue)!
                                }
                            case(15):
                              if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[15] += (item._calories?.floatValue)!
                                }
                            case(16):
                                if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[16] += (item._calories?.floatValue)!
                                }
                            case(17):
                                if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[17] += (item._calories?.floatValue)!
                                }
                            case(18):
                                if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[18] += (item._calories?.floatValue)!
                                }
                            case(19):
                                if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[19] += (item._calories?.floatValue)!
                                }
                            case(20):
                                if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[20] += (item._calories?.floatValue)!
                                }
                            case(21):
                                if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[21] += (item._calories?.floatValue)!
                                }
                            case(22):
                                if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[22] += (item._calories?.floatValue)!
                                }
                            case(23):
                                if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[23] += (item._calories?.floatValue)!
                                }
                            case(24):
                                if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[24] += (item._calories?.floatValue)!
                                }
                            case(25):
                                if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[25] += (item._calories?.floatValue)!
                                }
                            case(26):
                                if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[26] += (item._calories?.floatValue)!
                                }
                            case(27):
                                if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[27] += (item._calories?.floatValue)!
                                }
                            case(28):
                                if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[28] += (item._calories?.floatValue)!
                                }
                            case(29):
                                if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[29] += (item._calories?.floatValue)!
                                }
                            case(30):
                                if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[30] += (item._calories?.floatValue)!
                                }
                            case(31):
                                if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[31] += (item._calories?.floatValue)!
                                }
                            case(32):
                                if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[32] += (item._calories?.floatValue)!
                                }
                            case(33):
                                if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[33] += (item._calories?.floatValue)!
                                }
                            case(34):
                                if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[34] += (item._calories?.floatValue)!
                                }
                            case(35):
                                if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[35] += (item._calories?.floatValue)!
                                }
                            case(36):
                                if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[36] += (item._calories?.floatValue)!
                                }
                            case(37):
                                if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[37] += (item._calories?.floatValue)!
                                }
                            case(38):
                                if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[38] += (item._calories?.floatValue)!
                                }
                            case(39):
                                if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[39] += (item._calories?.floatValue)!
                                }
                            case(40):
                                if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[40] += (item._calories?.floatValue)!
                                }
                            case(41):
                                if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[41] += (item._calories?.floatValue)!
                                }
                            case(42):
                                if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[42] += (item._calories?.floatValue)!
                                }
                            case(43):
                                if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[43] += (item._calories?.floatValue)!
                                }
                            case(44):
                                if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[44] += (item._calories?.floatValue)!
                                }
                            case(45):
                                if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[45] += (item._calories?.floatValue)!
                                }
                            case(46):
                                if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[46] += (item._calories?.floatValue)!
                                }
                            case(47):
                                if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[47] += (item._calories?.floatValue)!
                                }
                            case(48):
                                if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[48] += (item._calories?.floatValue)!
                                }
                            case(49):
                                if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[49] += (item._calories?.floatValue)!
                                }
                            case(50):
                                if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[50] += (item._calories?.floatValue)!
                                }
                            case(51):
                                if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[51] += (item._calories?.floatValue)!
                                }
                            case(52):
                                if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                        print("ExerciseName is calories")
                                        storedExerciseItem?.weeklyCount[52] += (item._calories?.floatValue)!
                                }
                                
                            default:
                                break
                            }
                            self.set.insert(storedExerciseItem!)
                        }
                        
                        for activity in item._exerciseList! {
                            let exerciseItem = ExerciseItem()
                            exerciseItem.exerciseID = activity["exerciseID"] as! String
                            exerciseItem.exerciseName = activity["exerciseName"] as! String
                            
                            
                            if !self.set.contains(exerciseItem) {
                               
                            }
                            else {
                                let storedExerciseItem = self.set.first(where: {$0.exerciseID == exerciseItem.exerciseID})
                                self.set.remove(storedExerciseItem!)
                                
                                
                                switch(weekNumber) {
                                case(1):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[1] += (item._calories?.floatValue)!
                                            
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[1] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(2):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[2] += (item._calories?.floatValue)!
                                            
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[2] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(3):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[3] += (item._calories?.floatValue)!
                                            
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[3] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(4):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[4] += (item._calories?.floatValue)!
                                            
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[4] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(5):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[5] += (item._calories?.floatValue)!
                                            
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[5] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(6):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[6] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[6] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(7):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[7] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[7] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(8):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[8] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[8] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(9):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[9] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[9] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(10):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[10] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[10] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                    
                                case(11):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[11] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[11] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(12):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[12] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[12] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(13):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[13] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[13] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(14):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[14] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[14] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(15):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[15] += (item._calories?.floatValue)!
                                            
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[15] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(16):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[16] += (item._calories?.floatValue)!
                                            
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[16] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(17):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[17] += (item._calories?.floatValue)!
                                            
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[17] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(18):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[18] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[18] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(19):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[19] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[19] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(20):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[20] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[20] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                    
                                case(21):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[21] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[21] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(22):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[22] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[22] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(23):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[23] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[23] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(24):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[24] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[24] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(25):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[25] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[25] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(26):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[26] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[26] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(27):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[27] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[27] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(28):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[28] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[28] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(29):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[29] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[29] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(30):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[30] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[30] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                    
                                case(31):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[31] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[31] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(32):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[32] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[32] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(33):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[33] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[33] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(34):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[34] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[34] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(35):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[35] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[35] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(36):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[36] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[36] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(37):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[37] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[37] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(38):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[38] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[38] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(39):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[39] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[39] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(40):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[40] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[40] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                    
                                case(41):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[41] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[41] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(42):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[42] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[42] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(43):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[43] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[43] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(44):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[44] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[44] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(45):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[45] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[45] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(46):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[46] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[46] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(47):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[47] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[47] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(48):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[48] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[48] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(49):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[49] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[49] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(50):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[50] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[50] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                    
                                case(51):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[51] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[51] += Float(activity["Count"] as! String)!
                                        }
                                    }
                                case(52):
                                    if activity["Count"] != nil {
                                        if storedExerciseItem?.exerciseName == "Calories" || storedExerciseItem?.exerciseName == "Calorie" || storedExerciseItem?.exerciseName == "calories" || storedExerciseItem?.exerciseName == "calorie" {
                                            print("ExerciseName is calories")
                                            storedExerciseItem?.weeklyCount[52] += (item._calories?.floatValue)!
                                        }
                                        else {
                                            storedExerciseItem?.weeklyCount[52] += Float(activity["Count"] as! String)!
                                        }
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
                                exerciseItem.goalWeight = (item._weight?.floatValue)!
                            }
                            else if item._distance?.intValue != nil {
                                exerciseItem.goalDistance = (item._distance?.intValue)!
                            }
                            else if item._time?.intValue != nil {
                                exerciseItem.goalTime = (item._time?.intValue)!
                            }
                            else if item._calories?.intValue != nil {
                                exerciseItem.goalCount = (item._calories?.floatValue)!
                            }
                            self.set.insert(exerciseItem)
                        }
                        else {
                            let storedExerciseItem = self.set.first(where: {$0.exerciseID == exerciseItem.exerciseID})
                            self.set.remove(storedExerciseItem!)
                            
                            if item._weight?.intValue != nil {
                                storedExerciseItem?.goalWeight += (item._weight?.floatValue)!
                            }
                            else if item._distance?.intValue != nil {
                                storedExerciseItem?.goalDistance += (item._distance?.intValue)!
                            }
                            else if item._time?.intValue != nil {
                                storedExerciseItem?.goalTime += (item._time?.intValue)!
                            }
                            else if item._calories?.intValue != nil {
                                storedExerciseItem?.goalCount += (item._calories?.floatValue)!
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
