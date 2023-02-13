//
//  GoalStatusReportVC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 6/10/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit
import SwiftDataTables
import JGProgressHUD
import AWSCognitoIdentityProvider
import PDFGenerator
import CSV

class GoalStatusReportVC: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var exportButton: UIButton!
    var dataTable: SwiftDataTable! = nil
    var dataTableConfig: DataTableConfiguration?
    var dataSource: DataTableContent = []
    var dataRows: [DataTableRow] = []
    var array: [Activity] = []
    var goalArray: [Goal] = []
    var stringArray: [[String]] = []
    var hud: JGProgressHUD?
    var pool: AWSCognitoIdentityUserPool?
    var session: Activity = Activity()
    var goal: Goal = Goal()
    var set: Set<ExerciseItem> = []
    let formatter = DateFormatter()
    let numberFormatter: NumberFormatter = NumberFormatter()
    let numFormatter = NumberFormatter()
    var daysWorkedOut = 0
    var daysInYear = 365
    var daysPastInYear = 0
    var daysLeftInYear = 0
    var weeks = 0
    var totalCalories: Float = 0
    
    let headerTitles = ["Activity", "Cumulative Goal", "Year-to-Date", "Weight Goal", "Max Weight",
                        "Distance Goal", "Total Distance", "Time Goal", "Max Time", "To Meet Goal",
                        "Pct%", "To Do Per Day", "Projected", "Avg Per Day"]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        getGoals()
        daysPastInYear = Calendar.current.ordinality(of: .day, in: .year, for: Date())!
        daysLeftInYear = daysInYear - daysPastInYear
        weeks = daysPastInYear/7
        print("Days Left: ", daysLeftInYear)
    }
    
    func setupViews() {
        hud = self.createLoadingHUD()
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = UIColor.white
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
        self.dataTable = SwiftDataTable(dataSource: self)
        self.dataTableConfig = DataTableConfiguration()
        self.dataTableConfig?.highlightedAlternatingRowColors = [UIColor.red]
        

        self.dataTable.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //self.dataTable.frame.origin.x = self.view.frame.origin.x
        //self.dataTable.frame.origin.y = 600
        self.dataTable.translatesAutoresizingMaskIntoConstraints = false
        
        //self.formatter.dateFormat = "MM/dd/yyyy h:mm a"
        self.formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        self.formatter.locale = Locale(identifier:"en_US_POSIX")
        self.numberFormatter.locale = Locale(identifier:"en_US")
        self.numberFormatter.numberStyle = NumberFormatter.Style.decimal
        
        numFormatter.locale = Locale(identifier:"en_US")
        numFormatter.maximumFractionDigits = 1
        
        let topConstraint = self.dataTable.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 121)
        let bottomConstraint = self.dataTable.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        let leadingConstraint = self.dataTable.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
        let trailingConstraint = self.dataTable.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        self.view.addSubview(self.dataTable)
        
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        exportButton.addTarget(self, action: #selector(createPDF), for: .touchUpInside)
        
        NSLayoutConstraint.activate([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
    }
    
    func getSessions() {
        //self.showHUD(hud: hud!)
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
                    
                    for item in self.array {
                            self.totalCalories += item._calories!.floatValue
                        for activity in item._exerciseList! {
                            let exerciseItem = ExerciseItem()
                            exerciseItem.exerciseID = activity["exerciseID"] as! String
                            exerciseItem.exerciseName = activity["exerciseName"] as! String
                            
                            exerciseItem.exerciseCount = Float(activity["Count"] as? String ?? "") ?? 0
                            exerciseItem.exerciseTime = activity["Time"] as? Int ?? 0
                            exerciseItem.exerciseDistance = Int(activity["Distance"] as? String ?? "") ?? 0
                            exerciseItem.exerciseWeightAmount = Float(activity["Weight Amount"] as? String ?? "") ?? 0
                            
                            if !self.set.contains(where: {(  ( ($0.goalCount != 0 && exerciseItem.exerciseCount != 0) || ($0.goalTime != 0 && exerciseItem.exerciseTime != 0) || ($0.goalDistance != 0 && exerciseItem.exerciseDistance != 0) || ($0.goalWeight != 0 && exerciseItem.exerciseWeightAmount != 0) ) && ($0.exerciseID == exerciseItem.exerciseID || $0.exerciseName == exerciseItem.exerciseName) )}) {
                            /*    if activity["Weight Amount"] != nil {
                                    exerciseItem.exerciseWeightAmount = Int(activity["Weight Amount"] as! String)!
                                    exerciseItem.exerciseSets = Int(activity["Sets"] as! String)!
                                    exerciseItem.exerciseReps = Int(activity["Reps"] as! String)!
                                }
                                else if activity["Time"] != nil {
                                    exerciseItem.exerciseTime = activity["Time"] as! Int
                                }
                                else if activity["Count"] != nil {
                                    exerciseItem.exerciseCount = Int(activity["Count"] as! String)!
                                }
                                else if activity["Distance"] != nil {
                                    exerciseItem.exerciseDistance = Int(activity["Distance"] as! String)!
                                }
                                self.set.insert(exerciseItem) */
                            }
                            else {
                                let storedExerciseItem = self.set.first(where: {$0.exerciseID == exerciseItem.exerciseID || $0.exerciseName == exerciseItem.exerciseName})
                                self.set.remove(storedExerciseItem!)
                                if activity["Weight Amount"] != nil {
                                    
                                    if (storedExerciseItem?.exerciseWeightAmount)! < Float(activity["Weight Amount"] as! String)! {
                                        storedExerciseItem?.exerciseWeightAmount = Float(activity["Weight Amount"] as! String)!
                                        storedExerciseItem?.exerciseSets = Int(activity["Sets"] as! String)!
                                        storedExerciseItem?.exerciseReps = Int(activity["Reps"] as! String)!
                                    }
                                }
                                else if activity["Time"] != nil {
                                    storedExerciseItem?.exerciseTime += activity["Time"] as! Int
                                }
                                else if activity["Count"] != nil {
                                    storedExerciseItem?.exerciseCount += Float(activity["Count"] as! String)!
                                }
                                else if activity["Distance"] != nil {
                                    storedExerciseItem?.exerciseDistance += Int(activity["Distance"] as! String)!
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
                        var row: DataTableRow = [DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""),
                                                 DataTableValueType.string(""), DataTableValueType.string(""),
                                                 DataTableValueType.string(""), DataTableValueType.string(""),
                                                 DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string("")]
                        
                        var stringRow: [String] = ["", "", "", "", "", "", "", "" , "", "", "", "", "", ""]
                        
                        row[0] = DataTableValueType.string(item.exerciseName)
                        stringRow[0] = item.exerciseName
                        
                        if item.goalWeight != 0 || item.exerciseWeightAmount != 0 {
                            row[3] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: item.goalWeight))!)
                            stringRow[3] = self.numFormatter.string(from: NSNumber(value: item.goalWeight))!
                            
                            row[4] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: item.exerciseWeightAmount))!)
                            stringRow[4] = self.numFormatter.string(from: NSNumber(value: item.exerciseWeightAmount))!
                            
                            if item.goalWeight - item.exerciseWeightAmount < 0 {
                                row[9] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: (0)))!)
                                stringRow[9] = self.numFormatter.string(from: NSNumber(value: (0)))!
                            }
                            else {
                                row[9] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: (item.goalWeight - item.exerciseWeightAmount)))!)
                                stringRow[9] = self.numFormatter.string(from: NSNumber(value: (item.goalWeight - item.exerciseWeightAmount)))!
                            }
                            
                            let percentage = ((Float(item.exerciseWeightAmount) / Float(item.goalWeight)) * 100)
                            row[10] = DataTableValueType.string("\(percentage.rounded(.toNearestOrAwayFromZero))" + "%")
                            stringRow[10] = "\(percentage.rounded(.toNearestOrAwayFromZero))" + "%"
                            
                            var projected = Float(0)
                            if ((Float(item.exerciseWeightAmount) / Float(self.daysPastInYear)) * Float(self.daysLeftInYear)) + Float(item.exerciseWeightAmount) < item.goalWeight {
                                projected = (((Float(item.exerciseWeightAmount) / Float(self.daysPastInYear)) * Float(self.daysLeftInYear)) + Float(item.exerciseWeightAmount)) * -1.0
                            }
                            else {
                                projected = (((Float(item.exerciseWeightAmount) / Float(self.daysPastInYear)) * Float(self.daysLeftInYear)) + Float(item.exerciseWeightAmount)) /* + Float(item.exerciseWeightAmount) */
                            }
                            //row[12] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: projected))!)
                            //row[12]
                        }
                        if item.goalTime != 0 || item.exerciseTime != 0 {
                            let hours = (item.goalTime) / 3600
                            let minutes = ((item.goalTime) / 60) % 60
                            let hoursTotal = (item.exerciseTime) / 3600
                            let minutesTotal = ((item.exerciseTime) / 60) % 60
                            let hoursDiff = (item.goalTime - item.exerciseTime) / 3600
                            let minutesDiff = ((item.goalTime - item.exerciseTime) / 60) % 60
                            
                            row[7] = DataTableValueType.string(String(format: "%02d:%02d", hours, minutes))
                            stringRow[7] = String(format: "%02d:%02d", hours, minutes)
                            
                            
                            row[8] = DataTableValueType.string(String(format: "%02d:%02d", hoursTotal, minutesTotal))
                            stringRow[8] = String(format: "%02d:%02d", hoursTotal, minutesTotal)
                            
                            if item.goalTime - item.exerciseTime < 0 {
                                row[9] = DataTableValueType.string(String(format: "%02d:%02d", 0, 0))
                                stringRow[9] = String(format: "%02d:%02d", 0, 0)
                            }
                            else {
                                row[9] = DataTableValueType.string(String(format: "%02d:%02d", hoursDiff, abs(minutesDiff)))
                                stringRow[9] = String(format: "%02d:%02d", hoursDiff, abs(minutesDiff))
                            }
                            
                            print("Exercise Time: ", Float(item.exerciseTime))
                            print("Goal Time: ", Float(item.goalTime))
                            print("Percentage: ", ((Float(item.exerciseTime) / Float(item.goalTime)) * 100))
                            let percentage = ((Float(item.exerciseTime) / Float(item.goalTime)) * 100)
                            print("Percentage 2", percentage)
                            print("Percentage 3", "\(percentage.rounded(.toNearestOrAwayFromZero))" + "%")
                            row[10] = DataTableValueType.string("\(percentage.rounded(.toNearestOrAwayFromZero))" + "%")
                            stringRow[10] = "\(percentage.rounded(.toNearestOrAwayFromZero))" + "%"
                        }
                        if item.goalDistance != 0 || item.exerciseDistance != 0 {
                            row[5] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: item.goalDistance))!)
                            stringRow[5] = self.numFormatter.string(from: NSNumber(value: item.goalDistance))!
                            
                            row[6] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: item.exerciseDistance))!)
                            stringRow[6] = self.numFormatter.string(from: NSNumber(value: item.exerciseDistance))!
                            
                            if item.goalDistance - item.exerciseDistance < 0 {
                                row[9] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: (0)))!)
                                stringRow[9] = self.numFormatter.string(from: NSNumber(value: (0)))!
                            }
                            else {
                                row[9] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: (item.goalDistance - item.exerciseDistance)))!)
                                stringRow[9] = self.numFormatter.string(from: NSNumber(value: (item.goalDistance - item.exerciseDistance)))!
                            }
                            
                            print("Distance Exercise Date: ", item.date)
                            print("Distance Exercise ID: ", item.exerciseID)
                            print("Exercise Distance: ", Float(item.exerciseDistance))
                            print("Goal Distance: ", Float(item.goalDistance))
                            print("Percentage Distance: ", ((Float(item.exerciseDistance) / Float(item.goalDistance)) * 100))
                            let percentage = ((Float(item.exerciseDistance) / Float(item.goalDistance)) * 100)
                            row[10] = DataTableValueType.string("\(percentage.rounded(.toNearestOrAwayFromZero))" + "%")
                            stringRow[10] = "\(percentage.rounded(.toNearestOrAwayFromZero))" + "%"
                            
                            var projected = Float(0)
                            if ((Float(item.exerciseDistance) / Float(self.daysPastInYear)) * Float(self.daysLeftInYear)) + Float(item.exerciseDistance) < Float(item.goalDistance) {
                                projected = (((Float(item.exerciseDistance) / Float(self.daysPastInYear)) * Float(self.daysLeftInYear)) + Float(item.exerciseDistance)) * -1.0
                            }
                            else {
                                projected = (((Float(item.exerciseDistance) / Float(self.daysPastInYear)) * Float(self.daysLeftInYear)) + Float(item.exerciseDistance)) /* + Float(item.exerciseDistance) */
                            }
                            row[12] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: projected.rounded(.toNearestOrAwayFromZero)))!)
                            stringRow[12] = self.numFormatter.string(from: NSNumber(value: projected.rounded(.toNearestOrAwayFromZero)))!
                            
                            
                        }
                        if item.goalCount != 0 || item.exerciseCount != 0 {
                            if item.exerciseName == "Calories" || item.exerciseName == "Calorie" || item.exerciseName == "calories" || item.exerciseName == "calorie" {
                                
                                row[1] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: item.goalCount))!)
                                stringRow[1] = self.numFormatter.string(from: NSNumber(value: item.goalCount))!
                                
                                row[2] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: self.totalCalories))!)
                                stringRow[2] = self.numFormatter.string(from: NSNumber(value: self.totalCalories))!
                                
                                let avgPerDay = (Float(self.totalCalories) / Float(self.daysPastInYear))
                                let avgPerDayStore = String(format: "%.01f", avgPerDay)
                                
                                row[13] = DataTableValueType.string(avgPerDayStore)
                                stringRow[13] = avgPerDayStore
                            
                                var meetGoal = (item.goalCount - self.totalCalories)
                                
                                if meetGoal < 0 {
                                    meetGoal = 0
                                }
                            
                                row[9] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: meetGoal))!)
                                stringRow[9] = self.numFormatter.string(from: NSNumber(value: meetGoal))!
                                
                                let percentage = ((Float(self.totalCalories) / Float(item.goalCount)) * 100)
                                row[10] = DataTableValueType.string("\(percentage.rounded(.toNearestOrAwayFromZero))" + "%")
                                stringRow[10] = "\(percentage.rounded(.toNearestOrAwayFromZero))" + "%"
                                
                                //row[11] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: (Float(meetGoal) / Float(self.daysLeftInYear)).rounded(.toNearestOrAwayFromZero)))!)
                                let perDay = (Float(meetGoal) / Float(self.daysLeftInYear))
                                let perDayString = String(format: "%.01f", perDay)
                                row[11] = DataTableValueType.string(perDayString)
                                stringRow[11] = perDayString
                                
                                var projected = Float(0)
                                if ((Float(self.totalCalories) / Float(self.daysPastInYear)) * Float(self.daysLeftInYear)) + Float(self.totalCalories) < item.goalCount {
                                    print("In If of calories projected")
                                    print("Total Calories: ", (Float(self.totalCalories)))
                                    print("Days Past: ", Float(self.daysPastInYear))
                                    print("Days Left: ", Float(self.daysLeftInYear))
                                    
                                    projected = (((Float(self.totalCalories) / Float(self.daysPastInYear)) * Float(self.daysLeftInYear)) + Float(self.totalCalories)) * -1.0
                                    print("Projected: ", Float(projected))
                                }
                                else {
                                    projected = (((Float(self.totalCalories) / Float(self.daysPastInYear)) * Float(self.daysLeftInYear)) + Float(self.totalCalories)) /*+ Float(self.totalCalories) */
                                    print("In else of calories projected")
                                    print("Total Calories: ", (Float(self.totalCalories)))
                                    print("Days Past: ", Float(self.daysPastInYear))
                                    print("Days Left: ", Float(self.daysLeftInYear))
                                    print("Projected: ", Float(projected))
                                }
                                row[12] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: projected.rounded(.toNearestOrAwayFromZero)))!)
                                stringRow[12] = self.numFormatter.string(from: NSNumber(value: projected.rounded(.toNearestOrAwayFromZero)))!
                            }
                            else {
                                row[1] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: item.goalCount))!)
                                stringRow[1] = self.numFormatter.string(from: NSNumber(value: item.goalCount))!
                                
                                row[2] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: item.exerciseCount))!)
                                stringRow[2] = self.numFormatter.string(from: NSNumber(value: item.exerciseCount))!
                                
                                let avgPerDay = (Float(item.exerciseCount) / Float(self.daysPastInYear))
                                let avgPerDayStore = String(format: "%.01f", avgPerDay)
                                
                                row[13] = DataTableValueType.string(avgPerDayStore)
                                stringRow[13] = avgPerDayStore
                                
                                var meetGoal = (item.goalCount - item.exerciseCount)
                                
                                if meetGoal < 0 {
                                    meetGoal = 0
                                }
                                
                                row[9] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: meetGoal))!)
                                stringRow[9] = self.numFormatter.string(from: NSNumber(value: meetGoal))!
                                
                                let percentage = ((Float(item.exerciseCount) / Float(item.goalCount)) * 100)
                                row[10] = DataTableValueType.string("\(percentage.rounded(.toNearestOrAwayFromZero))" + "%")
                                stringRow[10] = "\(percentage.rounded(.toNearestOrAwayFromZero))" + "%"
                                
                                //row[11] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: (Float(meetGoal) / Float(self.daysLeftInYear)).rounded(.toNearestOrAwayFromZero)))!)
                                let perDay = (Float(meetGoal) / Float(self.daysLeftInYear))
                                let perDayString = String(format: "%.01f", perDay)
                                row[11] = DataTableValueType.string(perDayString)
                                stringRow[11] = perDayString
                                var projected = Float(0)
                                if ((Float(item.exerciseCount) / Float(self.daysPastInYear)) * Float(self.daysLeftInYear)) + Float(item.exerciseCount) < item.goalCount {
                                    projected = (((Float(item.exerciseCount) / Float(self.daysPastInYear)) * Float(self.daysLeftInYear)) + Float(item.exerciseCount)) * -1.0
                                }
                                else {
                                    projected = (((Float(item.exerciseCount) / Float(self.daysPastInYear)) * Float(self.daysLeftInYear)) + Float(item.exerciseCount)) /* + Float(item.exerciseCount) */
                                }
                                row[12] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: projected.rounded(.toNearestOrAwayFromZero)))!)
                                stringRow[12] = self.numFormatter.string(from: NSNumber(value: projected.rounded(.toNearestOrAwayFromZero)))!
                            }
                        }
                        self.dataRows.append(row)
                        self.stringArray.append(stringRow)
                    }
                    self.addDataSourceAfter()
                }
            }
            else if response == "no result" {
                DispatchQueue.main.async {
                    self.dataRows.removeAll()
                    let row: DataTableRow = [DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""),
                                             DataTableValueType.string(""), DataTableValueType.string(""),
                                             DataTableValueType.string(""), DataTableValueType.string(""),
                                             DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string("")]
                    let stringRow: [String] = ["", "", "", "", "", "", "", "" , "", "", "", "", "", ""]
                    
                    self.dataRows.append(row)
                    self.stringArray.append(stringRow)
                    self.addDataSourceAfter()
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
               // self.hideHUD(hud: self.hud!)
            }
            if response == "success" {
                DispatchQueue.main.async {
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
                    self.hideHUD(hud: self.hud!)
                    self.dataRows.removeAll()
                    let row: DataTableRow = [DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""),
                                             DataTableValueType.string(""), DataTableValueType.string(""),
                                             DataTableValueType.string(""), DataTableValueType.string(""),
                                             DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string("")]
                    let stringRow: [String] = ["", "", "", "", "", "", "", "" , "", "", "", "", "", ""]
                    
                    self.dataRows.append(row)
                    self.stringArray.append(stringRow)
                    self.addDataSourceAfter()
                }
            }
        }
    }
    
    public func addDataSourceAfter(){
        self.dataSource = self.dataRows
        self.dataTable.delegate = self
        self.dataTable.reload()
    }
    
    @objc func createPDF() {
       /* let v = dataTable.collectionView
        let dst = URL(fileURLWithPath: NSTemporaryDirectory().appending("Goal Status Report.pdf"))
        do {
            try PDFGenerator.generate([v], to: dst)
            openPDFViewer(dst)
        } catch (let error) {
            print(error)
        } */
        
        let fileName = "Goal Status Report.csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        let stream = OutputStream(toFileAtPath: (path?.path)!, append: false)!
        let csv = try! CSVWriter(stream: stream)
        
        
        
        try! csv.write(row: ["Activity", "Cumulative Goal", "Year-to-Date", "Weight Goal", "Max Weight", "Distance Goal", "Total Distance", "Time Goal", "Max Time", "To Meet Goal", "Pct%", "To Do Per Day", "Projected", "Avg Per Day"])
        
        for row in stringArray {
            try! csv.write(row: [row[0], row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8], row[9], row[10], row[11], row[12], row[13]])
        }
        
        csv.stream.close()
        openPDFViewer(path!)
    }
    
    fileprivate func openPDFViewer(_ pdfPath: URL) {
        //let url = URL(fileURLWithPath: pdfPath)
        let storyboard = UIStoryboard(name: "PDFPreviewVC", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "PDFPreviewVC") as! PDFPreviewVC
        destVC.setupWithURL(pdfPath)
        destVC.messageTitle = "Goals Status Report"
        present(destVC, animated: true, completion: nil)
    }
    
    @objc func goBack() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension GoalStatusReportVC: SwiftDataTableDataSource {
    public func dataTable(_ dataTable: SwiftDataTable, headerTitleForColumnAt columnIndex: NSInteger) -> String {
        return self.headerTitles[columnIndex]
    }
    
    public func numberOfColumns(in: SwiftDataTable) -> Int {
        return 14
    }
    
    func numberOfRows(in: SwiftDataTable) -> Int {
        return self.dataSource.count
    }
    
    public func dataTable(_ dataTable: SwiftDataTable, dataForRowAt index: NSInteger) -> [DataTableValueType] {
        return self.dataSource[index]
    }
    
    public func dataTable(_ dataTable: SwiftDataTable, highlightedColorForRowIndex at: Int) -> UIColor {
        print("Got inside highlight")
        return UIColor.red
    }
}


extension GoalStatusReportVC: SwiftDataTableDelegate {
    @objc func fixedColumns(for dataTable: SwiftDataTable) -> DataTableFixedColumnType {
        // and return the object here
        return .init(leftColumns: 1) // freeze the first two columns
    }
}
