//
//  YearsTotalReportVC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 6/10/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit
import SwiftDataTables

class YearTotalsReportVC: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    var dataTable: SwiftDataTable! = nil
    var dataSource: DataTableContent = []
    
    let headerTitles = ["Activity", "Weight", "Time", "Distance", "Count"]

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
        self.view.addSubview(self.dataTable)
        
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        
        NSLayoutConstraint.activate([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
    }
    
    public func addDataSourceAfter(){
        
        self.dataSource = [
            [
                DataTableValueType.string("Bench Press"),
                DataTableValueType.string("5,200"),
                DataTableValueType.string(""),
                DataTableValueType.string(""),
                DataTableValueType.string(""),
                ],
            [
                DataTableValueType.string("Bike"),
                DataTableValueType.string(""),
                DataTableValueType.string(""),
                DataTableValueType.string("550.0"),
                DataTableValueType.string(""),
                ],
            [
                DataTableValueType.string("Sit-Ups"),
                DataTableValueType.string(""),
                DataTableValueType.string(""),
                DataTableValueType.string(""),
                DataTableValueType.string("55,280"),
                ],
            [
                DataTableValueType.string("Treadmill"),
                DataTableValueType.string(""),
                DataTableValueType.string("4:22"),
                DataTableValueType.string("15:50"),
                DataTableValueType.string(""),
                ],
        ]
        
        self.dataTable.reload()
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
