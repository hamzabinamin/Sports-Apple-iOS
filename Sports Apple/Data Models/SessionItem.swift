//
//  SessionItem.swift
//  Sports Apple
//
//  Created by Hamza Amin on 6/5/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import Foundation

class SessionItem {
    
    var sessionDate: String
    var sessionLocation: String
    var sessionBodyWeight: String
    var sessionCalories: String
    var sessionComment: String
    var sessionActivities: [Exercise]
    
    init(sessionDate: String, sessionLocation: String, sessionBodyWeight: String, sessionCalories: String, sessionComment: String) {
        self.sessionDate = sessionDate
        self.sessionLocation = sessionLocation
        self.sessionBodyWeight = sessionBodyWeight
        self.sessionCalories = sessionCalories
        self.sessionComment = sessionComment
        self.sessionActivities = []
    }
    
    
}
