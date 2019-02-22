//
//  User.swift
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
import AWSAuthCore

@objcMembers
class User: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userId: String?
    var _biceps: NSNumber?
    var _calves: NSNumber?
    var _chest: NSNumber?
    var _dOB: String?
    var _firstName: String?
    var _forearms: NSNumber?
    var _height: String?
    var _hips: NSNumber?
    var _lastName: String?
    var _location: String?
    var _neck: NSNumber?
    var _thighs: NSNumber?
    var _trainerEmail: String?
    var _units: String?
    var _waist: NSNumber?
    var _weight: NSNumber?
    var _wrist: NSNumber?
    var _subscriptionDetails: [String:String]?
    
    class func dynamoDBTableName() -> String {

        return "sportsapple-mobilehub-1970899121-User"
    }
    
    class func hashKeyAttribute() -> String {

        return "_userId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
               "_userId" : "userId",
               "_biceps" : "Biceps",
               "_calves" : "Calves",
               "_chest" : "Chest",
               "_dOB" : "DOB",
               "_firstName" : "First Name",
               "_forearms" : "Forearms",
               "_height" : "Height",
               "_hips" : "Hips",
               "_lastName" : "Last Name",
               "_location" : "Location",
               "_neck" : "Neck",
               "_thighs" : "Thighs",
               "_trainerEmail" : "Trainer Email",
               "_units" : "Units",
               "_waist" : "Waist",
               "_weight" : "Weight",
               "_wrist" : "Wrist",
               "_subscriptionDetails" : "Subscription Details",
        ]
    }
    
    func createUser(userId: String, firstName: String, lastName: String, trainerEmail: String, biceps: NSNumber, calves: NSNumber, chest: NSNumber, dOB: String, forearms: NSNumber, height: String, hips: NSNumber, location: String, neck: NSNumber, thighs: NSNumber, waist: NSNumber, weight: NSNumber, wrist: NSNumber, subscriptionDetails: [String: String], completion: @escaping (_ success: String) -> Void) {
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        
        // Create data object using data models you downloaded from Mobile Hub
        let userItem: User = User()
        userItem._userId = userId
        userItem._firstName = firstName
        userItem._lastName = lastName
        userItem._trainerEmail = trainerEmail
        userItem._biceps = biceps
        userItem._calves = calves
        userItem._chest = chest
        userItem._dOB = dOB
        userItem._forearms = forearms
        userItem._height = height
        userItem._hips = hips
        userItem._location = location
        userItem._neck = neck
        userItem._thighs = thighs
        userItem._units = "Imperial"
        userItem._waist = waist
        userItem._weight = weight
        userItem._wrist = wrist
        userItem._subscriptionDetails = subscriptionDetails
        //Save a new item
        dynamoDbObjectMapper.save(userItem, completionHandler: {
            (error: Error?) -> Void in
            
            if let error = error {
                print("Amazon DynamoDB Save Error 123: \(error)")
                completion(error.localizedDescription)
            }
            else {
                print("An item was saved.")
                completion("success")
            }
        })
    }
    
    func queryUser(userId: String, completion: @escaping (_ success: String, _ responseUser: UserItem) -> Void) {
        let responseUser: UserItem = UserItem()
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "#userId = :userId"
        
        queryExpression.expressionAttributeNames = [
            "#userId": "userId",
        ]
        queryExpression.expressionAttributeValues = [
            ":userId": userId
        ]
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        
        dynamoDbObjectMapper.query(User.self, expression: queryExpression) { (output: AWSDynamoDBPaginatedOutput?, error: Error?) in
            if error != nil {
                print("The request failed. Error: \(String(describing: error))")
                completion((error?.localizedDescription)!, responseUser)
            }
            if output != nil {
                for user in output!.items {
                    let userItem = user as? User
                    responseUser.firstName = (userItem?._firstName)!
                    responseUser.lastName = (userItem?._lastName)!
                    responseUser.trainerEmail = (userItem?._trainerEmail)!
                    responseUser.biceps = (userItem?._biceps)!
                    responseUser.calves = (userItem?._calves)!
                    responseUser.chest = (userItem?._chest)!
                    responseUser.dOB = (userItem?._dOB)!
                    responseUser.forearms = (userItem?._forearms)!
                    responseUser.height = (userItem?._height)!
                    responseUser.hips = (userItem?._hips)!
                    responseUser.location = (userItem?._location)!
                    responseUser.neck = (userItem?._neck)!
                    responseUser.thighs = (userItem?._thighs)!
                    responseUser.units = (userItem?._units)!
                    responseUser.userID = (userItem?._userId)!
                    responseUser.waist = (userItem?._waist)!
                    responseUser.weight = (userItem?._weight)!
                    responseUser.wrist = (userItem?._wrist)!
                    
                    if userItem?._subscriptionDetails != nil {
                        responseUser.subscriptionDetails = (userItem?._subscriptionDetails)!
                    }
                    else {
                        var subscriptionDetails: Dictionary = [String: String]()
                        subscriptionDetails["Type"] = "none"
                        subscriptionDetails["Expiration Date"] = "none"
                        subscriptionDetails["Original Purchase Date"] = "none"
                        subscriptionDetails["Purchase Date"] = "none"
                        subscriptionDetails["Original Transaction ID"] = "none"
                        responseUser.subscriptionDetails = subscriptionDetails
                    }
                }
                if output!.items.count > 0 {
                    completion("success", responseUser)
                }
                else {
                    completion("failure", responseUser)
                }
            }
        }
    }
}
