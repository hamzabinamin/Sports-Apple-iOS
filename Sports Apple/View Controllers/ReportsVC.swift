//
//  ReportsVC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 6/10/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit

class ReportsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var array:[Reports] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        array.append(Reports(report: "Summary Report", description: "Year-to-date statistics"))
        array.append(Reports(report: "YTD Goal Status Report", description: "Check where you stand with any goals that you created"))
        array.append(Reports(report: "Year Totals Report", description: "The total amount of weight, time, distance and count of any activity entered into the daily activity log"))
        array.append(Reports(report: "Daily Activity Report", description: "Your daily activity report with date selection"))

        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ReportsTVCell
        cell.reportNameLabel.text = array[indexPath.row].report
        cell.descriptionLabel.text = array[indexPath.row].description
        cell.nextImageView.transform = CGAffineTransform(rotationAngle: .pi);
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
          /*  let tap = UITapGestureRecognizer(target: self, action: #selector(goToSummaryReportVC))
            cell.nextImageView.isUserInteractionEnabled = true
            cell.nextImageView.addGestureRecognizer(tap) */
            goToSummaryReportVC()
        }
        else if indexPath.row == 1 {
          /*  let tap = UITapGestureRecognizer(target: self, action: #selector(goToGoalStatusReportVC))
            cell.nextImageView.isUserInteractionEnabled = true
            cell.nextImageView.addGestureRecognizer(tap) */
            goToGoalStatusReportVC()
        }
        else if indexPath.row == 2 {
          /*  let tap = UITapGestureRecognizer(target: self, action: #selector(goToYearTotalsReportVC))
            cell.nextImageView.isUserInteractionEnabled = true
            cell.nextImageView.addGestureRecognizer(tap) */
            goToYearTotalsReportVC()
        }
        else if indexPath.row == 3 {
          /*  let tap = UITapGestureRecognizer(target: self, action: #selector(goToDailyActivityReportVC))
            cell.nextImageView.isUserInteractionEnabled = true
            cell.nextImageView.addGestureRecognizer(tap) */
            goToDailyActivityReportVC()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func goToSummaryReportVC() {
        let storyboard = UIStoryboard(name: "SummaryReport", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "SummaryReportVC")
        self.present(destVC, animated: true, completion: .none)
    }
    
    @objc func goToGoalStatusReportVC() {
        let storyboard = UIStoryboard(name: "GoalStatusReport", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "GoalStatusReportVC")
        self.present(destVC, animated: true, completion: .none)
    }
    
    @objc func goToYearTotalsReportVC() {
        let storyboard = UIStoryboard(name: "YearTotalsReport", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "YearTotalsReportVC")
        self.present(destVC, animated: true, completion: .none)
    }
    
    @objc func goToDailyActivityReportVC() {
        let storyboard = UIStoryboard(name: "DailyActivityReport", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "DailyActivityReportVC")
        self.present(destVC, animated: true, completion: .none)
    }
}
