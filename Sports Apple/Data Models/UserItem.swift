//
//  UserItem.swift
//  Sports Apple
//
//  Created by Hamza Amin on 6/23/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import Foundation

class UserItem: NSObject, NSCoding {
    
    var userID: String
    var email: String
    var password: String
    var newPassword: String
    var biceps: NSNumber
    var calves: NSNumber
    var chest: NSNumber
    var dOB: String
    var firstName: String
    var forearms: NSNumber
    var height: String
    var hips: NSNumber
    var lastName: String
    var location: String
    var neck: NSNumber
    var thighs: NSNumber
    var trainerEmail: String
    var units: String
    var waist: NSNumber
    var weight: NSNumber
    var wrist: NSNumber
    var subscriptionDetails: [String: String]
    
    override init() {
        userID = ""
        email = ""
        password = ""
        newPassword = ""
        biceps = -1
        calves = -1
        chest = -1
        dOB = ""
        firstName = ""
        forearms = -1
        height = ""
        hips = -1
        lastName = ""
        location = ""
        neck = -1
        thighs = -1
        trainerEmail = ""
        units = ""
        waist = -1
        weight = -1
        wrist = -1
        subscriptionDetails = [String: String]()
    }
    
    init(userID: String, email: String, password: String, newPassword: String, biceps: NSNumber, calves: NSNumber, chest: NSNumber, dOB: String, firstName: String, forearms: NSNumber, height: String, hips: NSNumber, lastName: String, location: String, neck: NSNumber, thighs: NSNumber, trainerEmail: String, units: String, waist: NSNumber, weight: NSNumber, wrist: NSNumber, subscriptionDetails: [String: String]) {
        self.userID = userID
        self.email = email
        self.password = password
        self.newPassword = newPassword
        self.biceps = biceps
        self.calves = calves
        self.chest = chest
        self.dOB = dOB
        self.firstName = firstName
        self.forearms = forearms
        self.height = height
        self.hips = hips
        self.lastName = lastName
        self.location = location
        self.neck = neck
        self.thighs = thighs
        self.trainerEmail = trainerEmail
        self.units = units
        self.waist = waist
        self.weight = weight
        self.wrist = wrist
        self.subscriptionDetails = subscriptionDetails
    }
    
    required init(coder decoder: NSCoder) {
        self.userID = decoder.decodeObject(forKey: "userID") as? String ?? ""
        self.email = decoder.decodeObject(forKey: "email") as? String ?? ""
        self.password = decoder.decodeObject(forKey: "password") as? String ?? ""
        self.newPassword = decoder.decodeObject(forKey: "newPassword") as? String ?? ""
        self.biceps = decoder.decodeObject(forKey: "biceps") as? NSNumber ?? 0
        self.calves = decoder.decodeObject(forKey: "calves") as? NSNumber ?? 0
        self.chest = decoder.decodeObject(forKey: "chest") as? NSNumber ?? 0
        self.dOB = decoder.decodeObject(forKey: "dOB") as? String ?? ""
        self.firstName = decoder.decodeObject(forKey: "firstName") as? String ?? ""
        self.forearms = decoder.decodeObject(forKey: "forearms") as? NSNumber ?? 0
        self.height = decoder.decodeObject(forKey: "height") as? String ?? ""
        self.hips = decoder.decodeObject(forKey: "hips") as? NSNumber ?? 0
        self.lastName = decoder.decodeObject(forKey: "lastName") as? String ?? ""
        self.location = decoder.decodeObject(forKey: "location") as? String ?? ""
        self.neck = decoder.decodeObject(forKey: "neck") as? NSNumber ?? 0
        self.thighs = decoder.decodeObject(forKey: "thighs") as? NSNumber ?? 0
        self.trainerEmail = decoder.decodeObject(forKey: "trainerEmail") as? String ?? ""
        self.units = decoder.decodeObject(forKey: "units") as? String ?? ""
        self.waist = decoder.decodeObject(forKey: "waist") as? NSNumber ?? 0
        self.weight = decoder.decodeObject(forKey: "weight") as? NSNumber ?? 0
        self.wrist = decoder.decodeObject(forKey: "wrist") as? NSNumber ?? 0
        self.subscriptionDetails = decoder.decodeObject(forKey: "subscriptionDetails") as? [String: String] ?? [String: String]()
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(userID, forKey: "userID")
        coder.encode(email, forKey: "email")
        coder.encode(password, forKey: "password")
        coder.encode(newPassword, forKey: "newPassword")
        coder.encode(biceps, forKey: "biceps")
        coder.encode(calves, forKey: "calves")
        coder.encode(chest, forKey: "chest")
        coder.encode(dOB, forKey: "dOB")
        coder.encode(firstName, forKey: "firstName")
        coder.encode(forearms, forKey: "forearms")
        coder.encode(height, forKey: "height")
        coder.encode(hips, forKey: "hips")
        coder.encode(lastName, forKey: "lastName")
        coder.encode(location, forKey: "location")
        coder.encode(neck, forKey: "neck")
        coder.encode(thighs, forKey: "thighs")
        coder.encode(trainerEmail, forKey: "trainerEmail")
        coder.encode(units, forKey: "units")
        coder.encode(waist, forKey: "waist")
        coder.encode(weight, forKey: "weight")
        coder.encode(wrist, forKey: "wrist")
        coder.encode(subscriptionDetails, forKey: "subscriptionDetails")
    }
    
}
