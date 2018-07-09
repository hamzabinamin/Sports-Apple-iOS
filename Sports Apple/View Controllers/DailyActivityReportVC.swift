//
//  DailyActivityReportVC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 6/10/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit
import SwiftDataTables

class DailyActivityReportVC: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    var dataTable: SwiftDataTable! = nil
    var dataSource: DataTableContent = []
    
    let headerTitles = ["Date", "Exercise", "Weight", "Reps", "Sets", "Count", "Distance", "Time"]

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
        
        let topConstraint = self.dataTable.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 171)
        let bottomConstraint = self.dataTable.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        let leadingConstraint = self.dataTable.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
        let trailingConstraint = self.dataTable.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        self.view.addSubview(self.dataTable)
        
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        
        NSLayoutConstraint.activate([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
    }
    
    public func addDataSourceAfter(){
        
        self.dataSource = [
            [
                DataTableValueType.string("30/5/2018"),
                DataTableValueType.string("Bike"),
                DataTableValueType.string(""),
                DataTableValueType.string(""),
                DataTableValueType.string(""),
                DataTableValueType.string(""),
                DataTableValueType.string(""),
                DataTableValueType.string("0:22"),
                
                ],
            [
                DataTableValueType.string("30/5/2018"),
                DataTableValueType.string("Curls"),
                DataTableValueType.string("30"),
                DataTableValueType.string("10"),
                DataTableValueType.string("3"),
                DataTableValueType.string(""),
                DataTableValueType.string(""),
                DataTableValueType.string(""),
                ],
            [
                DataTableValueType.string("2/6/2018"),
                DataTableValueType.string("Cable Cross"),
                DataTableValueType.string("30"),
                DataTableValueType.string("10"),
                DataTableValueType.string("3"),
                DataTableValueType.string(""),
                DataTableValueType.string(""),
                DataTableValueType.string(""),
                ],
            [
                DataTableValueType.string("3/6/2018"),
                DataTableValueType.string("Treadmill"),
                DataTableValueType.string(""),
                DataTableValueType.string(""),
                DataTableValueType.string(""),
                DataTableValueType.string(""),
                DataTableValueType.string("2"),
                DataTableValueType.string("0:35"),
                ],
        ]
        
        self.dataTable.reload()
    }
    
    @objc func goBack() {
        self.dismiss(animated: true, completion: nil)
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
