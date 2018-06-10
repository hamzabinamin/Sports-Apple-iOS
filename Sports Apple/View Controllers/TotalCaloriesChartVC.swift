//
//  TotalCaloriesChart.swift
//  Sports Apple
//
//  Created by Hamza Amin on 6/11/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit
//import AAChart

class TotalCaloriesChartVC: UIViewController {
    
    @IBOutlet weak var backImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(goBack))
        backImageView.isUserInteractionEnabled = true
        backImageView.addGestureRecognizer(tap)
        let aaChartView = AAChartView()
        aaChartView.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = aaChartView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 121)
        let bottomConstraint = aaChartView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        let leadingConstraint = aaChartView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
        let trailingConstraint = aaChartView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        // set the content height of aachartView
        // aaChartView?.contentHeight = self.view.frame.size.height
        self.view.addSubview(aaChartView)
        NSLayoutConstraint.activate([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
        
        let aaChartModel = AAChartModel.init()
            .chartType(AAChartType.Column)//Can be any of the chart types listed under `AAChartType`.
            .animationType(AAChartAnimationType.Bounce)
            //.title("TITLE")//The chart title
            .dataLabelEnabled(false) //Enable or disable the data labels. Defaults to false
            .tooltipValueSuffix(" Calories")//the value suffix of the chart tooltip
            .categories(["Week 1", "Week 2", "Week 3", "Week 4", "Week 5", "Week 6", "Week 7", "Week 8", "Week 9", "Week 10",
                "Week 11", "Week 12", "Week 13", "Week 14", "Week 15", "Week 16", "Week 17", "Week 18", "Week 19", "Week 20",
                "Week 21", "Week 22", "Week 23", "Week 24", "Week 25", "Week 26", "Week 27", "Week 28", "Week 29", "Week 30",
                "Week 31", "Week 32", "Week 33", "Week 34", "Week 35", "Week 36", "Week 37", "Week 38", "Week 39", "Week 40",
                "Week 41", "Week 42", "Week 43", "Week 44", "Week 45", "Week 46", "Week 47", "Week 48", "Week 49", "Week 50", "Week 51"])
            .colorsTheme(["#06caf4"])
            .series([
                AASeriesElement()
                    .name("Workout")
                    .data([2000.0, 2500.9, 2900.5, 3400.5, 3180.2, 4210.5, 4925.2, 4826.5, 5123.3, 5118.3,
                           3000.0, 3500.9, 3900.5, 4400.5, 4180.2, 5210.5, 5925.2, 5826.5, 6123.3, 6118.3,
                           4000.0, 4500.9, 4900.5, 5400.5, 5180.2, 6210.5, 6925.2, 8826.5, 5123.3, 5118.3,
                           3000.0, 3500.9, 3900.5, 4400.5, 4180.2, 5210.5, 5925.2, 5826.5, 6123.3, 6118.3,
                           3000.0, 3500.9, 3900.5, 4400.5, 4180.2, 5210.5, 5925.2, 5826.5, 6123.3, 6118.3,
                           4000.0])
                    .toDic()!,
               ])
        
        aaChartView.aa_drawChartWithChartModel(aaChartModel)
    }
    
    @objc func goBack() {
        self.dismiss(animated: true, completion: nil)
    }
}
