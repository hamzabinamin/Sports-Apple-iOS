//
//  GoalStatusReportVC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 6/10/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit
import SwiftDataTables

class GoalStatusReportVC: UIViewController {
    
    @IBOutlet weak var backImageView: UIImageView!
    var dataTable: SwiftDataTable! = nil
    var dataSource: DataTableContent = []
    
    let headerTitles = ["Activity", "Cumulative Goal", "Year-to-Date", "Weight Goal", "Max Weight",
                        "Distance Goal", "Total Distance", "Time Goal", "Max Time", "To Meet Goal",
                        "Pct%", "To Do Per Day", "Projected"]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        self.addDataSourceAfter()
    }
    
    func setupViews() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(goBack))
        backImageView.isUserInteractionEnabled = true
        backImageView.addGestureRecognizer(tap)
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = UIColor.white
        self.dataTable = SwiftDataTable(dataSource: self)
        self.dataTable.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //self.dataTable.frame.origin.x = self.view.frame.origin.x
        //self.dataTable.frame.origin.y = 600
        self.dataTable.translatesAutoresizingMaskIntoConstraints = false
        
        let topConstraint = self.dataTable.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 121)
        let bottomConstraint = self.dataTable.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        let leadingConstraint = self.dataTable.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
        let trailingConstraint = self.dataTable.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        self.view.addSubview(self.dataTable);
        NSLayoutConstraint.activate([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
    }
    
    public func addDataSourceAfter(){
        
        self.dataSource = [
            [
                DataTableValueType.string("Bench Press"),
                DataTableValueType.string(""),
                DataTableValueType.string(""),
                DataTableValueType.string("200"),
                DataTableValueType.string("150"),
                DataTableValueType.string(""),
                DataTableValueType.string(""),
                DataTableValueType.string(""),
                DataTableValueType.string(""),
                DataTableValueType.string("50"),
                DataTableValueType.string("75%"),
                DataTableValueType.string(""),
                DataTableValueType.string(""),
                ],
            [
                DataTableValueType.string("Foul Shots"),
                DataTableValueType.string("5,000"),
                DataTableValueType.string("5,000"),
                DataTableValueType.string(""),
                DataTableValueType.string(""),
                DataTableValueType.string(""),
                DataTableValueType.string(""),
                DataTableValueType.string(""),
                DataTableValueType.string(""),
                DataTableValueType.string("10,000"),
                DataTableValueType.string("60%"),
                DataTableValueType.string("67"),
                DataTableValueType.string("44,140"),
                ],
            [
                DataTableValueType.string("Sit-Ups"),
                DataTableValueType.string("80,000"),
                DataTableValueType.string("55,000"),
                DataTableValueType.string(""),
                DataTableValueType.string(""),
                DataTableValueType.string(""),
                DataTableValueType.string(""),
                DataTableValueType.string(""),
                DataTableValueType.string(""),
                DataTableValueType.string("24,720"),
                DataTableValueType.string("69%"),
                DataTableValueType.string("165"),
                DataTableValueType.string("93,847"),
                ],
            [
                DataTableValueType.string("Treadmill"),
                DataTableValueType.string(""),
                DataTableValueType.string(""),
                DataTableValueType.string(""),
                DataTableValueType.string(""),
                DataTableValueType.string(""),
                DataTableValueType.string(""),
                DataTableValueType.string("1:00"),
                DataTableValueType.string("0:35"),
                DataTableValueType.string(""),
                DataTableValueType.string(""),
                DataTableValueType.string(""),
                DataTableValueType.string(""),
                ],
        ]
        
        self.dataTable.reload()
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
}
