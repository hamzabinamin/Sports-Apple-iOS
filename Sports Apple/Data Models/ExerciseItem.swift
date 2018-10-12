//
//  Exercise.swift
//  Sports Apple
//
//  Created by Hamza Amin on 6/3/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import Foundation

class ExerciseItem: Hashable {

    var exerciseID: String
    var exerciseName: String
    var exerciseWeightAmount: Float
    var exerciseCount: Float
    var exerciseReps: Int
    var exerciseSets: Int
    var exerciseTime: Int
    var exerciseDistance: Int
    var exerciseComment: String
    var goalWeight: Float
    var goalTime: Int
    var goalDistance: Int
    var goalCount: Float
    var date: String
    var weeklyCount: [Int]
    
    var hashValue: Int { return exerciseID.hashValue }
    
    init() {
        self.exerciseID = ""
        self.exerciseName = ""
        self.exerciseWeightAmount = 0
        self.exerciseCount = 0
        self.exerciseReps = 0
        self.exerciseSets = 0
        self.exerciseTime = 0
        self.exerciseDistance = 0
        self.exerciseComment = ""
        self.goalWeight = 0
        self.goalTime = 0
        self.goalDistance = 0
        self.goalCount = 0
        self.date = ""
        self.weeklyCount = [Int](repeating: 0, count: 52)
    }
    
    init(exerciseID: String, exerciseName: String, exerciseWeightAmount: Float, exerciseCount: Float, exerciseReps: Int, exerciseSets: Int, exerciseTime: Int, exerciseDistance: Int, exerciseComment: String) {
        
        self.exerciseID = exerciseID
        self.exerciseName = exerciseName
        self.exerciseWeightAmount = exerciseWeightAmount
        self.exerciseCount = exerciseCount
        self.exerciseReps = exerciseReps
        self.exerciseSets = exerciseSets
        self.exerciseTime = exerciseTime
        self.exerciseDistance = exerciseDistance
        self.exerciseComment = exerciseComment
        self.goalWeight = 0
        self.goalTime = 0
        self.goalDistance = 0
        self.goalCount = 0
        self.date = ""
        self.weeklyCount = [Int](repeating: 0, count: 52)
    }
    
}

func ==(lhs: ExerciseItem, rhs: ExerciseItem) -> Bool {
    return lhs.exerciseID == rhs.exerciseID
}
