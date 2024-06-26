//
//  CalendarVC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 7/6/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarVC: UIViewController, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var yearButton: UIButton!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var calendar: JTAppleCalendarView!
    var date = Date()
    var date2 = Date()
    var dateRange = false
    var oneDate = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupCalendar()
        
         NotificationCenter.default.addObserver(self, selector: #selector(updateYear(notification:)), name: .yearSelected, object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Prepare for Segue called")
        if segue.identifier == "showPopUp" {
            let popOverViewController = segue.destination
            popOverViewController.popoverPresentationController?.delegate = self
        }
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        print("Popover dismissed")
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func setupViews() {
        mainView.layer.cornerRadius = 10
        mainView.layer.masksToBounds = true
        cancelButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(confirmDate), for: .touchUpInside)
    }

    func setupCalendar() {
        calendar.allowsMultipleSelection = true
        calendar.minimumLineSpacing = 0
        calendar.minimumInteritemSpacing = 0
        //let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        calendar.scrollToDate(date, animateScroll: false)
        
        if dateRange {
            if date == date2 {
                print("Both dates are equal")
                print(date)
                print(date2)
                calendar.selectDates([date])
            }
            else {
                print("Both dates are not equal")
                print(date)
                print(date2)
                
                if oneDate {
                    calendar.selectDates([date])
                }
                else {
                    calendar.selectDates([date, date2])
                }
            }
        }
        else {
            calendar.selectDates([date])
        }
    }
    
    func handleCellTextColor(view: JTAppleCell?, cellState: CellState) {
        guard let validCell = view as? CalendarCVCell else { return }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier:"en_US_POSIX")
        formatter.dateFormat = "MM/dd/yyyy"
        
        if cellState.isSelected {
            validCell.dateLabel.textColor = UIColor.white
        }
        else {
            if cellState.dateBelongsTo == .thisMonth {
                validCell.dateLabel.textColor = UIColor.black
                
             /*   if cellState.date < Date() {
                    validCell.dateLabel.textColor = UIColor.lightGray
                }
                else {
                    validCell.dateLabel.textColor = UIColor.black
                } */
                
            }
            else {
                validCell.dateLabel.textColor = UIColor.lightGray
                //validCell.dateLabel.isHidden = true
            }
            
        }
        
        let cellDate = formatter.string(from: cellState.date)
        let currentDate = formatter.string(from: Date())
        if cellDate == currentDate {
            validCell.dateLabel.textColor = UIColor.init(hex: "#C52024")
        }
        if cellState.date > Date() {
            validCell.dateLabel.textColor = UIColor.lightGray
        }
    }
    
    func handleCellSelected(view: JTAppleCell?, cellState: CellState) {
        guard let validCell = view as? CalendarCVCell else { return }
        if cellState.isSelected {
            validCell.selectedView.isHidden = false
        } else {
            validCell.selectedView.isHidden = true
        }
    }
    
    func sharedFunctionToConfigureCell(myCustomCell: CalendarCVCell, cellState: CellState, date: Date) {
        myCustomCell.dateLabel.text = cellState.text
        
        handleCellTextColor(view: myCustomCell, cellState: cellState)
        handleCellSelected(view: myCustomCell, cellState: cellState)
        let date = calendar.visibleDates().monthDates.first!.date
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier:"en_US_POSIX")
        formatter.dateFormat = "MMMM"
        monthLabel.text = formatter.string(from: date)
        formatter.dateFormat = "yyyy"
        yearButton.setTitle(formatter.string(from: date), for: .normal)
    }
    
    @objc func updateYear(notification: Notification) {
        if let year = notification.object as? Int {
            print("Selected Year: ", year)
            yearButton.setTitle("\(year)", for: .normal)
            let currentDate = calendar.selectedDates
            print("Current Date: ", currentDate)
            if(currentDate.count > 0) {
            var dateComponents: DateComponents? = Calendar.current.dateComponents([.year, .month, .day], from: currentDate[0])
                dateComponents?.year = year
                let store: Date? = Calendar.current.date(from: dateComponents!)
                print("New Date: ", "\(store)")
                calendar.scrollToDate(store!) {
                    //self.calendar.selectDates([date])
                }
            }
            else {
                var dateComponents: DateComponents? = Calendar.current.dateComponents([.year, .month, .day], from: Date())
                dateComponents?.year = year
                let store: Date? = Calendar.current.date(from: dateComponents!)
                print("New Date: ", "\(store)")
                calendar.scrollToDate(store!) {
                    //self.calendar.selectDates([date])
                }
            }
        }
        else {
            print("No Year")
        }
    }
    
    @objc func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func confirmDate() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier:"en_US_POSIX")
        formatter.dateFormat = "MMM d, yyyy"
        let selectedDate = calendar.selectedDates
        print(selectedDate)
        if selectedDate.count > 0 {
            dismissVC()
            if dateRange {
                NotificationCenter.default.post(name: .confirmDateRange, object: selectedDate)
            }
            else {
                NotificationCenter.default.post(name: .confirmDate, object: selectedDate)
            }
        }
        else {
            self.showErrorHUD(text: "Please select a date first")
        }
    }
}

extension CalendarVC: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let myCustomCell = cell as! CalendarCVCell
        sharedFunctionToConfigureCell(myCustomCell: myCustomCell, cellState: cellState, date: date)
    }
    
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let myCustomCell = calendar.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CalendarCVCell
        sharedFunctionToConfigureCell(myCustomCell: myCustomCell, cellState: cellState, date: date)
        
        return myCustomCell
    }
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier:"en_US_POSIX")
        formatter.dateFormat = "MM/dd/yyyy"
        //let resultDate = formatter.string(from: Date())
        //let startDate = formatter.date(from: resultDate)
        let year = Calendar.current.component(.year, from: Date())
        let firstOfCurrentYear = Calendar.current.date(from: DateComponents(year: year - 1, month: 2, day: 1))
        let firstOfNextYear = Calendar.current.date(from: DateComponents(year: year + 1, month: 1, day: 1))
        let lastOfYear = Calendar.current.date(byAdding: .day, value: -1, to: firstOfNextYear!)
        let firstOfYear = Calendar.current.date(byAdding: .day, value: -1, to: firstOfCurrentYear!)
        let firstDate = formatter.date(from: formatter.string(from: firstOfYear!))
        let lastDate = formatter.date(from: formatter.string(from: lastOfYear!))
        let parameters = ConfigurationParameters(startDate: firstDate!, endDate: lastDate!)
        
        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        print("You scrolled")
        let date = visibleDates.monthDates.first!.date
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier:"en_US_POSIX")
        formatter.dateFormat = "MMMM"
        monthLabel.text = formatter.string(from: date)
        formatter.dateFormat = "yyyy"
        yearButton.setTitle(formatter.string(from: date), for: .normal)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        
        if dateRange {
            print("Date Range: true")
            if calendar.selectedDates.count < 2 {
                if cellState.date > Date() {
                    return false
                }
                return true
            }
            else {
                return false
            }
        }
        else {
            self.calendar.allowsMultipleSelection = false
            if cellState.date > Date() {
                return false
            }
            return true
        }
    }
}
