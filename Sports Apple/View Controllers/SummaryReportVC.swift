//
//  SummaryReportVC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 6/10/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit
import SwiftDataTables

class SummaryReportVC: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var chartButton: UIButton!
    var dataTable: SwiftDataTable! = nil
    var dataSource: DataTableContent = []
    
    let headerTitles = ["Terms", "Calculations"]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        self.addDataSourceAfter()
    }
    
    func setupViews() {
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = UIColor.white
        self.dataTable = SwiftDataTable(dataSource: self)
        self.dataTable.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.dataTable.translatesAutoresizingMaskIntoConstraints = false
        
        let topConstraint = self.dataTable.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 121)
        let bottomConstraint = self.dataTable.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        let leadingConstraint = self.dataTable.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
        let trailingConstraint = self.dataTable.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        self.view.addSubview(self.dataTable);
        
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        chartButton.addTarget(self, action: #selector(goToChartsVC), for: .touchUpInside)
        
        NSLayoutConstraint.activate([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
    }

    public func addDataSourceAfter(){
        
        self.dataSource = [
                            [
                            DataTableValueType.string("Total Calories"),
                            DataTableValueType.string("89,650"),
                            ],
                           [
                            DataTableValueType.string("Avg. Weekly Calories"),
                            DataTableValueType.string("2,919"),
                            ],
                           [
                            DataTableValueType.string("Avg. Workout Calories"),
                            DataTableValueType.string("747"),
                            ],
                           [
                            DataTableValueType.string("Avg. Weekly Workouts"),
                            DataTableValueType.string("4"),
                            ],
                           [
                            DataTableValueType.string("Total Weight Moved"),
                            DataTableValueType.string("6,968"),
                            ],
                           [
                            DataTableValueType.string("Days Passed"),
                            DataTableValueType.string("215"),
                            ],
                           [
                            DataTableValueType.string("Days Left"),
                            DataTableValueType.string("150"),
                            ],
                           [
                            DataTableValueType.string("Workout Days"),
                            DataTableValueType.string("120"),
                            ],
                           [
                            DataTableValueType.string("Percent of Activity Days"),
                            DataTableValueType.string("56%"),
                            ],
        ]
        
        self.dataTable.reload()
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
