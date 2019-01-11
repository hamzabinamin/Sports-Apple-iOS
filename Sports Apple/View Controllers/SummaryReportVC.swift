//
//  SummaryReportVC.swift
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
import MessageUI
import CSV

class SummaryReportVC: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var chartButton: UIButton!
    @IBOutlet weak var exportButton: UIButton!
    var dataTable: SwiftDataTable! = nil
    var dataSource: DataTableContent = []
    var hud: JGProgressHUD?
    var array: [Activity] = []
    var pool: AWSCognitoIdentityUserPool?
    var session: Activity = Activity()
    var set: Set<String> = []
    let formatter = DateFormatter()
    let numberFormatter: NumberFormatter = NumberFormatter()
    var daysWorkedOut = 0
    var daysInYear = 365
    var daysPastInYear = 0
    var daysLeftInYear = 0
    var weeks: Float = 0.0
    
    var totalCalories: Float = 0
    var avgWeeklyCalories: Float = 0
    var avgWorkoutCalories: Float = 0
    var avgWeeklyWorkouts: Float = 0
    var totalWeightMoved: Float = 0
    var daysPast = 0
    var daysLeft = 0
    var workoutDays = 0
    var percentageOfActivityDays: Float = 0
    
    let headerTitles = ["Terms", "Calculations"]
    var data: Data?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        self.addDataSourceAfter()
        
        daysPastInYear = Calendar.current.ordinality(of: .day, in: .year, for: Date())!
        daysLeftInYear = daysInYear - daysPastInYear
        daysPast = daysPastInYear
        daysLeft = daysLeftInYear
        weeks = Float(daysPastInYear)/Float(7)
        print(daysPastInYear)
        
        getSessions()
    }
    
    func setupViews() {
        hud = self.createLoadingHUD()
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = UIColor.white
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
        self.dataTable = SwiftDataTable(dataSource: self)
        self.dataTable.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.dataTable.translatesAutoresizingMaskIntoConstraints = false
        
        //self.formatter.dateFormat = "MM/dd/yyyy h:mm a"
        self.formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        self.formatter.locale = Locale(identifier:"en_US_POSIX")
        self.numberFormatter.locale = Locale(identifier:"en_US")
        self.numberFormatter.numberStyle = NumberFormatter.Style.decimal
        self.numberFormatter.maximumFractionDigits = 1
        
        let topConstraint = self.dataTable.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 121)
        let bottomConstraint = self.dataTable.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        let leadingConstraint = self.dataTable.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
        let trailingConstraint = self.dataTable.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        self.view.addSubview(self.dataTable);
        
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        chartButton.addTarget(self, action: #selector(goToChartsVC), for: .touchUpInside)
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
                        //self.formatter.dateFormat = "MM/dd/yyyy h:mm a"
                        self.formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                        let date = self.formatter.date(from: item._date!)
                        self.formatter.dateFormat = "yyyy-MM-dd"
                        let dateString = self.formatter.string(from: date!)
                        self.set.insert(dateString)
                        
                        self.totalCalories += item._calories!.floatValue
                        
                        for activity in item._exerciseList! {
                            if activity["Weight Amount"] != nil {
                                self.totalWeightMoved += Float(activity["Weight Amount"] as! String)!
                            }
                        }
                    }
                    self.daysWorkedOut = self.set.count
                    self.avgWeeklyCalories = Float(Float(self.totalCalories)/Float(self.weeks))
                    self.avgWorkoutCalories = Float(Float(self.totalCalories)/Float(self.daysWorkedOut))
                    self.avgWeeklyWorkouts = Float(Float(self.daysWorkedOut)/Float(self.weeks))
                    self.daysPast = self.daysPastInYear
                    self.daysLeft = self.daysLeftInYear
                    self.workoutDays = self.daysWorkedOut
                    
                    self.percentageOfActivityDays = Float((Float(self.daysWorkedOut)/Float(self.daysPast)) * 100)
                    
                    print("Total Calories: ", String(format: "%.0f", locale: Locale.current, Double(self.totalCalories)))
                    print("Average Weekly Calories: ", self.avgWeeklyCalories)
                    print("Average Workout Calories: ", self.avgWorkoutCalories)
                    print("Average Weekly Workouts: ", self.avgWeeklyWorkouts)
                    print("Total Weight Moved: ", self.totalWeightMoved)
                    print("Days Past: ", self.daysPast)
                    print("Days Left: ", self.daysLeft)
                    print("Workout Days: ", self.daysWorkedOut)
                    print("Percent of Activity Days: ", String(format: "%.1f", locale: Locale.current, Double(self.percentageOfActivityDays)) + "%")
                    
