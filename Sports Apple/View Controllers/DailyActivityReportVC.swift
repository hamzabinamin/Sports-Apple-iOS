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
import PDFGenerator
import CSV

class DailyActivityReportVC: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var exportButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    var hud: JGProgressHUD?
    var dataTable: SwiftDataTable! = nil
    var array: [Activity] = []
    var dataSource: DataTableContent = []
    var dataRows: [DataTableRow] = []
    var stringArray: [[String]] = []
    var pool: AWSCognitoIdentityUserPool?
    var date1 = Date()
    var date2 = Date()
    let formatter = DateFormatter()
    var session: Activity = Activity()
    let numberFormatter: NumberFormatter = NumberFormatter()
    let numFormatter: NumberFormatter = NumberFormatter()
    var oneDate = false
    var totalCalories: Float = 0
    var totalWeight: Float = 0
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
        numFormatter.locale = Locale(identifier:"en_US")
        numFormatter.maximumFractionDigits = 1
        
        let topConstraint = self.dataTable.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 250)
        let bottomConstraint = self.dataTable.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        let leadingConstraint = self.dataTable.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
        let trailingConstraint = self.dataTable.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        self.view.addSubview(self.dataTable)
        
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        calendarButton.addTarget(self, action: #selector(goToCalendarVC), for: .touchUpInside)
        exportButton.addTarget(self, action: #selector(createPDF), for: .touchUpInside)
        
        NSLayoutConstraint.activate([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
    }
    
    func getSessions(date1: Date, date2: Date) {
        self.totalCalories = 0
        self.totalWeight = 0
        self.dataRows = []
        self.stringArray = []
        
        //formatter.dateFormat = "MM/dd/yyyy"
        formatter.dateFormat = "yyyy-MM-dd"
        
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
                    
                    //self.formatter.dateFormat = "MM/dd/yyyy h:mm a"
                    self.formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    
                    self.array.sort(by: { self.formatter.date(from: $0._date!)?.compare(self.formatter.date(from: ($1._date)!)!) == .orderedAscending})
                    for item in self.array {
                        self.totalCalories += (item._calories?.floatValue)!
                        for activity in item._exerciseList! {
                            
                            //self.formatter.dateFormat = "MM/dd/yyyy h:mm a"
                            self.formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                            
                            var row: DataTableRow = [DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""),
                                DataTableValueType.string("")]
                            var stringRow = ["", "", "", "", "", "", "", ""]
                            
                            let dateStore = self.formatter.date(from: item._date!)
                            
                            //self.formatter.dateFormat = "MM/dd/yyyy"
                            self.formatter.dateFormat = "yyyy-MM-dd"
                            
                            row[0] = DataTableValueType.string(self.formatter.string(from: dateStore!))
                            stringRow[0] = self.formatter.string(from: dateStore!)
                            
                            row[1] = DataTableValueType.string(activity["exerciseName"] as! String)
                            stringRow[1] = activity["exerciseName"] as! String
                            
                            if activity["Weight Amount"] != nil {
                                let weightStore = Float(activity["Weight Amount"] as! String)!
                                let repsStore = Int(activity["Reps"] as! String)!
                                let setsStore = Int(activity["Sets"] as! String)!
                                self.totalWeight += weightStore

                                row[2] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: weightStore))!)
                                stringRow[2] = self.numFormatter.string(from: NSNumber(value: weightStore))!
                                
                                row[3] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: repsStore))!)
                                stringRow[3] = self.numFormatter.string(from: NSNumber(value: repsStore))!
                                
                                row[4] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: setsStore))!)
                                stringRow[4] = self.numFormatter.string(from: NSNumber(value: setsStore))!
                            }
                            else if activity["Time"] != nil {
                                let timeStore = activity["Time"] as! Int
                                let hours = (timeStore) / 3600
                                let minutes = ((timeStore) / 60) % 60
                                row[7] = DataTableValueType.string(String(format: "%02d:%02d", hours, minutes))
                                stringRow[7] = String(format: "%02d:%02d", hours, minutes)
                            }
                            else if activity["Count"] != nil {
                                let countStore = Float(activity["Count"] as! String)!
                                 row[5] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: countStore))!)
                                stringRow[5] = self.numFormatter.string(from: NSNumber(value: countStore))!
                            }
                            else if activity["Distance"] != nil {
                                let distanceStore = Int(activity["Distance"] as! String)!
                                row[6] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: distanceStore))!)
                                stringRow[6] = self.numFormatter.string(from: NSNumber(value: distanceStore))!
                            }
                            self.dataRows.append(row)
                            self.stringArray.append(stringRow)
                        }
                    }
                    self.addDataSourceAfter()
                    self.caloriesLabel.text = "Calories: " + "\(self.totalCalories)"
                    self.weightLabel.text = "Weight: " + "\(self.totalWeight)" + " lbs"
                }
            }
            else if response == "no result" {
                DispatchQueue.main.async {
                    self.dataRows.removeAll()
                    let row: DataTableRow = [DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""),
                                             DataTableValueType.string("")]
                    let stringRow = ["", "", "", "", "", "", "", ""]
                    
                    self.dataRows.append(row)
                    self.stringArray.append(stringRow)
                    self.addDataSourceAfter()
                    self.caloriesLabel.text = "Calories: " + "\(0)"
                    self.weightLabel.text = "Weight: " + "\(0)" + " lbs"
                }
            }
            else {
                print("Response: " + response)
            }
        }
    }
    
    func getSessions(date1: Date) {
        self.totalCalories = 0
        self.totalWeight = 0
        self.dataRows = []
        self.stringArray = []
        
        //formatter.dateFormat = "MM/dd/yyyy"
        formatter.dateFormat = "yyyy-MM-dd"
        
        self.showHUD(hud: hud!)
        session.queryActivity(userId: (pool?.currentUser()?.username)!, date: formatter.string(from: date1)) { (response, responseArray) in
            
            DispatchQueue.main.async {
                self.hideHUD(hud: self.hud!)
            }
            print("Response: " + response)
            if response == "success" {
                DispatchQueue.main.async {
                    self.array = responseArray
                    
                    //self.formatter.dateFormat = "MM/dd/yyyy h:mm a"
                    self.formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    
                    self.array.sort(by: { self.formatter.date(from: $0._date!)?.compare(self.formatter.date(from: ($1._date)!)!) == .orderedAscending})
                    for item in self.array {
                        self.totalCalories += (item._calories?.floatValue)!
                        for activity in item._exerciseList! {
                            //self.formatter.dateFormat = "MM/dd/yyyy h:mm a"
                            self.formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                            
                            var row: DataTableRow = [DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""),
                                                     DataTableValueType.string("")]
                            var stringRow = ["", "", "", "", "", "", "", ""]
                            let dateStore = self.formatter.date(from: item._date!)
                            
                            //self.formatter.dateFormat = "MM/dd/yyyy"
                            self.formatter.dateFormat = "yyyy-MM-dd"
                            
                            row[0] = DataTableValueType.string(self.formatter.string(from: dateStore!))
                            stringRow[0] = self.formatter.string(from: dateStore!)
                            
                            row[1] = DataTableValueType.string(activity["exerciseName"] as! String)
                            stringRow[1] = activity["exerciseName"] as! String
                            
                            if activity["Weight Amount"] != nil {
                                let weightStore = Float(activity["Weight Amount"] as! String)!
                                let repsStore = Int(activity["Reps"] as! String)!
                                let setsStore = Int(activity["Sets"] as! String)!
                                self.totalWeight += weightStore
                                
                                row[2] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: weightStore))!)
                                stringRow[2] = self.numFormatter.string(from: NSNumber(value: weightStore))!
                                
                                row[3] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: repsStore))!)
                                stringRow[3] = self.numFormatter.string(from: NSNumber(value: repsStore))!
                                
                                row[4] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: setsStore))!)
                                stringRow[4] = self.numFormatter.string(from: NSNumber(value: setsStore))!
                            }
                            else if activity["Time"] != nil {
                                let timeStore = activity["Time"] as! Int
                                let hours = (timeStore) / 3600
                                let minutes = ((timeStore) / 60) % 60
                                row[7] = DataTableValueType.string(String(format: "%02d:%02d", hours, minutes))
                                stringRow[7] = String(format: "%02d:%02d", hours, minutes)
                            }
                            else if activity["Count"] != nil {
                                let countStore = Float(activity["Count"] as! String)!
                                row[5] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: countStore))!)
                                stringRow[5] = self.numFormatter.string(from: NSNumber(value: countStore))!
                            }
                            else if activity["Distance"] != nil {
                                let distanceStore = Int(activity["Distance"] as! String)!
                                row[6] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: distanceStore))!)
                                stringRow[6] = self.numFormatter.string(from: NSNumber(value: distanceStore))!
                            }
                            self.dataRows.append(row)
                            self.stringArray.append(stringRow)
                        }
                    }
                   self.addDataSourceAfter()
                   self.caloriesLabel.text = "Calories: " + "\(self.totalCalories)"
                   self.weightLabel.text = "Weight: " + "\(self.totalWeight)" + " lbs"
                }
            }
            else if response == "no result" {
                DispatchQueue.main.async {
                   self.dataRows.removeAll()
                   let row: DataTableRow = [DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""),
                                             DataTableValueType.string("")]
                   let stringRow = ["", "", "", "", "", "", "", ""]
                   self.dataRows.append(row)
                   self.stringArray.append(stringRow)
                   self.addDataSourceAfter()
                   self.caloriesLabel.text = "Calories: " + "\(0)"
                   self.weightLabel.text = "Weight: " + "\(0)" + " lbs"
                }
            }
            else {
                print("Response: " + response)
            }
        }
    }
    
    func getSessions() {
        self.dataRows = []
        self.stringArray = []
        //formatter.dateFormat = "MM/dd/yyyy"
        formatter.dateFormat = "yyyy-MM-dd"
        self.showHUD(hud: hud!)
        session.queryActivity(userId: (pool?.currentUser()?.username)!) { (response, responseArray) in
            
            DispatchQueue.main.async {
                self.hideHUD(hud: self.hud!)
            }
            print("Response: " + response)
            if response == "success" {
                DispatchQueue.main.async {
                    self.array = responseArray
                    //self.formatter.dateFormat = "MM/dd/yyyy h:mm a"
                    self.formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    self.array.sort(by: { self.formatter.date(from: $0._date!)?.compare(self.formatter.date(from: ($1._date)!)!) == .orderedDescending})
                    var storeItem = Activity()
                    storeItem?._date = self.array.first?._date
                    let labelDate = self.formatter.date(from: (storeItem?._date)!)
                    self.formatter.dateFormat = "MMM d, yyyy"
                    let storeDateString = self.formatter.string(from: labelDate!)
                    self.dateLabel.text = storeDateString
                    let storeDateStore = self.formatter.date(from: storeDateString)
                    let storeFormatter = DateFormatter()
                    storeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                    let finalStringStore = storeFormatter.string(from: storeDateStore!)
                    self.date1 = storeFormatter.date(from: finalStringStore)!
                    self.date2 = storeFormatter.date(from: finalStringStore)!
                    for item in self.array {
                        //self.formatter.dateFormat = "MM/dd/yyyy h:mm a"
                        
                        self.formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                        let d1 = self.formatter.date(from: (storeItem?._date!)!)
                        let d2 = self.formatter.date(from: (item._date!))
                        
                        //self.formatter.dateFormat = "MM/dd/yyyy"
                        self.formatter.dateFormat = "yyyy-MM-dd"
                        
                        let ds1 = self.formatter.string(from: d1!)
                        let ds2 = self.formatter.string(from: d2!)
                        if self.formatter.date(from: (ds1)) == self.formatter.date(from: ds2) {
                            storeItem = item
                        self.totalCalories += (item._calories?.floatValue)!
                        for activity in item._exerciseList! {
                            
                            //self.formatter.dateFormat = "MM/dd/yyyy h:mm a"
                            self.formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                            
                            var row: DataTableRow = [DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""),
                                                     DataTableValueType.string("")]
                            var stringRow = ["", "", "", "", "", "", "", ""]
                            let dateStore = self.formatter.date(from: item._date!)
                            
                            //self.formatter.dateFormat = "MM/dd/yyyy"
                            self.formatter.dateFormat = "yyyy-MM-dd"
                            
                            row[0] = DataTableValueType.string(self.formatter.string(from: dateStore!))
                            stringRow[0] = self.formatter.string(from: dateStore!)
                            
                            row[1] = DataTableValueType.string(activity["exerciseName"] as! String)
                            stringRow[1] = activity["exerciseName"] as! String
                            
                            if activity["Weight Amount"] != nil {
                                let weightStore = Float(activity["Weight Amount"] as! String)!
                                let repsStore = Int(activity["Reps"] as! String)!
                                let setsStore = Int(activity["Sets"] as! String)!
                                self.totalWeight += weightStore
                                
                                row[2] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: weightStore))!)
                                stringRow[2] = self.numFormatter.string(from: NSNumber(value: weightStore))!
                                
                                row[3] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: repsStore))!)
                                stringRow[3] = self.numFormatter.string(from: NSNumber(value: repsStore))!
                                
                                row[4] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: setsStore))!)
                                stringRow[4] = self.numFormatter.string(from: NSNumber(value: setsStore))!
                                
                            }
                            else if activity["Time"] != nil {
                                let timeStore = activity["Time"] as! Int
                                let hours = (timeStore) / 3600
                                let minutes = ((timeStore) / 60) % 60
                                row[7] = DataTableValueType.string(String(format: "%02d:%02d", hours, minutes))
                                stringRow[7] = String(format: "%02d:%02d", hours, minutes)
                            }
                            else if activity["Count"] != nil {
                                let countStore = Float(activity["Count"] as! String)!
                                row[5] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: countStore))!)
                                stringRow[5] = self.numFormatter.string(from: NSNumber(value: countStore))!
                            }
                            else if activity["Distance"] != nil {
                                let distanceStore = Int(activity["Distance"] as! String)!
                                row[6] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: distanceStore))!)
                                stringRow[6] = self.numFormatter.string(from: NSNumber(value: distanceStore))!
                            }
                            self.dataRows.append(row)
                            self.stringArray.append(stringRow)
                        }
                    }
                }
                    self.addDataSourceAfter()
                    self.caloriesLabel.text = "Calories: " + "\(self.totalCalories)"
                    self.weightLabel.text = "Weight: " + "\(self.totalWeight)" + " lbs"
                }
            }
            else if response == "no result" {
                DispatchQueue.main.async {
                    self.dataRows.removeAll()
                    let row: DataTableRow = [DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""),
                                             DataTableValueType.string("")]
                    let stringRow = ["", "", "", "", "", "", "", ""]
                    self.dataRows.append(row)
                    self.stringArray.append(stringRow)
                    self.addDataSourceAfter()
                    self.caloriesLabel.text = "Calories: " + "\(0)"
                    self.weightLabel.text = "Weight: " + "\(0)" + " lbs"
                    self.oneDate = true
                }
            }
            else {
                print("Response: " + response)
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
        let dst = URL(fileURLWithPath: NSTemporaryDirectory().appending("Daily Activity Report.pdf"))
        do {
            try PDFGenerator.generate([v], to: dst)
            openPDFViewer(dst)
        } catch (let error) {
            print(error)
        } */
        
        let fileName = "Daily Activity Report.csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        let stream = OutputStream(toFileAtPath: (path?.path)!, append: false)!
        let csv = try! CSVWriter(stream: stream)
        
        try! csv.write(row: ["Date", "Exercise", "Weight", "Reps", "Sets", "Count", "Distance", "Time"])
        
        for row in stringArray {
            try! csv.write(row: [row[0], row[1], row[2], row[3], row[4], row[5], row[6], row[7]])
        }
        
        csv.stream.close()
        openPDFViewer(path!)
    }
    
    fileprivate func openPDFViewer(_ pdfPath: URL) {
        //let url = URL(fileURLWithPath: pdfPath)
        let storyboard = UIStoryboard(name: "PDFPreviewVC", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "PDFPreviewVC") as! PDFPreviewVC
        destVC.setupWithURL(pdfPath)
        destVC.messageTitle = "Daily Activity Report"
        present(destVC, animated: true, completion: nil)
    }
    
    @objc func confirmDate(notification: Notification) {
        print("Inside DailyActivityReportVC")
        if let date = notification.object as? [Date] {
             print("Inside if")
            formatter.dateFormat = "MMM d, yyyy"
            
            if date.count == 1 {
                self.date1 = date.first!
                self.oneDate = true
                dateLabel.text = formatter.string(from: date.first!)
                getSessions(date1: date1)
            }
            else {
                self.date1 = date.first!
                self.date2 = date[1]
                self.oneDate = false
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
        destVC.oneDate = self.oneDate
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

extension DailyActivityReportVC: SwiftDataTableDelegate {
   @objc func dataTable(_ dataTable: SwiftDataTable, widthForColumnAt index: Int) -> CGFloat {
        return 150.0
    }
}
