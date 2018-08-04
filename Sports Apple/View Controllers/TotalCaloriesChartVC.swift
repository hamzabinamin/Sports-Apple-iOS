//
//  TotalCaloriesChart.swift
//  Sports Apple
//
//  Created by Hamza Amin on 6/11/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit
import JGProgressHUD
import AWSCognitoIdentityProvider

class TotalCaloriesChartVC: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var emptySessionsLabel: UILabel!
    let aaChartView = AAChartView()
    var aaChartModel: AAChartModel?
    var hud: JGProgressHUD?
    var pool: AWSCognitoIdentityUserPool?
    var array: [Activity] = []
    var caloriesArray = [Int](repeating: 0, count: 52)
    let formatter = DateFormatter()
    var session: Activity = Activity()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        getSessions()
    }
    
    func setupViews() {
        hud = self.createLoadingHUD()
        self.formatter.dateFormat = "MM/dd/yyyy h:mm a"
        self.formatter.locale = Locale(identifier:"en_US_POSIX")
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
        aaChartView.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = aaChartView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 121)
        let bottomConstraint = aaChartView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        let leadingConstraint = aaChartView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
        let trailingConstraint = aaChartView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        // set the content height of aachartView
        // aaChartView?.contentHeight = self.view.frame.size.height
        self.view.addSubview(aaChartView)
        NSLayoutConstraint.activate([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
        
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        
      /*  aaChartModel = AAChartModel.init()
            .chartType(AAChartType.Column)//Can be any of the chart types listed under `AAChartType`.
            .animationType(AAChartAnimationType.Bounce)
            //.title("TITLE")//The chart title
            .dataLabelEnabled(false) //Enable or disable the data labels. Defaults to false
            .tooltipValueSuffix(" Calories")//the value suffix of the chart tooltip
            .categories(["Week 1", "Week 2", "Week 3", "Week 4", "Week 5", "Week 6", "Week 7", "Week 8", "Week 9", "Week 10",
                "Week 11", "Week 12", "Week 13", "Week 14", "Week 15", "Week 16", "Week 17", "Week 18", "Week 19", "Week 20",
                "Week 21", "Week 22", "Week 23", "Week 24", "Week 25", "Week 26", "Week 27", "Week 28", "Week 29", "Week 30",
                "Week 31", "Week 32", "Week 33", "Week 34", "Week 35", "Week 36", "Week 37", "Week 38", "Week 39", "Week 40",
                "Week 41", "Week 42", "Week 43", "Week 44", "Week 45", "Week 46", "Week 47", "Week 48", "Week 49", "Week 50", "Week 51", "Week 52"])
            .colorsTheme(["#06caf4"])
            .series([
                AASeriesElement()
                    .name("Workout")
                    /*.data([2000.0, 2500.9, 2900.5, 3400.5, 3180.2, 4210.5, 4925.2, 4826.5, 5123.3, 5118.3,
                           3000.0, 3500.9, 3900.5, 4400.5, 4180.2, 5210.5, 5925.2, 5826.5, 6123.3, 6118.3,
                           4000.0, 4500.9, 4900.5, 5400.5, 5180.2, 6210.5, 6925.2, 8826.5, 5123.3, 5118.3,
                           3000.0, 3500.9, 3900.5, 4400.5, 4180.2, 5210.5, 5925.2, 5826.5, 6123.3, 6118.3,
                           3000.0, 3500.9, 3900.5, 4400.5, 4180.2, 5210.5, 5925.2, 5826.5, 6123.3, 6118.3,
                           4000.0])*/
                        .data(caloriesArray)
                    .toDic()!,
               ])
        
        aaChartView.aa_drawChartWithChartModel(aaChartModel!) */
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
                    self.emptySessionsLabel.isHidden = true
                    self.aaChartView.isHidden = false
                    self.array = responseArray
                    self.formatter.dateFormat = "MM/dd/yyyy h:mm a"
                    for item in self.array {
                   
                        let date = self.formatter.date(from: item._date!)
                        let weekNumber = Calendar.current.component(.weekOfYear, from: date!)
                        print("Total Calories Date: ", date)
                        print("Total Calories for Session: ", item._calories)
                        print("Total Calories for Session (Week Number): ", weekNumber)
                        
                        
                        switch(weekNumber) {
                            case(1):
                                self.caloriesArray[0] += (item._calories?.intValue)!
                            case(2):
                                self.caloriesArray[1] += (item._calories?.intValue)!
                            case(3):
                                self.caloriesArray[2] += (item._calories?.intValue)!
                            case(4):
                                self.caloriesArray[3] += (item._calories?.intValue)!
                            case(5):
                                self.caloriesArray[4] += (item._calories?.intValue)!
                            case(6):
                                self.caloriesArray[5] += (item._calories?.intValue)!
                            case(7):
                                self.caloriesArray[6] += (item._calories?.intValue)!
                            case(8):
                                self.caloriesArray[7] += (item._calories?.intValue)!
                            case(9):
                                self.caloriesArray[8] += (item._calories?.intValue)!
                            case(10):
                                self.caloriesArray[9] += (item._calories?.intValue)!
                            
                            case(11):
                                self.caloriesArray[10] += (item._calories?.intValue)!
                            case(12):
                                self.caloriesArray[11] += (item._calories?.intValue)!
                            case(13):
                                self.caloriesArray[12] += (item._calories?.intValue)!
                            case(14):
                                self.caloriesArray[13] += (item._calories?.intValue)!
                            case(15):
                                self.caloriesArray[14] += (item._calories?.intValue)!
                            case(16):
                                self.caloriesArray[15] += (item._calories?.intValue)!
                            case(17):
                                self.caloriesArray[16] += (item._calories?.intValue)!
                            case(18):
                                self.caloriesArray[17] += (item._calories?.intValue)!
                            case(19):
                                self.caloriesArray[18] += (item._calories?.intValue)!
                            case(20):
                                self.caloriesArray[19] += (item._calories?.intValue)!
                            
                            case(21):
                                self.caloriesArray[20] += (item._calories?.intValue)!
                            case(22):
                                self.caloriesArray[21] += (item._calories?.intValue)!
                            case(23):
                                self.caloriesArray[22] += (item._calories?.intValue)!
                            case(24):
                                self.caloriesArray[23] += (item._calories?.intValue)!
                            case(25):
                                self.caloriesArray[24] += (item._calories?.intValue)!
                            case(26):
                                self.caloriesArray[25] += (item._calories?.intValue)!
                            case(27):
                                self.caloriesArray[26] += (item._calories?.intValue)!
                            case(28):
                                self.caloriesArray[27] += (item._calories?.intValue)!
                            case(29):
                                self.caloriesArray[28] += (item._calories?.intValue)!
                            case(30):
                                self.caloriesArray[29] += (item._calories?.intValue)!
                            
                            case(31):
                                self.caloriesArray[30] += (item._calories?.intValue)!
                            case(32):
                                self.caloriesArray[31] += (item._calories?.intValue)!
                            case(33):
                                self.caloriesArray[32] += (item._calories?.intValue)!
                            case(34):
                                self.caloriesArray[33] += (item._calories?.intValue)!
                            case(35):
                                self.caloriesArray[34] += (item._calories?.intValue)!
                            case(36):
                                self.caloriesArray[35] += (item._calories?.intValue)!
                            case(37):
                                self.caloriesArray[36] += (item._calories?.intValue)!
                            case(38):
                                self.caloriesArray[37] += (item._calories?.intValue)!
                            case(39):
                                self.caloriesArray[38] += (item._calories?.intValue)!
                            case(40):
                                self.caloriesArray[39] += (item._calories?.intValue)!
                            
                            case(41):
                                self.caloriesArray[40] += (item._calories?.intValue)!
                            case(42):
                                self.caloriesArray[41] += (item._calories?.intValue)!
                            case(43):
                                self.caloriesArray[42] += (item._calories?.intValue)!
                            case(44):
                                self.caloriesArray[43] += (item._calories?.intValue)!
                            case(45):
                                self.caloriesArray[44] += (item._calories?.intValue)!
                            case(46):
                                self.caloriesArray[45] += (item._calories?.intValue)!
                            case(47):
                                self.caloriesArray[46] += (item._calories?.intValue)!
                            case(48):
                                self.caloriesArray[47] += (item._calories?.intValue)!
                            case(49):
                                self.caloriesArray[48] += (item._calories?.intValue)!
                            case(50):
                                self.caloriesArray[49] += (item._calories?.intValue)!
                            
                            case(51):
                                self.caloriesArray[50] += (item._calories?.intValue)!
                            case(52):
                                self.caloriesArray[51] += (item._calories?.intValue)!
                            
                            default:
                                break
                        }
                    }
                    self.aaChartModel = AAChartModel.init()
                        .chartType(AAChartType.Column)//Can be any of the chart types listed under `AAChartType`.
                        .animationType(AAChartAnimationType.Bounce)
                         .zoomType(AAChartZoomType.XY)
                        //.title("TITLE")//The chart title
                        .dataLabelEnabled(false) //Enable or disable the data labels. Defaults to false
                        .tooltipValueSuffix(" Calories")//the value suffix of the chart tooltip
                        .categories(["Week 1", "Week 2", "Week 3", "Week 4", "Week 5", "Week 6", "Week 7", "Week 8", "Week 9", "Week 10",
                                     "Week 11", "Week 12", "Week 13", "Week 14", "Week 15", "Week 16", "Week 17", "Week 18", "Week 19", "Week 20",
                                     "Week 21", "Week 22", "Week 23", "Week 24", "Week 25", "Week 26", "Week 27", "Week 28", "Week 29", "Week 30",
                                     "Week 31", "Week 32", "Week 33", "Week 34", "Week 35", "Week 36", "Week 37", "Week 38", "Week 39", "Week 40",
                                     "Week 41", "Week 42", "Week 43", "Week 44", "Week 45", "Week 46", "Week 47", "Week 48", "Week 49", "Week 50", "Week 51", "Week 52"])
                        .colorsTheme(["#06caf4"])
                        .series([
                            AASeriesElement()
                                .name("Workout")
                                .data(self.caloriesArray)
                                .toDic()!,
                            ])
                    
                    self.aaChartView.aa_drawChartWithChartModel(self.aaChartModel!)
                }
            }
            else if response == "no result" {
                DispatchQueue.main.async {
                    self.emptySessionsLabel.isHidden = false
                    self.aaChartView.isHidden = true
                }
            }
            else {
                print("Response: " + response)
            }
        }
    }
    
    @objc func goBack() {
        self.dismiss(animated: true, completion: nil)
    }
}
