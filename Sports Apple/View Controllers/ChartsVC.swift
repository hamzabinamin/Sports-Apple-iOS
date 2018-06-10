//
//  ChartsVC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 6/10/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit

class ChartsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var array:[Reports] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        array.append(Reports(report: "Total Calories Graph", description: "Weekly breakdown for the entire year"))
        array.append(Reports(report: "Cumulative Goals Graph", description: "Weekly breakdown for the entire year"))
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
        
        if indexPath.row == 0 {
            let tap = UITapGestureRecognizer(target: self, action: #selector(goToTotalCaloriesChartVC))
            cell.nextImageView.isUserInteractionEnabled = true
            cell.nextImageView.addGestureRecognizer(tap)
        }
        else if indexPath.row == 1 {
            let tap = UITapGestureRecognizer(target: self, action: #selector(goToCumulativeGoalsChartVC))
            cell.nextImageView.isUserInteractionEnabled = true
            cell.nextImageView.addGestureRecognizer(tap)
        }
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func setupViews() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(goBack))
        backImageView.isUserInteractionEnabled = true
        backImageView.addGestureRecognizer(tap)
        tableView.tableFooterView = UIView()
    }
    
    @objc func goToTotalCaloriesChartVC() {
        let storyboard = UIStoryboard(name: "TotalCaloriesChart", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "TotalCaloriesChartVC")
        self.present(destVC, animated: true, completion: .none)
    }
    
    @objc func goToCumulativeGoalsChartVC() {
        let storyboard = UIStoryboard(name: "CumulativeGoalsChart", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "CumulativeGoalsChartVC")
        self.present(destVC, animated: true, completion: .none)
    }
    
    @objc func goBack() {
        self.dismiss(animated: true, completion: nil)
    }

}
