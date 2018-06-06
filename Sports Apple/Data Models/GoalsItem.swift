//
//  GoalsItem.swift
//  Sports Apple
//
//  Created by Hamza Amin on 6/6/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import Foundation

class GoalsItem {
    
    var activity: String
    var goalType: String
    var goalAmount: Int
    
    init(activity: String, goalType: String, goalAmount: Int) {
        self.activity = activity
        self.goalType = goalType
        self.goalAmount = goalAmount
    }
    
}
