//
//  YearPopUpVC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 10/17/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit

class YearPopUpVC: UIViewController,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    let y1 = Calendar.current.date(byAdding: .year, value: -1, to: Date())
    let y2 = Calendar.current.date(byAdding: .year, value: -2, to: Date())
    let y3 = Calendar.current.date(byAdding: .year, value: -3, to: Date())
    let y4 = Calendar.current.component(.year, from:Date())
    var yearArray: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        yearArray = [(y4-1), y4]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return yearArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = "\(yearArray[indexPath.row])"
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let year = yearArray[indexPath.row]
        NotificationCenter.default.post(name: .yearSelected, object: year)
        dismiss(animated: true, completion: nil)
    }

}
