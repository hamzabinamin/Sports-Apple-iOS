//
//  Exercise.swift
//  Sports Apple
//
//  Created by Hamza Amin on 6/3/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import Foundation

class ExerciseItem {
    
    var exerciseID: String
    var exerciseName: String
    var exerciseWeightAmount: Int
    var exerciseCount: Int
    var exerciseReps: Int
    var exerciseSets: Int
    var exerciseTime: Int
    var exerciseDistance: Int
    var exerciseComment: String
    
    init(exerciseID: String, exerciseName: String, exerciseWeightAmount: Int, exerciseCount: Int, exerciseReps: Int, exerciseSets: Int, exerciseTime: Int, exerciseDistance: Int, exerciseComment: String) {
        
        self.exerciseID = exerciseID
        self.exerciseName = exerciseName
        self.exerciseWeightAmount = exerciseWeightAmount
        self.exerciseCount = exerciseCount
        self.exerciseReps = exerciseReps
        self.exerciseSets = exerciseSets
        self.exerciseTime = exerciseTime
        self.exerciseDistance = exerciseDistance
        self.exerciseComment = exerciseComment
    }
    
}
