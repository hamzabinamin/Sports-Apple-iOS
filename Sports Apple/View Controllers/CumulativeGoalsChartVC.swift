//
//  CumulativeGoalsChartVC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 6/11/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit

class CumulativeGoalsChartVC: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()

    }
    
    func setupViews() {
        //let chartViewWidth  = self.view.frame.size.width;
        //let chartViewHeight = self.view.frame.size.height;
        let aaChartView = AAChartView()
        //aaChartView.frame = CGRect(x:0,y:0,width:chartViewWidth,height:chartViewHeight)
        aaChartView.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = aaChartView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 121)
        let bottomConstraint = aaChartView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        let leadingConstraint = aaChartView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
        let trailingConstraint = aaChartView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        // set the content height of aachartView
        //aaChartView?.contentHeight = self.view.frame.size.height
        self.view.addSubview(aaChartView)
        NSLayoutConstraint.activate([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
        
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        
        let aaChartModel = AAChartModel.init()
            .chartType(AAChartType.Column)//Can be any of the chart types listed under `AAChartType`.
            .zoomType(AAChartZoomType.XY)
            .animationType(AAChartAnimationType.Bounce)
            .stacking(AAChartStackingType.False)
            //.title("TITLE")//The chart title
            .dataLabelEnabled(false) //Enable or disable the data labels. Defaults to false
            .tooltipValueSuffix("")//the value suffix of the chart tooltip
            .categories(["Week 1", "Week 2", "Week 3", "Week 4", "Week 5", "Week 6", "Week 7", "Week 8", "Week 9", "Week 10",
                         "Week 11", "Week 12", "Week 13", "Week 14", "Week 15", "Week 16", "Week 17", "Week 18", "Week 19", "Week 20",
                         "Week 21", "Week 22", "Week 23", "Week 24", "Week 25", "Week 26", "Week 27", "Week 28", "Week 29", "Week 30",
                         "Week 31", "Week 32", "Week 33", "Week 34", "Week 35", "Week 36", "Week 37", "Week 38", "Week 39", "Week 40",
                         "Week 41", "Week 42", "Week 43", "Week 44", "Week 45", "Week 46", "Week 47", "Week 48", "Week 49", "Week 50", "Week 51", "Week 52"])
            .colorsTheme(["#fe117c","#ffc069","#06caf4","#7dffc0"])
            .series([
                AASeriesElement()
                    .name("Bench Press")
                    .data([2000.0, 2500.9, 2900.5, 3400.5, 3180.2, 4210.5, 4925.2, 4826.5, 5123.3, 5118.3,
                           3000.0, 3500.9, 3900.5, 4400.5, 4180.2, 5210.5, 5925.2, 5826.5, 6123.3, 6118.3,
                           4000.0, 4500.9, 4900.5, 5400.5, 5180.2, 6210.5, 6925.2, 8826.5, 5123.3, 5118.3,
                           3000.0, 3500.9, 3900.5, 4400.5, 4180.2, 5210.5, 5925.2, 5826.5, 6123.3, 6118.3,
                           3000.0, 3500.9, 3900.5, 4400.5, 4180.2, 5210.5, 5925.2, 5826.5, 6123.3, 6118.3,
                           4000.0])
                    .toDic()!,
                AASeriesElement()
                    .name("Sit Ups")
                    .data([200.0, 250.9, 290.5, 340.5, 318.2, 421.5, 492.2, 482.5, 512.3, 511.3,
                           300.0, 350.9, 390.5, 440.5, 418.2, 520.5, 592.2, 582.5, 612.3, 611.3,
                           400.0, 450.9, 490.5, 540.5, 518.2, 621.5, 692.2, 882.5, 512.3, 511.3,
                           300.0, 350.9, 390.5, 440.5, 418.2, 521.5, 592.2, 582.5, 612.3, 611.3,
                           300.0, 350.9, 390.5, 440.5, 418.2, 521.5, 592.2, 582.5, 612.3, 611.3,
                           400.0])
                    .toDic()!,
                AASeriesElement()
                    .name("Push Ups")
                    .data([300.0, 450.9, 390.5, 340.5, 518.2, 721.5, 792.2, 482.5, 512.3, 511.3,
                           400.0, 550.9, 490.5, 440.5, 418.2, 720.5, 692.2, 582.5, 612.3, 611.3,
                           500.0, 650.9, 590.5, 540.5, 518.2, 621.5, 692.2, 882.5, 512.3, 511.3,
                           600.0, 550.9, 690.5, 640.5, 418.2, 521.5, 592.2, 582.5, 612.3, 611.3,
                           700.0, 550.9, 790.5, 740.5, 418.2, 521.5, 592.2, 582.5, 612.3, 611.3,
                           500.0])
                    .toDic()!,
                AASeriesElement()
                    .name("Running")
                    .data([3000.0, 4500.9, 3900.5, 3400.5, 5180.2, 7210.5, 7920.2, 4802.5, 5102.3, 5101.3,
                           4000.0, 5500.9, 4900.5, 4400.5, 4180.2, 7200.5, 6920.2, 5802.5, 6102.3, 6101.3,
                           5000.0, 6500.9, 5900.5, 5400.5, 5180.2, 6201.5, 6920.2, 8802.5, 5102.3, 5101.3,
                           6000.0, 5500.9, 6900.5, 6400.5, 4180.2, 5201.5, 5920.2, 5802.5, 6102.3, 6101.3,
                           7000.0, 5500.9, 7900.5, 7400.5, 4180.2, 5201.5, 5920.2, 5802.5, 6102.3, 6101.3,
                           5000.0])
                    .toDic()!,])
        
        aaChartView.aa_drawChartWithChartModel(aaChartModel)
    }
    
    @objc func goBack() {
        self.dismiss(animated: true, completion: nil)
    }
}
