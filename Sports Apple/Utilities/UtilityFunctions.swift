//
//  UtilityFunctions.swift
//  Sports Apple
//
//  Created by Hamza Amin on 6/23/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import Foundation

class UtilityFunctions {
    
    static func saveUserDefaults(value: UserItem) {
        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: value)
        UserDefaults.standard.set(encodedData, forKey: "User")
    }
    
    static func getUserDefaults() -> UserItem? {
        if UserDefaults.standard.object(forKey: "User") != nil {
            let decoded  = UserDefaults.standard.object(forKey: "User") as! Data
            let decoded2 = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! UserItem
            return decoded2
        }
        else {
            return nil
        }
    }
}
