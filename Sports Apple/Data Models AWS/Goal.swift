//
//  Goal.swift
//  MySampleApp
//
//
// Copyright 2018 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to 
// copy, distribute and modify it.
//
// Source code generated from template: aws-my-sample-app-ios-swift v0.21
//

import Foundation
import UIKit
import AWSDynamoDB

@objcMembers
class Goal: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userId: String?
    var _distance: NSNumber?
    var _time: NSNumber?
    var _totals: NSNumber?
    var _weight: NSNumber?
    var _exerciseId: NSNumber?
    
    class func dynamoDBTableName() -> String {

        return "sportsapple-mobilehub-1970899121-Goal"
    }
    
    class func hashKeyAttribute() -> String {

        return "_userId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
               "_userId" : "userId",
               "_distance" : "Distance",
               "_time" : "Time",
               "_totals" : "Totals",
               "_weight" : "Weight",
               "_exerciseId" : "exerciseId",
        ]
    }
    
    func createGoal(goalItem: Goal) {
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        
        // Create data object using data models you downloaded from Mobile Hub
        
            //Save a new item
            dynamoDbObjectMapper.save(goalItem, completionHandler: {
                (error: Error?) -> Void in
                
                if let error = error {
                    print("Amazon DynamoDB Save Error: \(error)")
                    return
                }
                print("An item was saved.")
            })
    }
}