//                    /"\(self.percentageOfActivityDays)" + "%")
                    
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

    public func addDataSourceAfter() {
        //String(format: "%d", locale: Locale.current, self.totalCalories)
        
        self.dataSource = [
                            [
                            DataTableValueType.string("Total Calories"),
                            DataTableValueType.string(numberFormatter.string(from: NSNumber(value: self.totalCalories))!),
                            ],
                           [
                            DataTableValueType.string("Avg. Weekly Calories"),
                            DataTableValueType.string(numberFormatter.string(from: NSNumber(value: self.avgWeeklyCalories))!),
                            ],
                           [
                            DataTableValueType.string("Avg. Workout Calories"),
                            DataTableValueType.string(numberFormatter.string(from: NSNumber(value: self.avgWorkoutCalories))!),
                            ],
                           [
                            DataTableValueType.string("Avg. Weekly Workouts"),
                            DataTableValueType.string(numberFormatter.string(from: NSNumber(value: self.avgWeeklyWorkouts))!),
                            ],
                           [
                            DataTableValueType.string("Total Weight Moved"),
                            DataTableValueType.string(numberFormatter.string(from: NSNumber(value: self.totalWeightMoved))!),
                            ],
                           [
                            DataTableValueType.string("Days Passed"),
                            DataTableValueType.string(numberFormatter.string(from: NSNumber(value: self.daysPast))!),
                            ],
                           [
                            DataTableValueType.string("Days Left"),
                            DataTableValueType.string(numberFormatter.string(from: NSNumber(value: self.daysLeft))!),
                            ],
                           [
                            DataTableValueType.string("Workout Days"),
                            DataTableValueType.string(numberFormatter.string(from: NSNumber(value: self.workoutDays))!),
                            ],
                           [
                            DataTableValueType.string("Percent of Activity Days"),
                            //DataTableValueType.string(String(format: "%.01f", Double(self.percentageOfActivityDays)) + "%"),
                            DataTableValueType.string(numberFormatter.string(from: NSNumber(value: self.percentageOfActivityDays))! + "%"),
                            ],
        ]
        
        self.dataTable.reload()
    
        ////
     /*   let fileManager = FileManager.default
        if let tDocumentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath =  tDocumentDirectory.appendingPathComponent("\("CSV_FOLDER")")
            if !fileManager.fileExists(atPath: filePath.path) {
                do {
                    try fileManager.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
                    
                    let stream = OutputStream(toFileAtPath: filePath.path, append: false)!
                    let csv = try! CSVWriter(stream: stream)
                    
                    try! csv.write(row: ["Terms", "Calculations"])
                    try! csv.write(row: ["Total Calories", numberFormatter.string(from: NSNumber(value: self.totalCalories))!])
                    try! csv.write(row: ["Avg. Weekly Calories", numberFormatter.string(from: NSNumber(value: self.avgWeeklyCalories))!])
                    try! csv.write(row: ["Avg. Workout Calories", numberFormatter.string(from: NSNumber(value: self.avgWorkoutCalories))!])
                    try! csv.write(row: ["Avg. Weekly Workouts", numberFormatter.string(from: NSNumber(value: self.avgWeeklyWorkouts))!])
                    try! csv.write(row: ["Total Weight Moved", numberFormatter.string(from: NSNumber(value: self.totalWeightMoved))!])
                    try! csv.write(row: ["Days Passed", numberFormatter.string(from: NSNumber(value: self.daysPast))!])
                    try! csv.write(row: ["Days Left", numberFormatter.string(from: NSNumber(value: self.daysLeft))!])
                    try! csv.write(row: ["Workout Days", numberFormatter.string(from: NSNumber(value: self.workoutDays))!])
                    try! csv.write(row: ["Percent of Activity Days", numberFormatter.string(from: NSNumber(value: self.percentageOfActivityDays))! + "%"])
                    
                    csv.stream.close()
                } catch {
                    NSLog("Couldn't create document directory")
                }
            }
            NSLog("Document directory is \(filePath)")
        } */
        

        
        
        // Creating a string.
        let mailString = NSMutableString()
        mailString.append("Terms, Calculations\n")
        mailString.append("Total Calories," + String(totalCalories) + "\n")
        mailString.append("Avg. Weekly Calories," + String(self.avgWeeklyCalories) + "\n")
        mailString.append("Avg. Workout Calories," + String(self.avgWorkoutCalories) + "\n")
        mailString.append("Avg. Weekly Workouts," + String(self.avgWeeklyWorkouts) + "\n")
        mailString.append("Total Weight Moved," + String(self.totalWeightMoved) + "\n")
        mailString.append("Days Passed," + String(self.daysPast) + "\n")
        mailString.append("Days Left," + String(self.daysLeft) + "\n")
        mailString.append("Workout Days," + String(self.workoutDays) + "\n")
        mailString.append("Percent of Activity Days," + String(self.percentageOfActivityDays) + "%\n")
        
        // Converting it to NSData.
        data = mailString.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)
        
        // Unwrapping the optional.
        if let content = data {
            print("NSData: \(content)")
        }
        else {
            print("No Data")
        }
        
      
    }

    @objc func createPDF() {
        let v = dataTable.collectionView
        let dst = URL(fileURLWithPath: NSTemporaryDirectory().appending("Summary Report.pdf"))
        //let dst2 = NSHomeDirectory() + "/\("Summary Report").pdf"
        // outputs as Data
      
        /*  do {
            let data = try PDFGenerator.generated(by: [v])
            try data.write(to: dst, options: .atomic)
        } catch (let error) {
            print(error)
        } */
        
        // writes to Disk directly.
      /*  do {
            try PDFGenerator.generate([v], to: dst)
            openPDFViewer(dst)
        } catch (let error) {
            print(error)
        } */
        
        let fileName = "Summary Report.csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        let stream = OutputStream(toFileAtPath: (path?.path)!, append: false)!
        let csv = try! CSVWriter(stream: stream)
        
        let numFormatter = NumberFormatter()
        numFormatter.locale = Locale(identifier:"en_US")
        numFormatter.maximumFractionDigits = 1
        
        try! csv.write(row: ["Terms", "Calculations"])
        try! csv.write(row: ["Total Calories", numFormatter.string(from: NSNumber(value: self.totalCalories))!])
        try! csv.write(row: ["Avg. Weekly Calories", numFormatter.string(from: NSNumber(value: self.avgWeeklyCalories))!])
        try! csv.write(row: ["Avg. Workout Calories", numFormatter.string(from: NSNumber(value: self.avgWorkoutCalories))!])
        try! csv.write(row: ["Avg. Weekly Workouts", numFormatter.string(from: NSNumber(value: self.avgWeeklyWorkouts))!])
        try! csv.write(row: ["Total Weight Moved", numFormatter.string(from: NSNumber(value: self.totalWeightMoved))!])
        try! csv.write(row: ["Days Passed", numFormatter.string(from: NSNumber(value: self.daysPast))!])
        try! csv.write(row: ["Days Left", numFormatter.string(from: NSNumber(value: self.daysLeft))!])
        try! csv.write(row: ["Workout Days", numFormatter.string(from: NSNumber(value: self.workoutDays))!])
        try! csv.write(row: ["Percent of Activity Days", numFormatter.string(from: NSNumber(value: self.percentageOfActivityDays))! + "%"])
        
        csv.stream.close()
        openPDFViewer(path!)
    }
    
    fileprivate func openPDFViewer(_ pdfPath: URL) {
        //let url = URL(fileURLWithPath: pdfPath)
        let storyboard = UIStoryboard(name: "PDFPreviewVC", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "PDFPreviewVC") as! PDFPreviewVC
        destVC.setupWithURL(pdfPath)
        destVC.messageTitle = "Summary Report"
        present(destVC, animated: true, completion: nil)
        //sendEmail(string: data!)
    }
    
    func sendEmail(string: Data) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.setMessageBody("<p>You're so awesome!</p>", isHTML: true)
            mail.setToRecipients(["Enter one or more emails here"])
            mail.mailComposeDelegate = self  //  Make sure to set this property to self, so that the controller can be dismissed!
            
            //Set the subject
            mail.setSubject("email with document pdf")
            
          /*  let url = URL(fileURLWithPath: pdfPath)
            if let fileData = NSData(contentsOf: url) {
                print ("File data loaded.")
                print (fileData)
                mail.addAttachmentData(fileData as Data, mimeType: "application/pdf", fileName: "GST")
            } */
             mail.addAttachmentData(string, mimeType: "text/csv", fileName: "GST")
            present(mail, animated: true, completion: nil)
            
        }
        
        else {
            print ("Error")
        } 
        let emailViewController = configuredMailComposeViewController(string: data!)
        if MFMailComposeViewController.canSendMail() {
            self.present(emailViewController, animated: true, completion: nil)
        }
    }
    
    func configuredMailComposeViewController(string: Data) -> MFMailComposeViewController {
        let emailController = MFMailComposeViewController()
        emailController.mailComposeDelegate = self
        emailController.setSubject("CSV File")
        emailController.setMessageBody("", isHTML: false)
        
        // Attaching the .CSV file to the email.
        emailController.addAttachmentData(string, mimeType: "text/csv", fileName: "Summary Report.csv")
        
        return emailController
    }

    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    @objc func goBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func goToChartsVC() {
        let storyboard = UIStoryboard(name: "Charts", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "ChartsVC")
        self.present(destVC, animated: true, completion: .none)
    }
}

extension SummaryReportVC: SwiftDataTableDataSource {
    public func dataTable(_ dataTable: SwiftDataTable, headerTitleForColumnAt columnIndex: NSInteger) -> String {
        return self.headerTitles[columnIndex]
    }
    
    public func numberOfColumns(in: SwiftDataTable) -> Int {
        return 2
    }
    
    func numberOfRows(in: SwiftDataTable) -> Int {
        return self.dataSource.count
    }
    
    public func dataTable(_ dataTable: SwiftDataTable, dataForRowAt index: NSInteger) -> [DataTableValueType] {
        return self.dataSource[index]
    }
}
