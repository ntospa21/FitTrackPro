//
//  FitTrackProWatchApp.swift
//  FitTrackProWatch Watch App
//
//  Created by user on 24/12/25.
//

import SwiftUI

@main
struct FitTrackProWatchApp: App {
    @StateObject private var workoutManager = WorkoutManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(workoutManager)
                .onAppear {
                    print("Watch App: ContentView appeared")
                    workoutManager.sendWatchReadyToPhone()
                }
        }
    }
}
