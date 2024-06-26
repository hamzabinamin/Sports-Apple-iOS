//
//  YearsTotalReportVC.swift
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

class YearTotalsReportVC: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var exportButton: UIButton!
    var dataTable: SwiftDataTable! = nil
    var dataSource: DataTableContent = []
    var dataRows: [DataTableRow] = []
    var hud: JGProgressHUD?
    var array: [Activity] = []
    var stringArray: [[String]] = []
    var set: Set<ExerciseItem> = []
    var pool: AWSCognitoIdentityUserPool?
    var session: Activity = Activity()
    let numberFormatter: NumberFormatter = NumberFormatter()
    let numFormatter = NumberFormatter()
    var weightTotal: Int = 0
    var timeTotal: Int = 0
    var distanceTotal: Int = 0
    var countTotal: Int = 0
    
    let headerTitles = ["Activity", "Weight", "Time", "Distance", "Count"]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        getSessions()
        //self.addDataSourceAfter()
    }
    
    func setupViews() {
        hud = self.createLoadingHUD()
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = UIColor.white
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
        self.dataTable = SwiftDataTable(dataSource: self)
        self.dataTable.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.dataTable.translatesAutoresizingMaskIntoConstraints = false
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
        self.showHUD(hud: hud!)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        formatter.locale = Locale(identifier:"en_US_POSIX")
        let date = formatter.string(from: Date())
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
                            
                            if !self.set.contains(where: {($0.exerciseID == exerciseItem.exerciseID || $0.exerciseName == exerciseItem.exerciseName)}) {
                                print("Wasn't present")
                                print(exerciseItem.exerciseID)
                                print(exerciseItem.exerciseName)
                                if activity["Weight Amount"] != nil {
                                    exerciseItem.exerciseWeightAmount = Float(activity["Weight Amount"] as! String)!
                                    exerciseItem.exerciseSets = Int(activity["Sets"] as! String)!
                                    exerciseItem.exerciseReps = Int(activity["Reps"] as! String)!
                                }
                                else if activity["Time"] != nil {
                                    exerciseItem.exerciseTime = activity["Time"] as! Int
                                }
                                else if activity["Count"] != nil {
                                    exerciseItem.exerciseCount = Float(activity["Count"] as! String)!
                                }
                                else if activity["Distance"] != nil {
                                    exerciseItem.exerciseDistance = Int(activity["Distance"] as! String)!
                                }
                                self.set.insert(exerciseItem)
                            }
                            else {
                                print("Was present")
                                print(exerciseItem.exerciseID)
                                print(exerciseItem.exerciseName)
                                let storedExerciseItem = self.set.first(where: {$0.exerciseID == exerciseItem.exerciseID || $0.exerciseName == exerciseItem.exerciseName})
                                self.set.remove(storedExerciseItem!)
                                if activity["Weight Amount"] != nil {
                                    storedExerciseItem?.exerciseWeightAmount += Float(activity["Weight Amount"] as! String)!
                                    storedExerciseItem?.exerciseSets += Int(activity["Sets"] as! String)!
                                    storedExerciseItem?.exerciseReps += Int(activity["Reps"] as! String)!
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
                        var row: DataTableRow = [DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""),]
                        var stringRow = ["", "", "", "", ""]
                        
                        row[0] = DataTableValueType.string(item.exerciseName)
                        stringRow[0] = item.exerciseName
                        
                        if item.exerciseWeightAmount != 0 {
                            row[1] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: item.exerciseWeightAmount))!)
                            stringRow[1] = self.numFormatter.string(from: NSNumber(value: item.exerciseWeightAmount))!
                        }
                        if item.exerciseTime != 0 {
                            let hours = (item.exerciseTime) / 3600
                            let minutes = ((item.exerciseTime) / 60) % 60
                            row[2] = DataTableValueType.string(String(format: "%02d:%02d", hours, minutes))
                            stringRow[2] = String(format: "%02d:%02d", hours, minutes)
                        }
                        if item.exerciseDistance != 0 {
                            row[3] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: item.exerciseDistance))!)
                            stringRow[3] = self.numFormatter.string(from: NSNumber(value: item.exerciseDistance))!
                        }
                        if item.exerciseCount != 0 {
                            row[4] = DataTableValueType.string(self.numberFormatter.string(from: NSNumber(value: item.exerciseCount))!)
                            stringRow[4] = self.numFormatter.string(from: NSNumber(value: item.exerciseCount))!
                        }
                        self.dataRows.append(row)
                        self.stringArray.append(stringRow)
                    }
                    self.addDataSourceAfter()
                }
            }
            else if response == "no result" {
                DispatchQueue.main.async {
                    self.dataRows = []
                    let row: DataTableRow = [DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""), DataTableValueType.string(""),]
                    let stringRow = ["", "", "", "", ""]
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
    
    public func addDataSourceAfter(){
        self.dataSource = self.dataRows
        self.dataTable.delegate = self
        self.dataTable.reload()
    }
    
    @objc func createPDF() {
      /*  let v = dataTable.collectionView
        let dst = URL(fileURLWithPath: NSTemporaryDirectory().appending("Year Total Report.pdf"))
        do {
            try PDFGenerator.generate([v], to: dst)
            openPDFViewer(dst)
        } catch (let error) {
            print(error)
        } */
        
        let fileName = "Year Total Report.csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        let stream = OutputStream(toFileAtPath: (path?.path)!, append: false)!
        let csv = try! CSVWriter(stream: stream)
        
        try! csv.write(row: ["Activity", "Weight", "Time", "Distance", "Count"])
        
        for row in stringArray {
            try! csv.write(row: [row[0], row[1], row[2], row[3], row[4]])
        }
        
        csv.stream.close()
        openPDFViewer(path!)
    }
    
    fileprivate func openPDFViewer(_ pdfPath: URL) {
        //let url = URL(fileURLWithPath: pdfPath)
        let storyboard = UIStoryboard(name: "PDFPreviewVC", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "PDFPreviewVC") as! PDFPreviewVC
        destVC.setupWithURL(pdfPath)
        destVC.messageTitle = "Years Total Report"
        present(destVC, animated: true, completion: nil)
    }
    
    @objc func goBack() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension YearTotalsReportVC: SwiftDataTableDataSource {
    public func dataTable(_ dataTable: SwiftDataTable, headerTitleForColumnAt columnIndex: NSInteger) -> String {
        return self.headerTitles[columnIndex]
    }
    
    public func numberOfColumns(in: SwiftDataTable) -> Int {
        return 5
    }
    
    func numberOfRows(in: SwiftDataTable) -> Int {
        return self.dataSource.count
    }
    
    public func dataTable(_ dataTable: SwiftDataTable, dataForRowAt index: NSInteger) -> [DataTableValueType] {
        return self.dataSource[index]
    }
}


extension YearTotalsReportVC: SwiftDataTableDelegate {
    @objc func dataTable(_ dataTable: SwiftDataTable, widthForColumnAt index: Int) -> CGFloat {
        return 150.0
    }
    
    @objc func fixedColumns(for dataTable: SwiftDataTable) -> DataTableFixedColumnType {
        return .init(leftColumns: 1)
    }
}
