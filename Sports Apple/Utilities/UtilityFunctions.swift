//
//  UtilityFunctions.swift
//  Sports Apple
//
//  Created by Hamza Amin on 6/23/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import Foundation
import AWSDynamoDB

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
    
    static func getExerciseList()-> [String] {
        let exerciseList = [
            "2-Way Raise",
            "Ab Coaster / Roller",
            "Abdominal",
            "Abs",
            "Arm Circles",
            "Arnold Curl",
            "Arnold Press",
            "Back Extensions",
            "Band Leg Curl",
            "Band Pull Aparts",
            "Band Pushdown",
            "Band Retraction",
            "Band Twist",
            "Bear Crawl",
            "Belt Squat",
            "Bench Press",
            "Bench Press - Close Grip",
            "Bench Press Decline",
            "Bench Press Incline",
            "Bent Arm Pullover",
            "Bent Over Row",
            "Bent Row - Lying",
            "Bicycle",
            "Bulgarian Split Squat",
            "Burpees",
            "Cable Ab Pulldown",
            "Cable Abduction",
            "Cable Adduction",
            "Cable Cross",
            "Cable Cross Down",
            "Cable Cross Up",
            "Cable Curl",
            "Cable Face Pull",
            "Cable Lat",
            "Cable Pull Down",
            "Cable Pull Up",
            "Cable Row",
            "Cable Shoulder Abduction",
            "Cable Shoulder Adduction",
            "Cable Tricep",
            "Cable Twist",
            "Calf Extensions",
            "Calf Raise",
            "Cambered Bar Squat",
            "Chair Squat Pose",
            "Chest Supported DB Row",
            "Chin Ups",
            "Clean and Jerk",
            "Clean Grip DL",
            "Close Grip Foam Roller Bench",
            "Concentrated Curl",
            "Contralateral Limb Raises",
            "Conventional DL",
            "Crunch",
            "Curls",
            "Deadlifts",
            "Dips",
            "Donkey Kick",
            "Elbows Out Extension",
            "Eliptical",
            "Farmers' Walk",
            "Fat Bar Bench Press",
            "Finger Curls",
            "Flat Chest Pullover",
            "Floor Press",
            "Foam Roller Bench Press",
            "French Press",
            "Front Foot Elevated Split Squat",
            "Front Raise Pullover",
            "Front Squat",
            "Front Squat Sit Ups",
            "Glutes",
            "Goblet Squat",
            "Half Kneeling Jammer Press",
            "Hammer Curl",
            "Hammer Row",
            "Hammer Row - Low Supinated",
            "Hammer Row - Neutral Grip",
            "Hammer Row - Pronated Grip",
            "Hammer Row - Wide Neutral",
            "Handstand Push-Up",
            "Hang Clean",
            "Hang Power Clean",
            "High Pull",
            "Hyperextension",
            "Incline Chest Press",
            "Indoor Bike",
            "Jammer Squat to Press",
            "Jerk Balance",
            "JM Press",
            "Jump Rope",
            "Jumping Jacks",
            "L Lateral Raise",
            "Landmine Rotation",
            "Lat Pulldown",
            "Lateral Lunge",
            "Lateral Raise",
            "Lateral Squat",
            "Laterial Lifts",
            "Leaning Lateral Raise",
            "Leg Abduction",
            "Leg Adduction",
            "Leg Curl",
            "Leg Extension",
            "Leg Press",
            "Leg Raise",
            "Legs Push Back",
            "Lunge",
            "Lunge Jump",
            "Lying Chest Fly",
            "MB Twist",
            "Meadow's Row",
            "Mid Thigh Rack Clean",
            "Military Press",
            "Mountain Climber",
            "NG Chin Ups",
            "OH Bar Sit Ups",
            "OH Plate Sit Ups",
            "One Armed Swing",
            "Outdoor Bike",
            "Overhead Dual Tricep Hammer",
            "Overhead Press",
            "Overhead Single Tricep Hammer",
            "Palms Down Behind Back",
            "Palms Down Wrist Curl",
            "Pause at Knee Clean",
            "Paused Bench Press",
            "Pistol Squat",
            "Plank",
            "Plank Side",
            "Plank-to-Push-Up",
            "Plate Twist",
            "Plyometric Push-Up",
            "Power Clean",
            "Preacher Curl",
            "Press Decline",
            "Press Incline",
            "Prone Walkout",
            "Pull-Ups",
            "Push Jerk",
            "Push Press",
            "Push-Up",
            "Push-Up Diamond",
            "Quadruped Leg Lift",
            "Romanian Deadlift",
            "Romanian Deadlift + Shrug",
            "Reverse Curl",
            "Reverse Hyper",
            "Reverse Lunge",
            "Rip & Press",
            "Rockers",
            "Rolling Tricep",
            "Rope Pushdown",
            "Rotator Cuff Rotation",
            "Row",
            "Rowing",
            "Run",
            "Seated Bench Press",
            "Seated Calf Extention",
            "Seated Calf Raise",
            "Seated Chest Fly",
            "Seated Delts",
            "Seated Leag Adduction",
            "Seated Leg Abduction",
            "Seated Leg Lifts",
            "Seated Leg Press",
            "Seated Overhead Press",
            "Seated Shrug",
            "Seated Tricep Press",
            "Shoulder Bridge",
            "Shoulder Schrugs",
            "Shrug",
            "Single Leg Deadlift",
            "Sit Ups",
            "Skullcruhers",
            "Sled Walks",
            "Snatch DL",
            "Snatch Grip Shrug",
            "Split Jerk",
            "Split Squats",
            "Squat",
            "Squat Clean",
            "SSB Squat",
            "Standing Chest Fly",
            "Standing Press",
            "Step-Up",
            "Suitcase Carry",
            "Sumo DL",
            "Superman",
            "Swings",
            "Toe Raise",
            "Torso Rotation",
            "Trap Bar DL",
            "Tricep Kickbacks (Row)",
            "Treadmill",
            "Tricep Extension",
            "Tricep Press",
            "Triceps Dip",
            "Tuck Jump",
            "UH Barbell Row",
            "Up Row",
            "W Raise",
            "Waiter Walks",
            "Wall Sit",
            "Wrist Curl Palms Down",
            "Wrist Rotation",
            "Zercher Squat",
            "Zottman Curl"
        ]
        return exerciseList
    }
    
    static func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    static func getExercises(completion: @escaping (_ success: String, _ exerciseArray: [Exercise]) -> Void) {
        var exerciseList: [Exercise] = []
        let scanExpression = AWSDynamoDBScanExpression()
        scanExpression.limit = 500
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        dynamoDbObjectMapper.scan(Exercise.self, expression: scanExpression).continueWith(block: { (task:AWSTask<AWSDynamoDBPaginatedOutput>!) -> Any? in
            if let error = task.error as NSError? {
                print("The request failed. Error: \(error)")
                completion("failure", [])
            } else if let paginatedOutput = task.result {
                for exercise in paginatedOutput.items {
                    let store = Exercise()
                    let id = exercise.value(forKey: "_exerciseId")! as! NSNumber
                    let name = exercise.value(forKey: "_name")! as! String
                    store?._exerciseId = id
                    store?._name = name
                    exerciseList.append(store!)
                    print(exercise.value(forKey: "_exerciseId")!)
                    print(exercise.value(forKey: "_name")!)
                    
                }
            }
            return()
        })

    }
}
