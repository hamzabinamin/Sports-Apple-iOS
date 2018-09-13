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

class GoalStatusReportVC: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var exportButton: UIButton!
    var dataTable: SwiftDataTable! = nil
    var dataTableConfig: DataTableConfiguration?
    var dataSource: DataTableContent = []
    var dataRows: [DataTableRow] = []
    var array: [Activity] = []
    var goalArray: [Goal] = []
    var hud: JGProgressHUD?
    var pool: AWSCognitoIdentityUserPool?
    var session: Activity = Activity()
    var goal: Goal = Goal()
    var set: Set<ExerciseItem> = []
    let formatter = DateFormatter()
    let numberFormatter: NumberFormatter = NumberFormatter()
    var daysWorkedOut = 0
    var daysInYear = 365
    var daysPastInYear = 0
    var daysLeftInYear = 0
    var weeks = 0
    
    let headerTitles = ["Activity", "Cumulative Goal", "Year-to-Date", "Weight Goal", "Max Weight",
                        "Distance Goal", "Total Distance", "Time Goal", "Max Time", "To Meet Goal",
                        "Pct%", "To Do Per Day", "Projected"]

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
        self.formatter.dateFormat = "MM/dd/yyyy h:mm a"
        self.formatter.locale = Locale(identifier:"en_US_POSIX")
        self.numberFormatter.locale = Locale(identifier:"en_US")
        self.numberFormatter.numberStyle = NumberFormatter.Style.decimal
        
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
                    
                    for item in self.array {
                        for activity in item._exerciseList! {
                            let exerciseItem = ExerciseItem()
                            exerciseItem.exerciseID = activity["exerciseID"] as! String
                            exerciseItem.exerciseName = activity["exerciseName"] as! String
                            
                            if !self.set.contains(exerciseItem) {
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
                                let storedExerciseItem = self.set.first(where: {$0.exerciseID == exerciseItem.exerciseID})
                                self.set.remove(storedExerciseItem!)
                                if activity["Weight Amount"] != nil {
                                    
                                    if (storedExerciseItem?.exerciseWeightAmount)! < Int(activity["Weight Amount"] as! String)! {
                                        storedExerciseItem?.exerciseWeightAmount = Int(activity["Weight Amount"] as! String)!
                                        storedExerciseItem?.exerciseSets = Int(activity["Sets"] as! String)!
                                        storedExerciseItem?.exerciseReps = Int(activity["Reps"] as! String)!
                                    }
                                }
                                else if activity["Time"] != nil {
                                    storedExerciseItem?.exerciseTime += activity["Time"] as! Int
                                }
                                else if activity["Count"] != nil {
                                    storedExerciseItem?.exerciseCount += Int(activity["Count"] as! String)!
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
                                                 DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string("")]
                        
                        row[0] = DataTableValueType.string(item.exerciseName)
                        
                        if item.goalWeight != 0 || item.exerciseWeightAmount != 0 {
                            row[3] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: item.goalWeight))!)
                            row[4] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: item.exerciseWeightAmount))!)
                            row[9] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: (item.goalWeight - item.exerciseWeightAmount)))!)
                            let percentage = ((Float(item.exerciseWeightAmount) / Float(item.goalWeight)) * 100)
                            row[10] = DataTableValueType.string("\(percentage.rounded(.toNearestOrAwayFromZero))" + "%")
                            var projected = Float(0)
                            if ((Float(item.exerciseWeightAmount) / Float(self.daysPastInYear)) * Float(self.daysLeftInYear)) + Float(item.exerciseWeightAmount) < 0 {
                                projected = (((Float(item.exerciseWeightAmount) / Float(self.daysPastInYear)) * Float(self.daysLeftInYear)) + Float(item.exerciseWeightAmount)) * -1.0
                            }
                            else {
                                projected = (((Float(item.exerciseWeightAmount) / Float(self.daysPastInYear)) * Float(self.daysLeftInYear)) + Float(item.exerciseWeightAmount)) + Float(item.exerciseWeightAmount)
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
                            row[8] = DataTableValueType.string(String(format: "%02d:%02d", hoursTotal, minutesTotal))
                            row[9] = DataTableValueType.string(String(format: "%02d:%02d", hoursDiff, minutesDiff))
                            let percentage = ((Float(item.exerciseTime) / Float(item.goalTime)) * 100)
                            row[10] = DataTableValueType.string("\(percentage.rounded(.toNearestOrAwayFromZero))" + "%")
                        }
                        if item.goalDistance != 0 || item.exerciseDistance != 0 {
                            row[5] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: item.goalDistance))!)
                            row[6] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: item.exerciseDistance))!)
                            row[9] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: (item.goalDistance - item.exerciseDistance)))!)
                            let percentage = ((Float(item.exerciseDistance) / Float(item.goalDistance)) * 100)
                            row[10] = DataTableValueType.string("\(percentage.rounded(.toNearestOrAwayFromZero))" + "%")
                            var projected = Float(0)
                            if ((Float(item.exerciseDistance) / Float(self.daysPastInYear)) * Float(self.daysLeftInYear)) + Float(item.exerciseDistance) < 0 {
                                projected = (((Float(item.exerciseDistance) / Float(self.daysPastInYear)) * Float(self.daysLeftInYear)) + Float(item.exerciseDistance)) * -1.0
                            }
                            else {
                                projected = (((Float(item.exerciseDistance) / Float(self.daysPastInYear)) * Float(self.daysLeftInYear)) + Float(item.exerciseDistance)) + Float(item.exerciseDistance)
                            }
                            row[12] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: projected.rounded(.toNearestOrAwayFromZero)))!)
                            
                            
                        }
                        if item.goalCount != 0 || item.exerciseCount != 0 {
                            row[1] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: item.goalCount))!)
                            row[2] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: item.exerciseCount))!)
                            let meetGoal = (item.goalCount - item.exerciseCount)
                            row[9] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: meetGoal))!)
                            let percentage = ((Float(item.exerciseCount) / Float(item.goalCount)) * 100)
                            row[10] = DataTableValueType.string("\(percentage.rounded(.toNearestOrAwayFromZero))" + "%")
                            //row[11] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: (Float(meetGoal) / Float(self.daysLeftInYear)).rounded(.toNearestOrAwayFromZero)))!)
                            let perDay = (Float(meetGoal) / Float(self.daysLeftInYear))
                            let perDayString = String(format: "%.01f", perDay)
                            row[11] = DataTableValueType.string(perDayString)
                            var projected = Float(0)
                            if ((Float(item.exerciseCount) / Float(self.daysPastInYear)) * Float(self.daysLeftInYear)) + Float(item.exerciseCount) < 0 {
                                projected = (((Float(item.exerciseCount) / Float(self.daysPastInYear)) * Float(self.daysLeftInYear)) + Float(item.exerciseCount)) * -1.0
                            }
                            else {
                                projected = (((Float(item.exerciseCount) / Float(self.daysPastInYear)) * Float(self.daysLeftInYear)) + Float(item.exerciseCount)) + Float(item.exerciseCount)
                            }
                            row[12] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: projected.rounded(.toNearestOrAwayFromZero)))!)
                        }
                        self.dataRows.append(row)
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
                                             DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string("")]
                    self.dataRows.append(row)
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
                self.hideHUD(hud: self.hud!)
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
                    self.dataRows.removeAll()
                    let row: DataTableRow = [DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""),
                                             DataTableValueType.string(""), DataTableValueType.string(""),
                                             DataTableValueType.string(""), DataTableValueType.string(""),
                                             DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string("")]
                    self.dataRows.append(row)
                    self.addDataSourceAfter()
                }
            }
        }
    }
    
    public func addDataSourceAfter(){
        self.dataSource = self.dataRows
        self.dataTable.reload()
    }
    
    @objc func createPDF() {
        let v = dataTable.collectionView
        let dst = URL(fileURLWithPath: NSTemporaryDirectory().appending("Goal Status Report.pdf"))
        //let dst2 = NSHomeDirectory() + "/\("Summary Report").pdf"
        // outputs as Data
        /*  do {
         let data = try PDFGenerator.generated(by: [v])
         try data.write(to: dst, options: .atomic)
         } catch (let error) {
         print(error)
         } */
        
        // writes to Disk directly.
        do {
            try PDFGenerator.generate([v], to: dst)
            openPDFViewer(dst)
        } catch (let error) {
            print(error)
        }
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
        return 13
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
