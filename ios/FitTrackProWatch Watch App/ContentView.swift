//
//  ContentView.swift
//  FitTrackProWatch Watch App
//
//  Created by user on 24/12/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        VStack(spacing: 12) {
            // Connection Status
            HStack {
                Circle()
                    .fill(workoutManager.isPhoneReachable ? Color.green : Color.red)
                    .frame(width: 10, height: 10)
                Text(workoutManager.isPhoneReachable ? "Connected" : "Not Connected")
                    .font(.caption2)
            }
            
            if workoutManager.isWorkoutActive {
                WorkoutActiveView()
            } else {
                WorkoutStartView()
            }
        }
        .onAppear {
            print("Watch: ContentView appeared, sending ready")
            workoutManager.sendWatchReadyToPhone()
        }
    }
}

struct WorkoutStartView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.walk")
                .font(.system(size: 50))
                .foregroundColor(.green)
            
            Text("Walking")
                .font(.headline)
            
            Button(action: {
                workoutManager.startWorkout()
            }) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Start")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
        .padding()
    }
}

struct WorkoutActiveView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                Text(workoutManager.elapsedTimeString)
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(.green)
                
                HStack(spacing: 16) {
                    VStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        Text("\(workoutManager.heartRate)")
                            .font(.headline)
                        Text("BPM")
                            .font(.caption2)
                    }
                    
                    VStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("\(workoutManager.calories)")
                            .font(.headline)
                        Text("CAL")
                            .font(.caption2)
                    }
                }
                
                HStack(spacing: 16) {
                    VStack {
                        Image(systemName: "figure.walk")
                            .foregroundColor(.blue)
                        Text("\(workoutManager.steps)")
                            .font(.headline)
                        Text("STEPS")
                            .font(.caption2)
                    }
                    
                    VStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.purple)
                        Text(String(format: "%.1f", workoutManager.distance / 1000))
                            .font(.headline)
                        Text("KM")
                            .font(.caption2)
                    }
                }
                
                Button(action: {
                    workoutManager.stopWorkout()
                }) {
                    HStack {
                        Image(systemName: "stop.fill")
                        Text("Stop")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(WorkoutManager())
}
