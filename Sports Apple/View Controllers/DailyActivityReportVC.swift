//
//  DailyActivityReportVC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 6/10/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit
import SwiftDataTables
import JGProgressHUD
import AWSCognitoIdentityProvider

class DailyActivityReportVC: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    var hud: JGProgressHUD?
    var dataTable: SwiftDataTable! = nil
    var array: [Activity] = []
    var dataSource: DataTableContent = []
    var dataRows: [DataTableRow] = []
    var pool: AWSCognitoIdentityUserPool?
    var date1 = Date()
    var date2 = Date()
    let formatter = DateFormatter()
    var session: Activity = Activity()
    let numberFormatter: NumberFormatter = NumberFormatter()
    
    let headerTitles = ["Date", "Exercise", "Weight", "Reps", "Sets", "Count", "Distance", "Time"]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        getSessions()
       // self.addDataSourceAfter()
        
        NotificationCenter.default.addObserver(self, selector: #selector(confirmDate(notification:)), name: .confirmDateRange, object: nil)
        
    }
    
    func setupViews() {
        hud = self.createLoadingHUD()
        formatter.dateFormat = "MMM d, yyyy"
        formatter.locale = Locale(identifier:"en_US_POSIX")
        dateLabel.text = formatter.string(from: date1)
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = UIColor.white
        self.dataTable = SwiftDataTable(dataSource: self)
        self.dataTable.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.dataTable.translatesAutoresizingMaskIntoConstraints = false
        self.numberFormatter.locale = Locale(identifier:"en_US")
        self.numberFormatter.numberStyle = NumberFormatter.Style.decimal
        
        let topConstraint = self.dataTable.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 171)
        let bottomConstraint = self.dataTable.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        let leadingConstraint = self.dataTable.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
        let trailingConstraint = self.dataTable.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        self.view.addSubview(self.dataTable)
        
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        calendarButton.addTarget(self, action: #selector(goToCalendarVC), for: .touchUpInside)
        
        NSLayoutConstraint.activate([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
    }
    
    func getSessions(date1: Date, date2: Date) {
        self.dataRows = []
        formatter.dateFormat = "MM/dd/yyyy"
        let date2New = Calendar.current.date(byAdding: .day, value: 1, to: date2)
        self.showHUD(hud: hud!)
        session.queryActivityInRange(userId: (pool?.currentUser()?.username)!, date1: formatter.string(from: date1), date2: formatter.string(from: date2New!)) { (response, responseArray) in
            
            DispatchQueue.main.async {
                self.hideHUD(hud: self.hud!)
            }
            print("Response: " + response)
            if response == "success" {
                DispatchQueue.main.async {
                    self.array = responseArray
                    self.formatter.dateFormat = "MM/dd/yyyy h:mm a"
                    self.array.sort(by: { self.formatter.date(from: $0._date!)?.compare(self.formatter.date(from: ($1._date)!)!) == .orderedAscending}) 
                    for item in self.array {
                        for activity in item._exerciseList! {
                             self.formatter.dateFormat = "MM/dd/yyyy h:mm a"
                            var row: DataTableRow = [DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""),
                                DataTableValueType.string("")]
                            let dateStore = self.formatter.date(from: item._date!)
                            self.formatter.dateFormat = "MM/dd/yyyy"
                            row[0] = DataTableValueType.string(self.formatter.string(from: dateStore!))
                            row[1] = DataTableValueType.string(activity["exerciseName"] as! String)
                            
                            if activity["Weight Amount"] != nil {
                                let weightStore = Int(activity["Weight Amount"] as! String)!
                                let repsStore = Int(activity["Reps"] as! String)!
                                let setsStore = Int(activity["Sets"] as! String)!

                                row[2] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: weightStore))!)
                                row[3] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: repsStore))!)
                                row[4] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: setsStore))!)
                                
                            }
                            else if activity["Time"] != nil {
                                let timeStore = activity["Time"] as! Int
                                let hours = (timeStore) / 3600
                                let minutes = ((timeStore) / 60) % 60
                                row[7] = DataTableValueType.string(String(format: "%02d:%02d", hours, minutes))
                            }
                            else if activity["Count"] != nil {
                                let countStore = Int(activity["Count"] as! String)!
                                 row[5] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: countStore))!)
                            }
                            else if activity["Distance"] != nil {
                                let distanceStore = Int(activity["Distance"] as! String)!
                                row[6] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: distanceStore))!)
                            }
                            self.dataRows.append(row)
                        }
                    }
                    self.addDataSourceAfter()
                }
            }
            else if response == "no result" {
                DispatchQueue.main.async {
                    
                }
            }
            else {
                print("Response: " + response)
            }
        }
    }
    
    func getSessions(date1: Date) {
        self.dataRows = []
        formatter.dateFormat = "MM/dd/yyyy"
        self.showHUD(hud: hud!)
        session.queryActivity(userId: (pool?.currentUser()?.username)!, date: formatter.string(from: date1)) { (response, responseArray) in
            
            DispatchQueue.main.async {
                self.hideHUD(hud: self.hud!)
            }
            print("Response: " + response)
            if response == "success" {
                DispatchQueue.main.async {
                    self.array = responseArray
                    self.formatter.dateFormat = "MM/dd/yyyy h:mm a"
                    self.array.sort(by: { self.formatter.date(from: $0._date!)?.compare(self.formatter.date(from: ($1._date)!)!) == .orderedAscending})
                    for item in self.array {
                        for activity in item._exerciseList! {
                             self.formatter.dateFormat = "MM/dd/yyyy h:mm a"
                            var row: DataTableRow = [DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""),
                                                     DataTableValueType.string("")]
                            let dateStore = self.formatter.date(from: item._date!)
                            self.formatter.dateFormat = "MM/dd/yyyy"
                            row[0] = DataTableValueType.string(self.formatter.string(from: dateStore!))
                            row[1] = DataTableValueType.string(activity["exerciseName"] as! String)
                            
                            if activity["Weight Amount"] != nil {
                                let weightStore = Int(activity["Weight Amount"] as! String)!
                                let repsStore = Int(activity["Reps"] as! String)!
                                let setsStore = Int(activity["Sets"] as! String)!
                                
                                row[2] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: weightStore))!)
                                row[3] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: repsStore))!)
                                row[4] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: setsStore))!)
                                
                            }
                            else if activity["Time"] != nil {
                                let timeStore = activity["Time"] as! Int
                                let hours = (timeStore) / 3600
                                let minutes = ((timeStore) / 60) % 60
                                row[7] = DataTableValueType.string(String(format: "%02d:%02d", hours, minutes))
                            }
                            else if activity["Count"] != nil {
                                let countStore = Int(activity["Count"] as! String)!
                                row[5] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: countStore))!)
                            }
                            else if activity["Distance"] != nil {
                                let distanceStore = Int(activity["Distance"] as! String)!
                                row[6] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: distanceStore))!)
                            }
                            self.dataRows.append(row)
                        }
                    }
                   self.addDataSourceAfter()
                }
            }
            else if response == "no result" {
                DispatchQueue.main.async {
                   
                }
            }
            else {
                print("Response: " + response)
            }
        }
    }
    
    func getSessions() {
        self.dataRows = []
        formatter.dateFormat = "MM/dd/yyyy"
        self.showHUD(hud: hud!)
        session.queryActivity(userId: (pool?.currentUser()?.username)!) { (response, responseArray) in
            
            DispatchQueue.main.async {
                self.hideHUD(hud: self.hud!)
            }
            print("Response: " + response)
            if response == "success" {
                DispatchQueue.main.async {
                    self.array = responseArray
                    self.formatter.dateFormat = "MM/dd/yyyy h:mm a"
                    self.array.sort(by: { self.formatter.date(from: $0._date!)?.compare(self.formatter.date(from: ($1._date)!)!) == .orderedDescending})
                    var storeItem = Activity()
                    storeItem?._date = self.array.first?._date
                    let labelDate = self.formatter.date(from: (storeItem?._date)!)
                    self.formatter.dateFormat = "MMM d, yyyy"
                    self.dateLabel.text = self.formatter.string(from: labelDate!)
                    for item in self.array {
                        self.formatter.dateFormat = "MM/dd/yyyy h:mm a"
                        let d1 = self.formatter.date(from: (storeItem?._date!)!)
                        let d2 = self.formatter.date(from: (item._date!))
                        self.formatter.dateFormat = "MM/dd/yyyy"
                        let ds1 = self.formatter.string(from: d1!)
                        let ds2 = self.formatter.string(from: d2!)
                        if self.formatter.date(from: (ds1)) == self.formatter.date(from: ds2) {
                            storeItem = item
                            
                        for activity in item._exerciseList! {
                            self.formatter.dateFormat = "MM/dd/yyyy h:mm a"
                            var row: DataTableRow = [DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""),
                                                     DataTableValueType.string("")]
                            let dateStore = self.formatter.date(from: item._date!)
                            self.formatter.dateFormat = "MM/dd/yyyy"
                            row[0] = DataTableValueType.string(self.formatter.string(from: dateStore!))
                            row[1] = DataTableValueType.string(activity["exerciseName"] as! String)
                            
                            if activity["Weight Amount"] != nil {
                                let weightStore = Int(activity["Weight Amount"] as! String)!
                                let repsStore = Int(activity["Reps"] as! String)!
                                let setsStore = Int(activity["Sets"] as! String)!
                                
                                row[2] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: weightStore))!)
                                row[3] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: repsStore))!)
                                row[4] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: setsStore))!)
                                
                            }
                            else if activity["Time"] != nil {
                                let timeStore = activity["Time"] as! Int
                                let hours = (timeStore) / 3600
                                let minutes = ((timeStore) / 60) % 60
                                row[7] = DataTableValueType.string(String(format: "%02d:%02d", hours, minutes))
                            }
                            else if activity["Count"] != nil {
                                let countStore = Int(activity["Count"] as! String)!
                                row[5] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: countStore))!)
                            }
                            else if activity["Distance"] != nil {
                                let distanceStore = Int(activity["Distance"] as! String)!
                                row[6] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: distanceStore))!)
                            }
                            self.dataRows.append(row)
                        }
                    }
                }
                    self.addDataSourceAfter()
                }
            }
            else if response == "no result" {
                DispatchQueue.main.async {
                    
                }
            }
            else {
                print("Response: " + response)
            }
        }
    }
    
    public func addDataSourceAfter(){
        self.dataSource = self.dataRows
        self.dataTable.reload()
    }
    
    @objc func confirmDate(notification: Notification) {
        print("Inside DailyActivityReportVC")
        if let date = notification.object as? [Date] {
             print("Inside if")
            formatter.dateFormat = "MMM d, yyyy"
            
            if date.count == 1 {
                self.date1 = date.first!
                dateLabel.text = formatter.string(from: date.first!)
                getSessions(date1: date1)
            }
            else {
                self.date1 = date.first!
                self.date2 = date[1]
                dateLabel.text = formatter.string(from: date.first!) + "-" + formatter.string(from: date[1])
                getSessions(date1: date1, date2: date2)
            }
        }
    }
    
    @objc func goBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func goToCalendarVC() {
        let storyboard = UIStoryboard(name: "AddSession", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "CalendarVC") as! CalendarVC
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        destVC.date = date1
        destVC.date2 = date2
        destVC.dateRange = true
        self.present(destVC, animated: true, completion: .none)
    }
}

extension DailyActivityReportVC: SwiftDataTableDataSource {
    public func dataTable(_ dataTable: SwiftDataTable, headerTitleForColumnAt columnIndex: NSInteger) -> String {
        return self.headerTitles[columnIndex]
    }
    
    public func numberOfColumns(in: SwiftDataTable) -> Int {
        return 8
    }
    
    func numberOfRows(in: SwiftDataTable) -> Int {
        return self.dataSource.count
    }
    
    public func dataTable(_ dataTable: SwiftDataTable, dataForRowAt index: NSInteger) -> [DataTableValueType] {
        return self.dataSource[index]
    }
}
