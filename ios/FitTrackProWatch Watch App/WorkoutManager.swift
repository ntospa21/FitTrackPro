//
//  WorkoutManager.swift
//  FitTrackProWatch Watch App
//
//  Created by user on 24/12/25.
//

import Foundation
import HealthKit
import WatchConnectivity

class WorkoutManager: NSObject, ObservableObject {
    private let healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?
    private var wcSession: WCSession?
    @Published var isPhoneReachable: Bool = false
    @Published var isWorkoutActive = false
    @Published var heartRate: Int = 0
    @Published var calories: Int = 0
    @Published var steps: Int = 0
    @Published var distance: Double = 0.0
    @Published var elapsedTime: TimeInterval = 0
    
    private var startDate: Date?
    private var timer: Timer?
    
    var elapsedTimeString: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = (Int(elapsedTime) % 3600) / 60
        let seconds = Int(elapsedTime) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    override init() {
        super.init()
        requestAuthorization()
        setupWatchConnectivity()
    }
    
    private func setupWatchConnectivity() {
        if WCSession.isSupported() {
            wcSession = WCSession.default
            wcSession?.delegate = self
            wcSession?.activate()
        }
    }
    
    private func requestAuthorization() {
        let typesToShare: Set<HKSampleType> = [
            HKObjectType.workoutType()
        ]
        
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.workoutType()
        ]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            if !success {
                print("Authorization failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func startWorkout() {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .walking
        configuration.locationType = .outdoor
        
        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session?.associatedWorkoutBuilder()
            
            session?.delegate = self
            builder?.delegate = self
            
            builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
            
            startDate = Date()
            session?.startActivity(with: startDate!)
            builder?.beginCollection(withStart: startDate!) { success, error in
                if success {
                    DispatchQueue.main.async {
                        self.isWorkoutActive = true
                        self.startTimer()
                        // Send workout started to iPhone
                        self.sendWorkoutStatusToPhone(isActive: true)
                    }
                }
            }
        } catch {
            print("Error starting workout: \(error.localizedDescription)")
        }
    }
    
    func stopWorkout() {
        session?.end()
        stopTimer()
        
        builder?.endCollection(withEnd: Date()) { success, error in
            if success {
                self.builder?.finishWorkout { workout, error in
                    DispatchQueue.main.async {
                        self.isWorkoutActive = false
                        // Send workout stopped to iPhone
                        self.sendWorkoutStatusToPhone(isActive: false)
                        self.sendWorkoutCompleteToPhone()
                    }
                }
            }
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if let start = self.startDate {
                self.elapsedTime = Date().timeIntervalSince(start)
                self.sendLiveDataToPhone()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func sendWorkoutStatusToPhone(isActive: Bool) {
        guard let wcSession = wcSession, wcSession.isReachable else {
            print("Phone is not reachable")
            return
        }
        
        let data: [String: Any] = [
            "type": "workoutStatus",
            "isActive": isActive
        ]
        
        wcSession.sendMessage(data, replyHandler: nil) { error in
            print("Error sending workout status: \(error.localizedDescription)")
        }
    }
    
    private func sendLiveDataToPhone() {
        guard let wcSession = wcSession, wcSession.isReachable else { return }
        
        let data: [String: Any] = [
            "type": "liveData",
            "heartRate": heartRate,
            "calories": calories,
            "steps": steps,
            "distance": distance,
            "duration": Int(elapsedTime),
            "isActive": isWorkoutActive
        ]
        
        wcSession.sendMessage(data, replyHandler: nil) { error in
            print("Error sending live data: \(error.localizedDescription)")
        }
    }
    
    private func sendWorkoutCompleteToPhone() {
        guard let wcSession = wcSession, wcSession.isReachable else { return }
        
        let data: [String: Any] = [
            "type": "workoutComplete",
            "heartRate": heartRate,
            "calories": calories,
            "steps": steps,
            "distance": distance,
            "duration": Int(elapsedTime),
            "isActive": false
        ]
        
        wcSession.sendMessage(data, replyHandler: nil) { error in
            print("Error sending workout data: \(error.localizedDescription)")
        }
    }
    
 // Find this function and make sure it's NOT private:

func sendWatchReadyToPhone() {  // <-- No 'private' keyword
    guard let wcSession = wcSession else {
        print("Watch: WCSession is nil")
        return
    }
    
    print("Watch: Sending ready, isReachable=\(wcSession.isReachable)")
    
    let data: [String: Any] = [
        "type": "watchReady",
        "isActive": isWorkoutActive
    ]
    
    if wcSession.isReachable {
        wcSession.sendMessage(data, replyHandler: { reply in
            print("Watch: Phone replied: \(reply)")
        }) { error in
            print("Watch: Error sending ready: \(error.localizedDescription)")
        }
    } else {
        wcSession.transferUserInfo(data)
        print("Watch: Phone not reachable, using transferUserInfo")
    }
}
    
}

// MARK: - HKWorkoutSessionDelegate
extension WorkoutManager: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        DispatchQueue.main.async {
            self.isWorkoutActive = toState == .running
            self.sendWorkoutStatusToPhone(isActive: toState == .running)
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout session failed: \(error.localizedDescription)")
    }
}

// MARK: - HKLiveWorkoutBuilderDelegate
extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else { continue }
            
            if let statistics = workoutBuilder.statistics(for: quantityType) {
                DispatchQueue.main.async {
                    self.updateStatistics(statistics)
                }
            }
        }
    }
    
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}
    
    private func updateStatistics(_ statistics: HKStatistics) {
        switch statistics.quantityType {
        case HKQuantityType.quantityType(forIdentifier: .heartRate):
            let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
            if let value = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) {
                heartRate = Int(value)
            }
            
        case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
            let calorieUnit = HKUnit.kilocalorie()
            if let value = statistics.sumQuantity()?.doubleValue(for: calorieUnit) {
                calories = Int(value)
            }
            
        case HKQuantityType.quantityType(forIdentifier: .stepCount):
            let stepsUnit = HKUnit.count()
            if let value = statistics.sumQuantity()?.doubleValue(for: stepsUnit) {
                steps = Int(value)
            }
            
        case HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning):
            let distanceUnit = HKUnit.meter()
            if let value = statistics.sumQuantity()?.doubleValue(for: distanceUnit) {
                distance = value
            }
            
        default:
            break
        }
    }
}

// MARK: - WCSessionDelegate
extension WorkoutManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed: \(error.localizedDescription)")
        } else {
            print("WCSession activated on watch")
            DispatchQueue.main.async {
                self.sendWatchReadyToPhone()
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let command = message["command"] as? String {
                switch command {
                case "startWorkout":
                    self.startWorkout()
                case "stopWorkout":
                    self.stopWorkout()
                default:
                    break
                }
            }
        }
    }
}
