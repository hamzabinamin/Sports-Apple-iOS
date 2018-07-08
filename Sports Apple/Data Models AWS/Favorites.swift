//
//  Favorites.swift
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
class Favorites: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userId: String?
    var _exerciseList: [[String: Any]]?
    
    class func dynamoDBTableName() -> String {

        return "sportsapple-mobilehub-1970899121-Favorites"
    }
    
    class func hashKeyAttribute() -> String {

        return "_userId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
               "_userId" : "userId",
               "_exerciseList" : "Exercise List",
        ]
    }
    
    func createFavorite(favoriteItem: Favorites, completion: @escaping (_ success: String) -> Void) {
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        
        // Create data object using data models you downloaded from Mobile Hub
        
        //Save a new item
        dynamoDbObjectMapper.save(favoriteItem, completionHandler: {
            (error: Error?) -> Void in
            
            if let error = error {
                print(error.localizedDescription)
                completion(error.localizedDescription)
                return
            }
            print("success")
            completion("success")
        })
    }
    
    func queryFavorites(userId: String, completion: @escaping (_ success: String, _ exerciseArray: [[String:Any]]) -> Void) {
        var exerciseArray: [[String:Any]] = []
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "#userId = :userId"
        
        queryExpression.expressionAttributeNames = [
            "#userId": "userId",
        ]
        queryExpression.expressionAttributeValues = [
            ":userId": userId
        ]
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        
        dynamoDbObjectMapper.query(Favorites.self, expression: queryExpression) { (output: AWSDynamoDBPaginatedOutput?, error: Error?) in
            if error != nil {
                print("The request failed. Error: \(String(describing: error))")
                completion((error?.localizedDescription)!, [])
            }
            if output != nil {
                for favorites in output!.items {
                    let favoritesItem = favorites as? Favorites
                    exerciseArray = (favoritesItem?._exerciseList)!
                }
                
                if exerciseArray.count > 0 {
                    completion("success", exerciseArray)
                }
                else {
                    completion("failure", exerciseArray)
                }
                
            }
        }
    }
}
